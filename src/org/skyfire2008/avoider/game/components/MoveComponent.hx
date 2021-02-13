package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;
import spork.core.Entity;
import spork.core.PropertyHolder;

import org.skyfire2008.avoider.geom.Point;

class MoveComponent implements Interfaces.UpdateComponent {
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var vel: Point;
	private var angVel: Wrapper<Float>;
	private var owner: Entity;

	public function new() {}

	public function onUpdate(time: Float) {
		pos.add(Point.scale(vel, time));
		rotation.value += angVel.value * time;
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
		angVel = holder.angVel;
	}
}
