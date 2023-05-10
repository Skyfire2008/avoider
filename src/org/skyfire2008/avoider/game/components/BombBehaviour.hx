package org.skyfire2008.avoider.game.components;

import spork.core.JsonLoader.EntityFactoryMethod;
import spork.core.Wrapper;

import org.skyfire2008.avoider.graphics.ColorMult;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.util.StorageLoader;

private enum State {
	Idling;
	Angry;
	Exploding;
}

class BombBehaviour implements Interfaces.InitComponent implements Interfaces.UpdateComponent implements Interfaces.DeathComponent {
	private static inline var detectRadius = 360.0;
	private static inline var angerTime = 1.0;
	private static inline var explodeTime = 0.5;
	private static inline var fragmentSpeed = 480.0;
	private static inline var fragmentRadius = 5.0;
	private static inline var shakeAmount = 10;
	private static var makeFragment: EntityFactoryMethod;

	private var time: Float;
	private var state = Idling;
	private var observing = false;
	private var targetPos: Point = null;
	private var targetId: Int = -1;
	private var shakePositions: Array<Point>;

	@prop
	private var side: Wrapper<Side>;
	@prop("position")
	private var pos: Point;
	@prop("velocity")
	private var vel: Point;
	@prop
	private var colorMult: ColorMult;
	@prop
	private var colliderRadius: Wrapper<Float>;

	public static function init() {
		makeFragment = Game.instance.entMap.get("bombFragment.json");
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
		targetPos = closest.pos;
		targetId = closest.id;
		observing = false;

		TargetingSystem.instance.addTargetDeathObserver(targetId, notifyAboutDeath);
	}

	private function notifyAboutDeath() {
		targetPos = null;
		targetId = -1;
		state = Idling;
	}

	public function new() {}

	public function onInit() {}

	public function onUpdate(dTime: Float) {
		switch (state) {
			case Idling:
				// if not watching targets and no target found, start watching!
				if (!observing && targetPos == null) {
					observing = true;
					TargetingSystem.instance.addTargetGroupObserver(side.value.opposite(), notifyAboutTargets);
				} else if (targetPos != null) {
					// if target found, check radius, switch to next state if needed
					if (Point.distance(pos, targetPos) <= detectRadius) {
						this.state = Angry;
						this.time = 0;
					}
				}
			case Angry:
				// if radius too far, switch to prev state
				if (Point.distance(pos, targetPos) > detectRadius) {
					this.state = Idling;
				} else if (time >= angerTime) { // otherwise, wait until
					this.state = Exploding;
					shakePositions = [];
					shakePositions.push(pos.copy());
					for (i in 0...shakeAmount) {
						var disp = new Point(Math.random() * colliderRadius.value, Math.random() * colliderRadius.value);
						disp.add(pos);
						shakePositions.push(disp);
					}
					shakePositions.push(pos.copy());
					vel.set(0, 0);
					this.time = 0;
				}
				time += dTime;
			case Exploding:
				if (time >= explodeTime) {
					owner.kill();
				} else {
					var foo = time / explodeTime * (shakePositions.length - 1);
					var index = Std.int(foo);
					var mult = foo - index;
					var newPos = Point.lerp(shakePositions[index], shakePositions[index + 1], mult);
					pos.set(newPos.x, newPos.y);
				}
				time += dTime;
		}
	}

	public function onDeath() {
		var radius = colliderRadius.value + fragmentRadius;
		for (i in 0...8) {
			var angle = i / 4 * Math.PI;
			var fragment = makeFragment((holder) -> {
				holder.position = Point.fromPolar(angle, radius);
				holder.position.add(pos);
				holder.velocity = Point.fromPolar(angle, fragmentSpeed);
				holder.rotation = new Wrapper(angle);
				holder.scale = new Wrapper(1.0);
				holder.colorMult = [1, 0, 0];
			});
			Game.instance.addEntity(fragment);
		}
	}
}
