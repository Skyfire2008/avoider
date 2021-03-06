package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

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
}

class ChaserIdling implements ChaserState {
	private var parent: ChaserBehaviour;
	private var observingTargets: Bool;

	public function new(parent: ChaserBehaviour) {
		this.parent = parent;
		TargetingSystem.instance.addTargetGroupObserver(parent.baseSide.value.opposite(), notifyAboutTargets);
		observingTargets = true;
	}

	public function onUpdate(time: Float) {
		if (!observingTargets) {
			TargetingSystem.instance.addTargetGroupObserver(parent.baseSide.value.opposite(), notifyAboutTargets);
			observingTargets = true;
		}
	}

	public function notifyAboutTargets(targets: Array<{id: Int, pos: Point}>) {
		var closest: {id: Int, pos: Point} = null;
		var closestDist: Float = Math.POSITIVE_INFINITY;

		for (target in targets) {
			var distance = Point.distance(target.pos, parent.pos);
			if (distance <= ChaserBehaviour.detectionRadius && distance < closestDist) {
				closest = target;
				closestDist = distance;
			}
		}

		if (closest != null) {} else {
			observingTargets = false;
		}
	}
}

class ChaserChasing implements ChaserState {
	private var targetPos: Point;
	private var parent: ChaserBehaviour;

	public function new(targetPos: Point, parent: ChaserBehaviour) {
		this.targetPos = targetPos;
		this.parent = parent;
	}

	public function onUpdate(time: Float) {
		if (Point.distance(targetPos, parent.pos) < ChaserBehaviour.detectionRadius) {
			var angVel = ChaserBehaviour.rotSpeed * time;
			Util.turnTo(parent.pos, parent.vel, parent.rotation, angVel, targetPos);
		} else {
			// return to idling state
			parent.state = new ChaserIdling(parent);
		}
	}
}

class ChaserBehaviour implements InitComponent implements UpdateComponent implements CollisionComponent implements DeathComponent {
	public static inline var detectionRadius = 720;
	public static inline var attackRadius = 400;
	public static inline var a = 256;
	public static inline var idleSpeed = 256;
	public static inline var attackSpeed = 1024;
	public static inline var rotSpeed = 2; // in radians
	public static inline var maxDeviation = 0.15; // in radians

	public var state: ChaserState;

	public var pos: Point;
	public var vel: Point;
	public var rotation: Wrapper<Float>;
	public var baseSide: Wrapper<Side>; // side, that doesn't change(e.g. to hostile when attacking)

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
		baseSide = holder.side;
	}

	public function onInit() {}

	public function onUpdate(time: Float) {
		/*switch (state) {
			case Idling:
			case Chasing:
			case Attacking:
		}*/
	}

	public function onCollide(other: Collider) {}

	public function onDeath() {}
}
