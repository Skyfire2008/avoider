package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;

import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.geom.Point;

class Targeted implements Interfaces.InitComponent implements Interfaces.DeathComponent {
	private var side: Side;
	private var pos: Point;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		side = holder.side.value;
	}

	public function onInit() {
		TargetingSystem.instance.addTarget(owner.id, pos, side);
	}

	public function onDeath() {
		TargetingSystem.instance.removeTarget(owner.id, side);
	}
}
