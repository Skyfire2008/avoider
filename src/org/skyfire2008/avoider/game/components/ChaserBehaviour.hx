package org.skyfire2008.avoider.game.components;

import howler.Howl;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

import org.skyfire2008.avoider.game.Constants;
import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.game.Spawner;
import org.skyfire2008.avoider.game.components.Interfaces.DeathComponent;
import org.skyfire2008.avoider.game.components.Interfaces.UpdateComponent;
import org.skyfire2008.avoider.game.components.Interfaces.InitComponent;
import org.skyfire2008.avoider.game.TargetingSystem;
import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.graphics.Renderer;
import org.skyfire2008.avoider.graphics.Shape;

using org.skyfire2008.avoider.geom.Point;

interface ChaserState {
	function onUpdate(time: Float): Void;

	function onDeath(): Void;
}

class ChaserIdling implements ChaserState {
	private var parent: ChaserBehaviour;
	private var observingTargets: Bool = false;
	private var targetPos: Point;

	public function new(parent: ChaserBehaviour) {
		this.parent = parent;
		parent.currentShape = ChaserBehaviour.baseShape;
		targetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
	}

	public function onUpdate(time: Float) {
		// if not subscribed to targeting system, subscribe!
		if (!observingTargets) {
			observingTargets = true;
			TargetingSystem.instance.addTargetGroupObserver(parent.baseSide.opposite(), notifyAboutTargets);
		}

		// if too close to target, reset it
		if (targetPos.distance(parent.pos) < ChaserBehaviour.idleTargetRadius) {
			targetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
		}

		// move towards target
		var angVel = ChaserBehaviour.rotSpeed * time;
		Util.turnTo(parent.pos, parent.vel, angVel, targetPos);

		// accelerate if needed
		parent.accelerateIfNeeded(time, ChaserBehaviour.idleSpeed);
	}

	public function onDeath() {
		if (observingTargets) {
			// remove callback on death
			TargetingSystem.instance.removeTargetGroupObserver(parent.baseSide.opposite(), notifyAboutTargets);
		}
	}

	/**
	 * Observer callback method ffor targeting system
	 * @param targets targets in given group
	 */
	public function notifyAboutTargets(targets: Array<{id: Int, pos: Point}>) {
		var closest: {id: Int, pos: Point} = null;
		var closestDist: Float = Math.POSITIVE_INFINITY;

		// go through all possible targets to select the closest one within range
		for (target in targets) {
			var distance = Point.distance(target.pos, parent.pos);
			if (distance <= ChaserBehaviour.detectionRadius && distance < closestDist) {
				closest = target;
				closestDist = distance;
			}
		}

		if (closest != null) {
			TargetingSystem.instance.addTargetDeathObserver(closest.id, onTargetDeath);
			parent.changeState(new ChaserChasing(closest.id, closest.pos, parent, onTargetDeath));
		} else {
			observingTargets = false;
		}
	}

	private function onTargetDeath() {
		parent.changeState(new ChaserIdling(parent));
	}
}

class ChaserChasing implements ChaserState {
	private var targetPos: Point;
	private var targetId: Int;
	private var parent: ChaserBehaviour;
	private var onTargetDeath: () -> Void;

	public function new(targetId: Int, targetPos: Point, parent: ChaserBehaviour, onTargetDeath: () -> Void) {
		parent.currentShape = ChaserBehaviour.chasingShape;
		this.onTargetDeath = onTargetDeath;
		this.targetId = targetId;
		this.targetPos = targetPos;
		this.parent = parent;
	}

	public function onUpdate(time: Float) {
		var distance = Point.distance(targetPos, parent.pos);

		if (distance < ChaserBehaviour.closeAttackRadius) {
			// if target in attack range, start aiming
			parent.changeState(new ChaserAiming(targetId, targetPos, parent, onTargetDeath));
		} else if (distance < ChaserBehaviour.detectionRadius) {
			// if target still in detection range move towards target
			var angVel = ChaserBehaviour.rotSpeed * time;
			Util.turnTo(parent.pos, parent.vel, angVel, targetPos);
		} else {
			// otherwise return to idling state
			TargetingSystem.instance.removeTargetDeathObserver(targetId, onTargetDeath);
			parent.changeState(new ChaserIdling(parent));
		}

		// accelerate if needed
		parent.accelerateIfNeeded(time, ChaserBehaviour.chaseSpeed);
	}

	public function onDeath() {
		TargetingSystem.instance.removeTargetDeathObserver(targetId, onTargetDeath);
	}
}

class ChaserAiming implements ChaserState {
	private var parent: ChaserBehaviour;
	private var targetPos: Point;
	private var targetId: Int;
	private var onTargetDeath: () -> Void;
	private var delay: Float;

	public function new(targetId: Int, targetPos: Point, parent: ChaserBehaviour, onTargetDeath: () -> Void) {
		this.targetId = targetId;
		this.targetPos = targetPos;
		this.parent = parent;
		this.onTargetDeath = onTargetDeath;
		delay = 0;
	}

