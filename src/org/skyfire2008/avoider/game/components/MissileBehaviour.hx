package org.skyfire2008.avoider.game.components;

import howler.Howl;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

import org.skyfire2008.avoider.util.StorageLoader;
import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.game.components.Interfaces.InitComponent;
import org.skyfire2008.avoider.graphics.ColorMult;

using org.skyfire2008.avoider.geom.Point;

enum MissileState {
	Arming;
	Chasing;
	Dying;
}

class MissileBehaviour implements InitComponent implements Interfaces.UpdateComponent {
	private static inline var armTime = 1.0;
	private static inline var flyTime = 5.0;
	private static inline var dieTime = 1.0;
	private static inline var speed = 400.0;
	private static inline var a = 300.0;
	private static inline var angVel = 6.0;
	private static inline var blinks = 10.0;

	private static var startSound: Howl;

	private var time = 0.0;
	private var state: MissileState;
	private var originalSide: Side;
	private var trailSpawner: Spawner;

	@prop("missileTargetPos")
	private var targetPos: Point;
	@prop("position")
	private var pos: Point;
	@prop("velocity")
	private var vel: Point;
	@prop("missileLauncherId")
	private var launcherId: Wrapper<Int>;
	@prop
	private var rotation: Wrapper<Float>;
	@prop
	private var side: Wrapper<Side>;
	@prop("indicatorColorMult")
	private var indicMult: ColorMult;

	public static function init() {
		startSound = SoundSystem.instance.getSound("chaserStart.wav");
	}

	public function new() {
		trailSpawner = new Spawner({
			entityName: "trail.json",
			spawnTime: 0.016,
			spawnVel: 20,
			velRand: 10,
			spawnNum: 3,
			relVelMult: 0,
			spreadAngle: 2.09,
			angleRand: 1.045
		});
		state = Arming;
	}

	public function onInit() {
		trailSpawner.init();
		originalSide = side.value;
	}

	public function onUpdate(dTime: Float) {
		switch (state) {
			case Arming:
				if (time > armTime) {
					time -= armTime;
					side.value = Side.Hostile;
					state = Chasing;
					trailSpawner.startSpawn();
					indicMult.set(StorageLoader.instance.data.dangerColor);
					SoundSystem.instance.playSound(startSound, pos.x, true);
				}
			case Chasing:
				if (time <= flyTime) {
					// accelerate if needed
					Util.accelIfNeeded(vel, speed, a, dTime);

					// turn towards target
					Util.turnTo(pos, vel, angVel * dTime, targetPos);

					// spawn particles
					trailSpawner.update(dTime, pos, rotation.value, vel);
				} else {
					time -= flyTime;
					state = Dying;
				}
			case Dying:
				if (time < dieTime) {
					// accelerate if needed
					Util.accelIfNeeded(vel, speed, a, dTime);
					// turn towards target
					Util.turnTo(pos, vel, angVel * dTime, targetPos);
					// spawn particles
					trailSpawner.update(dTime, pos, rotation.value, vel);
					// blink
					var num = Std.int(time * blinks / dieTime) % 2;
					if (num == 0) {
						indicMult.set(StorageLoader.instance.data.dangerColor);
					} else {
						indicMult.set(StorageLoader.instance.data.warnColor);
					}
				} else {
					this.owner.kill();
				}
		}

		time += dTime;
	}
}
