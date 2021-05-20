package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Entity;
import spork.core.JsonLoader.EntityFactoryMethod;
import spork.core.Wrapper;

import org.skyfire2008.avoider.util.Util;

using org.skyfire2008.avoider.geom.Point;

enum State {
	Idling;
	Aiming;
	Firing;
}

class HowitzerBehaviour implements Interfaces.UpdateComponent implements Interfaces.InitComponent implements Interfaces.DeathComponent {
	private static inline var idleSpeed = 32.0;
	private static inline var rotSpeed = 1.0;
	private static inline var reloadTime = 5.0;
	private static inline var crosshairTol = 30.0;
	private static inline var crosshairSpeed = 640.0;
	private static inline var crosshairA = 1280.0;
	private static inline var shotSpeed = 1280.0;
	private static inline var idleTargetR = 40;
	private static inline var a = 16;

	private static var createCrosshair: EntityFactoryMethod;
	private static var createImpact: EntityFactoryMethod;
	private static var createCircle: EntityFactoryMethod;

	private var side: Wrapper<Side>;
	private var state: State;
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var vel: Point;
	private var time: Float;
	private var moveTargetPos: Point;
	private var shootTargetPos: Point;
	private var shootTargetId: Int;
	private var observingTargets: Bool;
	private var crosshair: Entity;
	private var crosshairPos: Point;
	private var crosshairVel: Point;

	public static function init() {
		createCrosshair = Game.instance.entMap.get("shooterCrosshair.json");
		createImpact = Game.instance.entMap.get("impactPoint.json");
		createCircle = Game.instance.entMap.get("howitzerCircle.json");
	}

	public function new() {
		time = -Math.random() * reloadTime;
		state = Idling;
		observingTargets = false;
		moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
		crosshairPos = new Point(0, 0);
	}

	private function notifyAboutTargets(targets: Array<{id: Int, pos: Point}>) {
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
		crosshair = createCrosshair((holder) -> {
			holder.position = crosshairPos;
		});
		crosshairPos.x = pos.x;
		crosshairPos.y = pos.y;
		var dir = shootTargetPos.difference(pos);
		dir.normalize();
		dir.mult(crosshairSpeed);
		crosshairVel = dir;
		crosshairPos.add(vel);
		Game.instance.addEntity(crosshair);

		TargetingSystem.instance.addTargetDeathObserver(shootTargetId, notifyAboutDeath);
	}

	private function notifyAboutDeath() {
		shootTargetPos = null;
		shootTargetId = -1;
		state = Idling;
		time = 0;
		if (crosshair != null) {
			crosshair.kill();
			crosshair = null;
		}
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		rotation = holder.rotation;
		vel = holder.velocity;
		vel.x = idleSpeed;
		side = holder.side;
	}

	public function onInit() {}

	public function onUpdate(dTime: Float) {
		if (state == Idling) {
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
			var dir = shootTargetPos.difference(crosshairPos);
			var dirLength = dir.length;

			if (dirLength <= Math.max(crosshairVel.length * dTime, crosshairTol)) {
				// reached the target, spawn impact point
				var entPos = crosshairPos.copy();
				var entTtl = Constants.reactionTime + pos.difference(entPos).length / shotSpeed;
				var impact = createImpact((holder) -> {
					holder.position = entPos;
					holder.timeToLive = new Wrapper(entTtl);
				});
				Game.instance.addEntity(impact);
				// also spawn circle signifying impact time
				var circle = createCircle((holder) -> {
					holder.position = entPos;
					holder.timeToLive = new Wrapper(entTtl);
				});
				Game.instance.addEntity(circle);

				state = Idling;
				time = 0;
				crosshair.kill();
				crosshair = null;
			} else {
				// not reached, move crosshair
				dir.mult(dTime * crosshairA / dirLength);
				crosshairVel.mult(Math.pow(Constants.mju, dTime * 60));
				crosshairVel.add(dir);
				crosshairPos.add(crosshairVel.scale(dTime));

				// rotate howitzer
				Util.turnTo(pos, vel, Math.PI * 2, crosshairPos);
			}

			// decelerate if needed
			if (vel.length > 1) {
				var friction = Math.pow(Constants.mju, dTime * 60);
				vel.mult(friction);
			}
		}

		// turn towards target
		var angVel = rotSpeed * dTime;
		Util.turnTo(pos, vel, angVel, moveTargetPos);

		// if close to the target, reset it
		if (moveTargetPos.distance(pos) < ChaserBehaviour.idleTargetRadius) {
			moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
		}

		time += dTime;
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
}