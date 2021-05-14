package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Component;
import spork.core.Wrapper;

import org.skyfire2008.avoider.geom.Point;

class SpawnsOnUpdate implements Interfaces.UpdateComponent implements Interfaces.InitComponent {
	private var spawner: Spawner;
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var vel: Point;

	public function new(spawner: Spawner) {
		this.spawner = spawner;
	}

	public static function fromJson(json: Dynamic): Component {
		return new SpawnsOnUpdate(new Spawner(json));
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
	}

	public function onInit() {
		spawner.init();
		spawner.startSpawn();
	}

	public function onUpdate(time: Float) {
		spawner.update(time, pos, rotation.value, vel);
	}

	public function clone() {
		return new SpawnsOnUpdate(spawner.clone());
	}
}
