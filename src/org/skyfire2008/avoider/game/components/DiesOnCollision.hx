package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;
import spork.core.PropertyHolder;

import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.spatial.Collider;

class DiesOnCollision implements Interfaces.CollisionComponent {
	private var side: Wrapper<Side>;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		side = holder.side;
	}

	public function onCollide(other: Collider) {
		if (this.side.value == Side.Hostile) {
			owner.kill();
		} else if (this.side.value != other.side.value) {
			owner.kill();
		}
	}
}
