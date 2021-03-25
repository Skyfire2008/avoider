package org.skyfire2008.avoider.game.components;

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

class ShooterBehaviour implements Interfaces.UpdateComponent implements Interfaces.DeathComponent {
	private static inline var idleSpeed = 32.0;
	private static inline var rotSpeed = 1.0;
	private static inline var reloadTime = 5;
	private static inline var idleTargetRadius = 40;
	private static inline var aimTime = 1;
	private static inline var a = 32;

	private static var beamFactory: EntityFactoryMethod;

	private var state: ShooterState;
	private var pos: Point;
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

	public static function init() {
		beamFactory = Game.instance.entMap.get("shooterBeam.json");
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
		vel = holder.velocity;
		vel.x = idleSpeed;
		side = holder.side;
	}

	public function onUpdate(time: Float) {
		if (state == Idling) {
			// if idling, wait until gun reloads, then request a target
			if (this.time > reloadTime && !observingTargets) {
				observingTargets = true;
				TargetingSystem.instance.addTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
			}

			// accelerate if needed
			if (vel.length < idleSpeed) {
				vel.add(vel.scale(1 / vel.length * a));
			}
		} else if (state == Aiming) {
			// if aimed enough, fire!
			if (this.time < aimTime) {
				// if aiming, move the crosshair towards target
				var crosshairVel = shootTargetPos.difference(crosshairPos);
				crosshairVel.mult(Math.pow(this.time / aimTime, 4));
				crosshairPos.add(crosshairVel);

				// set beam props
				var dir = crosshairPos.difference(pos);
				beamAngle.value = Math.atan2(dir.y, dir.x);
				beamMult.setAll(this.time / aimTime);
			} else {
				state = Firing;
				this.time = 0;
				crosshairPos.x = shootTargetPos.x;
				crosshairPos.y = shootTargetPos.y;
			}

			// decelerate if needed
			if (vel.length > 1) {
				var friction = Math.pow(Constants.mju, time * 60);
				vel.mult(friction);
			}
		} else {
			// if firing, delay and shoot
			if (this.time >= Constants.reactionTime) {
				var myCol = new Collider(this.owner, pos, 0, new Wrapper(Side.Hostile));

				var colliders = Game.instance.queryLine(pos, crosshairPos);
				for (col in colliders) {
					if (col.owner != this.owner) {
						col.owner.onCollide(myCol);
						break;
					}
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
		var angVel = rotSpeed * time;
		Util.turnTo(pos, vel, angVel, moveTargetPos);

		// if close to the target, reset it
		if (moveTargetPos.distance(pos) < ChaserBehaviour.idleTargetRadius) {
			moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
		}

		this.time += time;
	}

	public function onDeath() {
		if (beam != null) {
			beam.kill();
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
	}
}
