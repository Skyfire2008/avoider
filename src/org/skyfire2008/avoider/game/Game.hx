package org.skyfire2008.avoider.game;

import haxe.ds.StringMap;

import spork.core.Entity;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.graphics.Renderer;
import org.skyfire2008.avoider.spatial.UniformGrid;
import org.skyfire2008.avoider.spatial.Collider;
import org.skyfire2008.avoider.game.components.ChaserBehaviour;

class Game {
	public static var instance(default, null): Game;
	public var entMap(default, null): StringMap<EntityFactoryMethod>;

	private var entities: Array<Entity>;
	private var grid: UniformGrid;
	private var colliders: Array<Collider>;

	public static function setInstance(instance: Game) {
		Game.instance = instance;
	}

	public function new(entMap: StringMap<EntityFactoryMethod>) {
		entities = [];
		this.entMap = entMap;
		grid = new UniformGrid(10, 10, Std.int(Constants.gameWidth / 10), Std.int(Constants.gameHeight / 10));
		colliders = [];
	}

	public function addEntity(entity: Entity, addToFront: Bool = false) {
		entity.onInit();
		if (addToFront) {
			entities.unshift(entity);
		} else {
			entities.push(entity);
		}
	}

	public function addCollider(collider: Collider) {
		colliders.push(collider);
	}

	public function update(time: Float) {
		Renderer.instance.clear();

		// update entities
		for (ent in entities) {
			ent.onUpdate(time);
		}

		// detect collisions
		grid.reset();
		for (col in colliders) {
			var query = grid.queryRect(col.rect());
			for (other in query) {
				if (col.intersects(other)) {
					// only call onCollide if collides with pysical object
					if (!other.ephemeral) {
						col.owner.onCollide(other);
					}
					if (!col.ephemeral) {
						other.owner.onCollide(col);
					}
				}
			}

			grid.add(col);
		}

		// remove dead colliders
		var newColliders: Array<Collider> = [];
		for (col in colliders) {
			if (col.owner.isAlive()) {
				newColliders.push(col);
			}
		}
		colliders = newColliders;

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
