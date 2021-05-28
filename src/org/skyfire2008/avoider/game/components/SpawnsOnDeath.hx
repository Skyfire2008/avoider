package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;
import spork.core.Component;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.game.Spawner;
import org.skyfire2008.avoider.geom.Point;

class SpawnsOnDeath implements Interfaces.DeathComponent implements Interfaces.InitComponent {
	private var spawner: Spawner;
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var vel: Point;

	public static function fromJson(json: Dynamic): Component {
		return new SpawnsOnDeath(new Spawner(json));
	}

	public function new(spawner: Spawner) {
		this.spawner = spawner;
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
	}

	public function clone(): Component {
		return new SpawnsOnDeath(spawner.clone());
	}

	public function onDeath() {
		spawner.spawn(pos, rotation.value, vel);
	}

	public function onInit() {
		spawner.init();
	}
}

class WarningBehaviour implements Interfaces.DeathComponent {
	private var func: EntityFactoryMethod;
	private var pos: Point;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		func = holder.warningFunc;
		pos = holder.position;
	}

	public function onDeath() {
		Game.instance.addEntity(func((holder) -> {
			holder.position = pos;
		}));
	}
}
