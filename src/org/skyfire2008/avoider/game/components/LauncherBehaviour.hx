package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.graphics.ColorMult;

import howler.Howl;

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

class LauncherBehaviour implements Interfaces.InitComponent implements Interfaces.UpdateComponent implements Interfaces.DeathComponent {
	private static inline var idleSpeed = 32.0;
	private static inline var chaseSpeed = 160.0;
	private static inline var a = 160.0;
	private static inline var rotSpeed = 2.5;
	private static inline var reloadTime = 5.0;
	private static inline var halfTime = 2.5;
	private static inline var runAwayTime = 1.5;
	private static inline var idleTargetRadius = 40;
	private static inline var chaseTargetRadius = 160.0;

	private static var createMissileProp: EntityFactoryMethod;
	private static var createMissile: EntityFactoryMethod;
	private static var createIndicator: EntityFactoryMethod;
	private static var shootSound: Howl;

	private var state: LauncherState;
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var side: Wrapper<Side>;
	private var vel: Point;
	private var time: Float;
	private var moveTargetPos: Point;
	private var shootTargetPos: Point;
	private var shootTargetId: Int = -1;
	private var observingTargets: Bool;
	private var runDir: Point;
	private var indicMult: ColorMult;

	private var indicator: Entity;
	private var missileProp: Entity = null;

	public static function init() {
		createMissileProp = Game.instance.entMap.get("missileProp.json");
		createMissile = Game.instance.entMap.get("missile.json");
		createIndicator = Game.instance.entMap.get("launcherIndicator.json");
		shootSound = SoundSystem.instance.getSound("launcherShoot.wav");
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
		indicMult.set([1, 0, 0]);
		shootTargetPos = closest.pos;
		shootTargetId = closest.id;
		observingTargets = false;
		if (missileProp == null) {
			missileProp = createMissileProp((holder) -> {
				holder.position = pos;
				holder.rotation = rotation;
			});
			Game.instance.addEntity(missileProp);
		}

		TargetingSystem.instance.addTargetDeathObserver(shootTargetId, notifyAboutDeath);
	}

	public function notifyAboutDeath() {
		observingTargets = true;
		TargetingSystem.instance.addTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
		state = Idling;
		time = 0;
	}

	public function onInit() {
		indicMult = [0, 1.0, 0];
		indicator = createIndicator((holder) -> {
			holder.position = pos;
			holder.rotation = rotation;
			holder.colorMult = indicMult;
		});
		Game.instance.addEntity(indicator);
	}

	public function onUpdate(dTime: Float) {
		switch (state) {
			case Idling:
				// set indicator color mult
				if (time < halfTime) {
					indicMult.set([time / halfTime, 1.0, 0]);
				} else {
					indicMult.set([1.0, (reloadTime - time) / halfTime, 0]);
				}

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
						holder.missileLauncherId = new Wrapper(this.owner.id);
						holder.missileTargetPos = shootTargetPos;
					});
					shootTargetId = -1;
					missileProp.kill();
					missileProp = null;
					Game.instance.addEntity(missile);
					shootSound.play();

					time = 0;
					state = Firing;
					runDir = vel.scale(-1);
					indicMult.set([0, 1.0, 0]);
				}

				// turn toward target
				Util.turnTo(pos, vel, rotSpeed * dTime, shootTargetPos);

				// accelerate/decelerate
				Util.accelIfNeeded(vel, chaseSpeed, a, dTime);
			case Firing:
				if (time < runAwayTime) {
					// turn toward target
					Util.turnTo(pos, vel, rotSpeed * dTime, pos.translate(runDir));

					// accelerate/decelerate
					Util.accelIfNeeded(vel, chaseSpeed, a, dTime);
				} else {
					state = Idling;
					time = 0;
				}
		}

		time += dTime;
	}

	public function onDeath() {
		if (state == Chasing) {
			MessageSystem.instance.createMessage("dangerous\ncargo", pos, {color: [1, 1, 0.8]});
			ScoringSystem.instance.addScore();
			ScoringSystem.instance.addScore();
		}

		indicator.kill();

		if (shootTargetId != -1) {
			TargetingSystem.instance.removeTargetDeathObserver(shootTargetId, notifyAboutDeath);
		}

		if (observingTargets) {
			TargetingSystem.instance.removeTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
		}

		if (missileProp != null) {
			missileProp.kill();
		}
	}
}
