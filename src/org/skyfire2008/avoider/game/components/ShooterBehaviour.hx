package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.spatial.Collider;

import spork.core.Wrapper;
import spork.core.PropertyHolder;
import spork.core.JsonLoader.EntityFactoryMethod;
import spork.core.Entity;

import org.skyfire2008.avoider.game.TargetingSystem;
import org.skyfire2008.avoider.util.Util;

using org.skyfire2008.avoider.geom.Point;

enum ShooterState {
	Idling;
	Aiming;
	Firing;
}

class ShooterBehaviour implements Interfaces.UpdateComponent implements Interfaces.DeathComponent {
	private static inline var idleSpeed = 64.0;
	private static inline var rotSpeed = 1.0;
	private static inline var reloadTime = 5.0;
	private static inline var idleTargetRadius = 40;
	private static inline var crosshairSpeed = 320;
	private static inline var a = 64;

	private static var crosshairFactory: EntityFactoryMethod;

	private var state: ShooterState;
	private var pos: Point;
	private var side: Wrapper<Side>;
	private var vel: Point;
	private var time: Float;
	private var moveTargetPos: Point;
	private var shootTargetPos: Point;
	private var shootTargetId: Int;
	private var observingTargets: Bool;

	private var crosshair: Entity;
	private var crosshairPos: Point;

	public static function init() {
		crosshairFactory = Game.instance.entMap.get("shooterCrosshair.json");
	}

	public function new() {
		state = Idling;
		time = 0;
		observingTargets = false;
		crosshairPos = new Point(0, 0);
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
			this.time += time;
			if (this.time > reloadTime && !observingTargets) {
				observingTargets = true;
				TargetingSystem.instance.addTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
			}

			// accelerate if needed
			if (vel.length < idleSpeed) {
				vel.add(vel.scale(1 / vel.length * a));
			}
		} else if (state == Aiming) {
			// if aiming, move the crosshair towards target
			var crosshairVel = shootTargetPos.difference(crosshairPos);
			var dist = crosshairVel.length;

			if (dist <= crosshairSpeed * time) {
				state = Firing;
				crosshairPos.add(crosshairVel);
				this.time = 0;
			} else {
				crosshairVel.mult(1 / dist);
				crosshairVel.mult(crosshairSpeed * time);
				crosshairPos.add(crosshairVel);
			}

			// decelerate if needed
			if (vel.length > 1) {
				var friction = Math.pow(Constants.mju, time * 60);
				vel.mult(friction);
			}
		} else {
			// if firing, delay and shoot
			this.time += time;
			if (this.time >= Constants.reactionTime) {
				var myCol = new Collider(this.owner, pos, 0, new Wrapper(Side.Hostile));

				var colliders = Game.instance.queryLine(pos, crosshairPos);
				for (col in colliders) {
					if (col.owner != this.owner) {
						col.owner.onCollide(myCol);
					}
				}

				// reset state
				this.time = 0;
				state = Idling;
				crosshair.kill();
				crosshair = null;
			}
		}

		// turn towards target
		var angVel = rotSpeed * time;
		Util.turnTo(pos, vel, angVel, moveTargetPos);

		// if close to the target, reset it
		if (moveTargetPos.distance(pos) < ChaserBehaviour.idleTargetRadius) {
			moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
		}
	}

	public function onDeath() {
		if (crosshair != null) {
			crosshair.kill();
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
		shootTargetPos = closest.pos;
		shootTargetId = closest.id;
		observingTargets = false;
		state = Aiming;
		crosshair = crosshairFactory((holder) -> {
			holder.position = crosshairPos;
		});
		crosshairPos.x = pos.x;
		crosshairPos.y = pos.y;
		Game.instance.addEntity(crosshair);

		TargetingSystem.instance.addTargetDeathObserver(shootTargetId, notifyAboutDeath);
	}

	public function notifyAboutDeath() {
		shootTargetPos = null;
		shootTargetId = -1;
		state = Idling;
		time = 0;
	}
}