	public function onUpdate(time: Float) {
		if (parent.vel.length2 > 1) {
			var friction = Math.pow(Constants.mju, time * 60);
			parent.vel.mult(friction);
		}

		if (delay < ChaserBehaviour.armTime) {
			var angVel = ChaserBehaviour.rotSpeed * time;
			Util.turnTo(parent.pos, parent.vel, angVel, targetPos);
			if (Point.distance(targetPos, parent.pos) > ChaserBehaviour.farAttackRadius) {
				parent.changeState(new ChaserChasing(targetId, targetPos, parent, onTargetDeath));
			}

			// check rotations
			var diff = targetPos.difference(parent.pos);
			var cos = Point.dot(parent.vel, diff) / (diff.length * parent.vel.length);
			cos = cos > 1 ? 1 : cos;
			if (Math.acos(cos) < ChaserBehaviour.angleThresh) {
				delay += time;
			} else {
				delay = 0;
			}
		} else if (delay < ChaserBehaviour.armTime + Constants.reactionTime) {
			// change shape and stop rotating
			if (parent.currentShape != ChaserBehaviour.attackingShape) {
				SoundSystem.instance.playSound(ChaserBehaviour.beepSound, parent.pos.x);
				TargetingSystem.instance.removeTargetDeathObserver(targetId, onTargetDeath);
				parent.currentShape = ChaserBehaviour.attackingShape;
			}
			delay += time;
		} else {
			parent.startPos = parent.pos.copy();
			parent.side.value = Side.Hostile;
			parent.changeState(new ChaserAttacking(parent));
			SoundSystem.instance.playSound(ChaserBehaviour.startSound, parent.pos.x, true);
		}
	}

	public function onDeath() {
		TargetingSystem.instance.removeTargetDeathObserver(targetId, onTargetDeath);
	}
}

class ChaserAttacking implements ChaserState {
	private var parent: ChaserBehaviour;
	private var delay: Float;

	public function new(parent: ChaserBehaviour) {
		this.parent = parent;
		delay = 0;
		// accelerate!
		this.parent.vel.normalize();
		this.parent.vel.mult(ChaserBehaviour.attackSpeed);
		parent.trailSpawner.startSpawn();
	}

	public function onUpdate(time: Float) {
		if (delay >= ChaserBehaviour.attackTime) {
			parent.startPos = null;
			parent.side.value = parent.baseSide;
			parent.changeState(new ChaserIdling(parent));
			parent.trailSpawner.stopSpawn();
		}

		parent.trailSpawner.update(time, parent.pos, parent.rotation.value, parent.vel);
		delay += time;
	}

	public function onDeath() {}
}

class ChaserBehaviour implements InitComponent implements UpdateComponent implements DeathComponent {
	public static inline var idleTargetRadius = 40;
	public static inline var detectionRadius = 640;
	public static inline var closeAttackRadius = 360;
	public static inline var farAttackRadius = 480;
	public static inline var a = 160;
	public static inline var idleSpeed = 64;
	public static inline var chaseSpeed = 160;
	public static inline var attackSpeed = 1360;
	public static inline var armTime = 1.0;
	public static inline var attackTime = 0.75;
	public static inline var rotSpeed = 6; // in radians
	public static inline var angleThresh = 0.04;

	public static var baseShape(default, null): Shape;
	public static var chasingShape(default, null): Shape;
	public static var attackingShape(default, null): Shape;
	public static var startSound(default, null): Howl;
	public static var beepSound(default, null): Howl;

	private var state: ChaserState;

	public var startPos: Point;
	public var pos: Point;
	public var vel: Point;
	public var rotation: Wrapper<Float>;
	public var baseSide: Side; // side, that doesn't change(e.g. to hostile when attacking)
	public var side: Wrapper<Side>;
	public var trailSpawner: Spawner;
	private var scale: Wrapper<Float>;

	public var currentShape: Shape;

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
	}

	public static function init() {
		baseShape = Shape.getShape("chaser.json");
		chasingShape = Shape.getShape("chaserChasing.json");
		attackingShape = Shape.getShape("chaserAttacking.json");
		startSound = SoundSystem.instance.getSound("chaserStart.wav");
		beepSound = SoundSystem.instance.getSound("beepNEW.mp3");
	}

	public function changeState(state: ChaserState) {
		this.state = state;
	}

	public function accelerateIfNeeded(time: Float, maxSpeed: Float) {
		var velLength = vel.length;
		if (velLength < maxSpeed) {
			var addVel = vel.scale(1 / velLength * time * a);
			vel.add(addVel);
		} else if (velLength > maxSpeed) {
			var friction = Math.pow(Constants.mju, time * 60);
			vel.mult(friction);
		}
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
		baseSide = holder.side.value;
		side = holder.side;
		scale = holder.scale;
	}

	public function onInit() {
		// init state here, so that targeting system, etc are available
		state = new ChaserIdling(this);
		// init speed
		vel.x += 1;
		// init shape
		currentShape = baseShape;
		trailSpawner.init();
	}

	public function onUpdate(time: Float) {
		state.onUpdate(time);
		Renderer.instance.render(currentShape, pos.x, pos.y, rotation.value, scale.value, [1.0, 1.0, 1.0], 0.2);
	}

	public function onDeath() {
		if (startPos != null && Point.distance(startPos, pos) >= Constants.gameHeight) {
			MessageSystem.instance.createMessage("eagle eye", pos, {color: [0.7, 0.7, 1.0]});
			ScoringSystem.instance.addScore();
			ScoringSystem.instance.addScore();
			ScoringSystem.instance.addScore();
		}
		state.onDeath();
	}
}
