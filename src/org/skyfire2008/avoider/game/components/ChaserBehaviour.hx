package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

import org.skyfire2008.avoider.game.Constants;
import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.game.components.Interfaces.DeathComponent;
import org.skyfire2008.avoider.game.components.Interfaces.CollisionComponent;
import org.skyfire2008.avoider.game.components.Interfaces.UpdateComponent;
import org.skyfire2008.avoider.game.components.Interfaces.InitComponent;
import org.skyfire2008.avoider.game.TargetingSystem;
import org.skyfire2008.avoider.spatial.Collider;
import org.skyfire2008.avoider.util.Util;

using org.skyfire2008.avoider.geom.Point;

/*enum State {
	Idling;
	Chasing;
	Attacking;
}*/
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
		targetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
	}

	public function onUpdate(time: Float) {
		// if not subscribed to targeting system, subscribe!
		if (!observingTargets) {
			observingTargets = true;
			TargetingSystem.instance.addTargetGroupObserver(parent.baseSide.value.opposite(), notifyAboutTargets);
		}

		// if too close to target, reset it
		if (targetPos.distance(parent.pos) < ChaserBehaviour.idleTargetRadius) {
			targetPos = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
		}

		// move towards target
		var angVel = ChaserBehaviour.rotSpeed * time;
		Util.turnTo(parent.pos, parent.vel, angVel, targetPos);

		// accelerate if needed
		parent.accelerateIfNeeded(time);
	}

	public function onDeath() {
		if (observingTargets) {
			// remove callback on death
			TargetingSystem.instance.removeTargetGroupObserver(parent.baseSide.value.opposite(), notifyAboutTargets);
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
			parent.changeState(new ChaserChasing(closest.id, closest.pos, parent));
		} else {
			observingTargets = false;
		}
	}
}

class ChaserChasing implements ChaserState {
	private var targetPos: Point;
	private var targetId: Int;
	private var parent: ChaserBehaviour;

	public function new(targetId: Int, targetPos: Point, parent: ChaserBehaviour) {
		TargetingSystem.instance.addTargetDeathObserver(targetId, onTargetDeath);
		this.targetId = targetId;
		this.targetPos = targetPos;
		this.parent = parent;
	}

	public function onUpdate(time: Float) {
		// if target still in detection range...
		if (Point.distance(targetPos, parent.pos) < ChaserBehaviour.detectionRadius) {
			// move towards target
			var angVel = ChaserBehaviour.rotSpeed * time;
			Util.turnTo(parent.pos, parent.vel, angVel, targetPos);
		} else {
			// otherwise return to idling state
			parent.changeState(new ChaserIdling(parent));
		}

		// accelerate if needed
		parent.accelerateIfNeeded(time);
	}

	public function onDeath() {
		TargetingSystem.instance.removeTargetDeathObserver(targetId, onTargetDeath);
	}

	private function onTargetDeath() {
		parent.changeState(new ChaserIdling(parent));
	}
}

class ChaserBehaviour implements InitComponent implements UpdateComponent implements CollisionComponent implements DeathComponent {
	public static inline var idleTargetRadius = 40;
	public static inline var detectionRadius = 560;
	public static inline var attackRadius = 280;
	public static inline var a = 256;
	public static inline var idleSpeed = 160;
	public static inline var attackSpeed = 1024;
	public static inline var rotSpeed = 4; // in radians
	public static inline var maxDeviation = 0.15; // in radians

	private var state: ChaserState;

	public var pos: Point;
	public var vel: Point;
	public var rotation: Wrapper<Float>;
	public var baseSide: Wrapper<Side>; // side, that doesn't change(e.g. to hostile when attacking)

	public function new() {}

	public function changeState(state: ChaserState) {
		this.state = state;
	}

	public function accelerateIfNeeded(time: Float) {
		var velLength = vel.length;
		if (velLength < idleSpeed) {
			var addVel = vel.scale(1 / velLength * time * a);
			vel.add(addVel);
		}
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
		baseSide = holder.side;
	}

	public function onInit() {
		// init state here, so that targeting system, etc are available
		state = new ChaserIdling(this);
		// init speed
		vel.x += 1;
	}

	public function onUpdate(time: Float) {
		state.onUpdate(time);
	}

	public function onCollide(other: Collider) {
		owner.kill();
	}

	public function onDeath() {
		state.onDeath();
	}
}
