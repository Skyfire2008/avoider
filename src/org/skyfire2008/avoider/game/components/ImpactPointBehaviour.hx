package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;

import org.skyfire2008.avoider.spatial.Collider;
import org.skyfire2008.avoider.geom.Point;

import spork.core.PropertyHolder;
import spork.core.JsonLoader.EntityFactoryMethod;

class ImpactPointBehaviour implements Interfaces.DeathComponent {
	private var launcherId: Int;
	private var pos: Point;

	private static var createImpact: EntityFactoryMethod;

	public static function init() {
		createImpact = Game.instance.entMap.get("howitzerImpact.json");
	}

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		launcherId = holder.missileLauncherId.value;
		pos = holder.position;
	}

	public function onDeath() {
		var impact = createImpact((holder) -> {
			holder.position = pos;
			holder.missileLauncherId = new Wrapper(launcherId);
		});
		Game.instance.addEntity(impact);
	}
}
