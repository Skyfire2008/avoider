package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;
import spork.core.PropertyHolder;
import spork.core.Entity;
import spork.core.Component;

import org.skyfire2008.avoider.geom.Point;

class SpawnsPhantomOnDeath implements Interfaces.DeathComponent {
	private var pos: Point;
	private var radius: Float;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		radius = holder.colliderRadius.value;
	}

	public function onDeath() {
		var ent = new Entity("phantom");
		var holder = new PropertyHolder();
		holder.position = pos.copy();
		holder.colliderRadius = new Wrapper(radius);
		holder.side = new Wrapper(Side.Player);
		holder.timeToLive = new Wrapper(0.2);

		var compos: Array<Component> = [];
		compos.push(new Timed());
		compos.push(new HasCollider());
		for (compo in compos) {
			compo.createProps(holder);
		}
		for (compo in compos) {
			compo.assignProps(holder);
			compo.attach(ent);
		}

		Game.instance.addEntity(ent);
	}
}
