package org.skyfire2008.avoider.game.components;

import howler.Howl;

import org.skyfire2008.avoider.spatial.Collider;

import spork.core.Wrapper;
import spork.core.PropertyHolder;
import spork.core.JsonLoader.EntityFactoryMethod;
import spork.core.Entity;

import org.skyfire2008.avoider.game.TargetingSystem;
import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.graphics.ColorMult;

using org.skyfire2008.avoider.geom.Point;

enum ShooterState {
	Idling;
	Aiming;
	Firing;
}

class ShooterBehaviour implements Interfaces.UpdateComponent implements Interfaces.DeathComponent implements Interfaces.InitComponent {
	private static inline var idleSpeed = 32.0;
	private static inline var rotSpeed = 1.0;
	private static inline var reloadTime = 5.0;
	private static inline var halfTime = 2.5; // half of reload time
	private static inline var idleTargetRadius = 40;
	private static inline var aimTime = 1.0;
	private static inline var a = 16;
	private static inline var trailLength = 10.0;

	private static var shootSound: Howl;
	private static var chargeSound: Howl;
	private static var beamFactory: EntityFactoryMethod;
	private static var trailFactory: EntityFactoryMethod;
	private static var indicatorFactory: EntityFactoryMethod;

	private var state: ShooterState;
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var side: Wrapper<Side>;
	private var vel: Point;
	private var time: Float;
	private var moveTargetPos: Point;
	private var shootTargetPos: Point;
	private var shootTargetId: Int;
	private var observingTargets: Bool;

	private var crosshairPos: Point;
	private var beam: Entity;
	private var beamAngle: Wrapper<Float>;
	private var beamMult: ColorMult;

	private var indicator: Entity;
	private var indicMult: ColorMult;

	public static function init() {
		beamFactory = Game.instance.entMap.get("shooterBeam.json");
		trailFactory = Game.instance.entMap.get("shooterTrail.json");
		indicatorFactory = Game.instance.entMap.get("shooterIndicator.json");
		shootSound = SoundSystem.instance.getSound("shooterShoot.wav");
		chargeSound = SoundSystem.instance.getSound("shooterCharge.mp3");
	}

	public function new() {
		state = Idling;
		time = -Math.random() * reloadTime;
		observingTargets = false;
		crosshairPos = new Point(0, 0);
		beamAngle = new Wrapper(0.0);
		beamMult = [0.0, 0.0, 0.0];
		moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		rotation = holder.rotation;
		vel = holder.velocity;
		vel.x = idleSpeed;
		side = holder.side;
	}

	public function onInit() {
		indicMult = [1.0, 0, 0];
		indicator = indicatorFactory((holder) -> {
			holder.position = pos;
			holder.rotation = rotation;
			holder.colorMult = indicMult;
		});
		Game.instance.addEntity(indicator);
	}

