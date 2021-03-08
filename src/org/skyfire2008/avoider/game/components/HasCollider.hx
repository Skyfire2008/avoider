package org.skyfire2008.avoider.game.components;

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
