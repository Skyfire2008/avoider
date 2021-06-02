package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.game.components.Interfaces.InitComponent;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.graphics.Renderer;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

using org.skyfire2008.avoider.geom.Point;

enum MissileState {
	Arming;
	Chasing;
	Dying;
}

class MissileBehaviour implements InitComponent implements Interfaces.UpdateComponent {
	private static inline var armTime = 1.0;
	private static inline var flyTime = 10.0;
	private static inline var dieTime = 1.0;
	private static inline var speed = 400.0;
	private static inline var a = 200.0;
	private static inline var angVel = 6.0;

	private static var baseShape: Shape;
	private static var dyingShape: Shape;

	private var time = 0.0;
	private var state: MissileState;

	private var pos: Point;
	private var vel: Point;
	private var rotation: Wrapper<Float>;
	private var side: Wrapper<Side>;
	private var scale: Wrapper<Float>;
	private var originalSide: Side;
	private var trailSpawner: Spawner;
	private var targetPos: Point;
	public var currentShape: Shape;

	public static function init() {
		baseShape = Shape.getShape("missile.json");
		dyingShape = Shape.getShape("missileRed.json");
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
		currentShape = baseShape;
		state = Arming;
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
		side = holder.side;
		scale = holder.scale;

		originalSide = side.value;
		targetPos = holder.missileTargetPos;
	}

	public function onInit() {
		trailSpawner.init();
	}

	public function onUpdate(dTime: Float) {
		switch (state) {
			case Arming:
				if (time > armTime) {
					time -= armTime;
					side.value = Side.Hostile;
					state = Chasing;
					trailSpawner.startSpawn();
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
					currentShape = dyingShape;
					state = Dying;
				}
			case Dying:
				if (time < dieTime) {
					// accelerate if needed
					var velLength = vel.length;
					if (velLength < speed) {
						vel.add(vel.scale(1 / velLength * a));
					} else if (velLength > speed) {
						vel.mult(speed / velLength);
					}

					// turn towards target
					Util.turnTo(pos, vel, angVel * dTime, targetPos);

					// spawn particles
					trailSpawner.update(dTime, pos, rotation.value, vel);
				} else {
					this.owner.kill();
				}
		}

		time += dTime;

		// render the shape
		Renderer.instance.render(currentShape, pos.x, pos.y, rotation.value, scale.value, [1, 1, 1], 0.2);
	}
}