	public function onUpdate(deltaTime: Float) {
		if (state == Idling) {
			// if idling, wait until gun reloads, then request a target
			if (this.time > reloadTime && !observingTargets) {
				observingTargets = true;
				TargetingSystem.instance.addTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
			}

			// accelerate if needed
			var velLength = vel.length;
			if (velLength < idleSpeed) {
				vel.add(vel.scale(1 / velLength * a));
			} else if (velLength > idleSpeed) {
				vel.mult(idleSpeed / velLength);
			}
		} else if (state == Aiming) {
			// if aimed enough, aim
			if (this.time < aimTime) {
				// if aiming, move the crosshair towards target
				var crosshairVel = shootTargetPos.difference(crosshairPos);
				crosshairVel.mult(Math.pow(this.time / aimTime, 4));
				crosshairPos.add(crosshairVel);

				// set beam props
				var dir = crosshairPos.difference(pos);
				beamAngle.value = Math.atan2(dir.y, dir.x);
				beamMult.setAll(0.5 * this.time / aimTime);
				beamMult.b = 0;
			} else {
				TargetingSystem.instance.removeTargetDeathObserver(shootTargetId, notifyAboutDeath);
				state = Firing;
				this.time = 0;
				beamMult.set([1.0, 0.0, 0.0]);
				crosshairPos.x = shootTargetPos.x;
				crosshairPos.y = shootTargetPos.y;
			}

			// decelerate if needed
			if (vel.length > 1) {
				var friction = Math.pow(Constants.mju, deltaTime * 60);
				vel.mult(friction);
			}
		} else {
			// if firing, delay and shoot
			if (this.time >= Constants.reactionTime) {
				SoundSystem.instance.playSound(shootSound, pos.x, true);
				var myCol = new Collider(new Entity("shooterBeam.json"), pos, 0, new Wrapper(Side.Hostile));

				// find the end point(where beam intersects the reactagnle containing the game)
				var k = Point.difference(crosshairPos, pos);
				var tx: Float;
				var ty: Float;
				if (k.x > 0) {
					tx = (Constants.gameWidth - pos.x) / (crosshairPos.x - pos.x);
				} else {
					tx = (0 - pos.x) / (crosshairPos.x - pos.x);
				}

				if (k.y > 0) {
					ty = (Constants.gameHeight - pos.y) / (crosshairPos.y - pos.y);
				} else {
					ty = (0 - pos.y) / (crosshairPos.y - pos.y);
				}

				var t = Math.min(tx, ty);

				var trailT = 1.0; // t for bullet trail length

				var pos2 = Point.translate(pos, Point.scale(k, t));
				var collisions = Game.instance.querySegment(pos, pos2);
				for (res in collisions) {
					if (res.col.owner != this.owner) {
						res.col.owner.onCollide(myCol);
						trailT = res.t;
						break;
					}
				}

				// draw the bullet trail
				k = pos2.difference(pos).scale(trailT);
				var pos1 = k.translate(pos);
				var trailNum = Std.int(pos1.difference(pos).length / trailLength) + 1;
				var step = 1 / trailNum;

				for (i in 0...trailNum) {
					Game.instance.addEntity(trailFactory((holder) -> {
						holder.scale = new Wrapper(trailLength);
						holder.timeToLive = new Wrapper(0.5 + Math.sqrt(i) / 8);
						holder.rotation = new Wrapper(Math.atan2(k.y, k.x));
						holder.position = k.scale(step * i).translate(pos);
						holder.velocity = Point.fromPolar(Math.random() * Math.PI * 2, Math.sqrt(trailNum - i) * 3);
						holder.angVel = new Wrapper(Util.rand(9) / Math.sqrt(i));
					}));
				}

				// reset state
				this.time = 0;
				state = Idling;
				beam.kill();
				beam = null;
				beamMult.setAll(0.0);
			}
		}

		// turn towards target
		var angVel = rotSpeed * deltaTime;
		Util.turnTo(pos, vel, angVel, moveTargetPos);

		// if close to the target, reset it
		if (moveTargetPos.distance(pos) < ChaserBehaviour.idleTargetRadius) {
			moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
		}

		this.time += deltaTime;

		// change indicator color multiplier
		if (state == Idling) {
			if (time < halfTime) {
				indicMult.set([time / halfTime, 1.0, 0]);
			} else {
				indicMult.set([1.0, (reloadTime - time) / halfTime, 0]);
			}
		}
	}

	public function onDeath() {
		indicator.kill();

		if (beam != null) {
			beam.kill();
			beam = null;
		}

		if (shootTargetId > 0) {
			TargetingSystem.instance.removeTargetDeathObserver(shootTargetId, notifyAboutDeath);
		} else if (observingTargets) {
			TargetingSystem.instance.removeTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
		}
	}

	public function notifyAboutTargets(targets: Array<{id: Int, pos: Point}>) {
		var closest: {id: Int, pos: Point} = null;
		var closestDist: Float = Math.POSITIVE_INFINITY;

		// go through all possible targets to select the closest one within range
		for (target in targets) {
			var distance = Point.distance(target.pos, pos);
			if (distance < closestDist) {
				closest = target;
				closestDist = distance;
			}
		}
		time = 0;
		shootTargetPos = closest.pos;
		shootTargetId = closest.id;
		observingTargets = false;
		state = Aiming;
		SoundSystem.instance.playSound(chargeSound, pos.x, true);
		beam = beamFactory((holder) -> {
			holder.position = pos;
			holder.rotation = beamAngle;
			holder.colorMult = beamMult;
		});
		crosshairPos.x = pos.x;
		crosshairPos.y = pos.y;
		crosshairPos.add(vel);
		Game.instance.addEntity(beam);

		TargetingSystem.instance.addTargetDeathObserver(shootTargetId, notifyAboutDeath);
	}

	public function notifyAboutDeath() {
		shootTargetPos = null;
		shootTargetId = -1;
		state = Idling;
		time = 0;
		if (beam != null) {
			beam.kill();
			beam = null;
			beamMult.setAll(0.0);
		}
	}
}
