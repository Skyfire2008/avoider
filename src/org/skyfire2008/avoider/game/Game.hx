package org.skyfire2008.avoider.game;

import haxe.ds.StringMap;

import spork.core.Entity;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.graphics.Renderer;

class Game {
	public static var instance(default, null): Game;
	public var entMap(default, null): StringMap<EntityFactoryMethod>;

	private var entities: Array<Entity>;

	public static function setInstance(instance: Game) {
		Game.instance = instance;
	}

	public function new(entMap: StringMap<EntityFactoryMethod>) {
		entities = [];
		this.entMap = entMap;
	}

	public function addEntity(entity: Entity, addToFront: Bool = false) {
		entity.onInit();
		if (addToFront) {
			entities.unshift(entity);
		} else {
			entities.push(entity);
		}
	}

	public function update(time: Float) {
		Renderer.instance.clear();

		for (ent in entities) {
			ent.onUpdate(time);
		}

		// remove dead entities
		var newEntities: Array<Entity> = [];
		for (entity in entities) {
			if (entity.isAlive()) {
				newEntities.push(entity);
			} else {
				entity.onDeath();
			}
		}
		entities = newEntities;
	}
}
