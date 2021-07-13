package org.skyfire2008.avoider.game.components;

import haxe.DynamicAccess;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.spatial.Collider;
import org.skyfire2008.avoider.game.Side;

class HasCollider implements Interfaces.InitComponent {
	private var side: Wrapper<Side>;
	private var radius: Float;
	private var pos: Point;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		side = holder.side;
		radius = holder.colliderRadius.value;
		pos = holder.position;
	}

	public function onInit() {
		var collider = new Collider(owner, pos, radius, side, false);
		Game.instance.addCollider(collider);
	}
}

class SpecialHasCollider implements Interfaces.InitComponent implements Interfaces.CollisionComponent {
	private var side: Wrapper<Side>;
	private var radius: Float;
	private var pos: Point;
	private var launcherId: Int;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		side = holder.side;
		radius = holder.colliderRadius.value;
		pos = holder.position;
		launcherId = holder.missileLauncherId.value;
	}

	public function onInit() {
		var collider = new Collider(owner, pos, radius, side, false);
		Game.instance.addCollider(collider);
	}

	public function onCollide(other: Collider) {
		if (other.owner.id == launcherId && side.value == Side.Hostile) {
			MessageSystem.instance.createMessage("with his\nown petard", other.pos, {scale: 4, spacing: 2, color: [1.0, 0.8, 1.0]});
			ScoringSystem.instance.addScore();
		}
	}
}
