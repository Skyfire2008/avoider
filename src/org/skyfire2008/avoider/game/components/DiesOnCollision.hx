package org.skyfire2008.avoider.game.components;

import spork.core.Entity;
import spork.core.Wrapper;
import spork.core.PropertyHolder;

import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.spatial.Collider;

class DiesOnCollision implements Interfaces.CollisionComponent {
	private var side: Wrapper<Side>;
	private var lastCollidedWith: Wrapper<Entity>;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		side = holder.side;
		lastCollidedWith = holder.lastCollidedWith;
	}

	public function onCollide(other: Collider) {
		if (this.side.value == Side.Hostile) {
			owner.kill();
			lastCollidedWith.value = other.owner;
		} else if (this.side.value != other.side.value) {
			owner.kill();
			lastCollidedWith.value = other.owner;
		}
	}
}
