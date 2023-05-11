package org.skyfire2008.avoider.game.components;

import howler.Howl;

import spork.core.JsonLoader.EntityFactoryMethod;
import spork.core.Wrapper;

import org.skyfire2008.avoider.graphics.ColorMult;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.util.StorageLoader;

private enum State {
	Idling;
	Angry;
	Exploding;
}

class BombBehaviour implements Interfaces.InitComponent implements Interfaces.UpdateComponent implements Interfaces.DeathComponent {
	private static inline var detectRadius = 240.0;
	private static inline var angerTime = 2.0;
	private static inline var fragmentSpeed = 360.0;
	private static inline var fragmentRadius = 8.0;
	private static inline var shakeAmount = 12;
	private inline static var speed = 80.0;

	private static var makeFragment: EntityFactoryMethod;
	private static var happyFace: Shape;
	private static var angryFaces: Array<Shape>;
	private static var explodeFace: Shape;
	private static var angerSound: Howl;
	private static var explodeSound: Howl;

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
	@prop
	private var indicatorColorMult: ColorMult;
	@prop
	private var indicatorShape: Wrapper<Shape>;

	public static function init() {
		makeFragment = Game.instance.entMap.get("bombFragment.json");
		happyFace = Shape.getShape("bomb/happyFace.json");
		explodeFace = Shape.getShape("bomb/explodeFace.json");
		angryFaces = [
			Shape.getShape("bomb/angryFaceRight.json"),
			Shape.getShape("bomb/angryFaceRightUp.json"),
			Shape.getShape("bomb/angryFaceUp.json"),
			Shape.getShape("bomb/angryFaceLeftUp.json"),
			Shape.getShape("bomb/angryFaceLeft.json"),
			Shape.getShape("bomb/angryFaceDownLeft.json"),
			Shape.getShape("bomb/angryFaceDown.json"),
			Shape.getShape("bomb/angryFaceDownRight.json")
		];

		angerSound = SoundSystem.instance.getSound("steamedHams.mp3");
		explodeSound = SoundSystem.instance.getSound("bombScream.mp3");
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
		if (state == Angry) {
			state = Idling;
			indicatorShape.value = happyFace;
		}
	}

	public function new() {}

	public function onInit() {
		var newVel = Point.fromPolar(Math.random() * Math.PI * 2, speed);
		vel.set(newVel.x, newVel.y);

		indicatorShape.value = happyFace;
	}

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
						SoundSystem.instance.playSound(angerSound, pos.x, true);
						vel.mult(0.5);
						this.time = 0;
					}
				}
				// TODO: sub to storage loader to change color, potentially use a new component interface
				indicatorColorMult.set(StorageLoader.instance.data.safeColor);
			case Angry:
				// if radius too far, switch to prev state
				var diff = Point.translate(targetPos, Point.scale(pos, -1));
				if (diff.length2 > detectRadius * detectRadius) {
					this.state = Idling;
					indicatorShape.value = happyFace;
					vel.mult(2);
				} else if (time >= angerTime) {
					// otherwise, wait until time runs out and switch to exploding state
					this.state = Exploding;
					SoundSystem.instance.playSound(explodeSound, pos.x, true);
					indicatorShape.value = explodeFace;
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
				} else {
					// otherwise just change faces
					var angle = Math.atan2(-diff.y, diff.x) + 2 * Math.PI;
					var index = Std.int((angle * 4 / Math.PI) + 0.5);
					index = index % 8;
					indicatorShape.value = angryFaces[index];

					// change face color
					indicatorColorMult.setInterpolation(StorageLoader.instance.data.safeColor, StorageLoader.instance.data.warnColor, time / angerTime);
				}

				time += dTime;
			case Exploding:
				if (time >= Constants.reactionTime) {
					owner.kill();
				} else {
					var foo = time / Constants.reactionTime * (shakePositions.length - 1);
					var index = Std.int(foo);
					var mult = foo - index;
					var newPos = Point.lerp(shakePositions[index], shakePositions[index + 1], mult);
					pos.set(newPos.x, newPos.y);
				}
				indicatorColorMult.set(StorageLoader.instance.data.dangerColor);
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
				holder.colliderRadius = new Wrapper(fragmentRadius);
				holder.scale = new Wrapper(fragmentRadius);
				holder.colorMult = [1, 0, 0];
			});
			Game.instance.addEntity(fragment);
		}
	}
}
