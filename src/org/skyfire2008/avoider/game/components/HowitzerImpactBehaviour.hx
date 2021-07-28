package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.spatial.Collider;

class HowitzerImpactBehaviour implements Interfaces.InitComponent implements Interfaces.CollisionComponent implements Interfaces.DeathComponent {
	private var pos: Point;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
	}

	public function onInit() {
		HowitzerSystem.instance.addImpact(this.owner.id);
	}

	public function onCollide(other: Collider) {
		if (other.side.value == Side.Enemy) {
			HowitzerSystem.instance.addTarget(this.owner.id, other.owner.id);
		}
	}

	public function onDeath() {
		var targets = HowitzerSystem.instance.removeImpactCountTargets(this.owner.id);
		if (targets > 2) {
			MessageSystem.instance.createMessage("rain on\ntheir parade", pos, {color: [1.0, 0.7, 0.7]});
			for (i in 0...targets * 2) {
				ScoringSystem.instance.addScore();
			}
		}
	}
}
