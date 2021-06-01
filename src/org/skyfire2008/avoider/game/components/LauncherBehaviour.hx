package org.skyfire2008.avoider.game.components;

import spork.core.Entity;
import spork.core.PropertyHolder;
import spork.core.Wrapper;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.util.Util;

using org.skyfire2008.avoider.geom.Point;

enum LauncherState {
	Idling;
	Chasing;
	Firing;
}

class LauncherBehaviour implements Interfaces.UpdateComponent implements Interfaces.DeathComponent {
	private static inline var idleSpeed = 32.0;
	private static inline var chaseSpeed = 160.0;
	private static inline var a = 40.0;
	private static inline var rotSpeed = 3.0;
	private static inline var reloadTime = 5.0;
	private static inline var idleTargetRadius = 40;
	private static inline var chaseTargetRadius = 240.0;

	private static var createMissileProp: EntityFactoryMethod;
	private static var createMissile: EntityFactoryMethod;

	private var state: LauncherState;
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var side: Wrapper<Side>;
	private var vel: Point;
	private var time: Float;
	private var moveTargetPos: Point;
	private var shootTargetPos: Point;
	private var shootTargetId: Int;
	private var observingTargets: Bool;

	private var missileProp: Entity;

	public static function init() {
		// createMissileProp = Game.instance.entMap.get("missileProp.json");
		createMissile = Game.instance.entMap.get("missile.json");
	}

	public function new() {
		state = Idling;
		time = -Math.random() * reloadTime;
		observingTargets = false;
		moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		rotation = holder.rotation;
		vel = holder.velocity;
		vel.x = idleSpeed;
		side = holder.side;
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
		state = Chasing;
		shootTargetPos = closest.pos;
		shootTargetId = closest.id;
		observingTargets = false;

		TargetingSystem.instance.addTargetDeathObserver(shootTargetId, notifyAboutDeath);
	}

	public function notifyAboutDeath() {
		observingTargets = true;
		TargetingSystem.instance.addTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
		state = Idling;
		time = 0;
	}

	public function onUpdate(dTime: Float) {
		switch (state) {
			case Idling:
				// if reached target, select new one
				if (moveTargetPos.difference(pos).length <= idleTargetRadius) {
					moveTargetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
				}

				// turn towards target
				Util.turnTo(pos, vel, rotSpeed * dTime, moveTargetPos);

				// accelerate/decelerate if needed
				Util.accelIfNeeded(vel, idleSpeed, a, dTime);

				// if reloaded, request target
				if (time > reloadTime) {
					observingTargets = true;
					TargetingSystem.instance.addTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
				}

			case Chasing:
				// if reached target, fire missile and change state
				if (shootTargetPos.difference(pos).length <= chaseTargetRadius) {
					TargetingSystem.instance.removeTargetDeathObserver(shootTargetId, notifyAboutDeath);
					var missile = createMissile((holder) -> {
						holder.position = pos.copy();
						holder.velocity = vel.copy();
						holder.side = new Wrapper(side.value);
						holder.missileTargetPos = shootTargetPos;
					});
					Game.instance.addEntity(missile);

					time = 0;
					state = Idling;
				}

				// turn toward target
				Util.turnTo(pos, vel, rotSpeed * dTime, shootTargetPos);

				// accelerate/decelerate
				Util.accelIfNeeded(vel, chaseSpeed, a, dTime);
			case Firing:
		}

		time += dTime;
	}

	public function onDeath() {}
}
