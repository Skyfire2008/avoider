package org.skyfire2008.avoider.game;

import haxe.ds.StringMap;

import spork.core.Entity;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.graphics.Renderer;
import org.skyfire2008.avoider.spatial.UniformGrid;
import org.skyfire2008.avoider.spatial.UniformGrid.SegQueryRes;
import org.skyfire2008.avoider.spatial.Collider;

class Game {
	public static var instance(default, null): Game;
	public var entMap(default, null): StringMap<EntityFactoryMethod>;
	public var livesCallback(default, null): (value: Int) -> Void;
	public var blinkCallback(default, null): (value: Float) -> Void;

	private var entities: Array<Entity>;
	private var grid: UniformGrid;
	private var colliders: Array<Collider>;
	private var collidersToRemove: Array<Int>;

	public static function setInstance(instance: Game) {
		Game.instance = instance;
	}

	public function new(entMap: StringMap<EntityFactoryMethod>, livesCallback: (value: Int) -> Void, blinkCallback: (value: Float) -> Void) {
		entities = [];
		this.entMap = entMap;
		this.livesCallback = livesCallback;
		this.blinkCallback = blinkCallback;
		grid = new UniformGrid(20, 20, Std.int(Constants.gameWidth / 20), Std.int(Constants.gameHeight / 20));
		colliders = [];

		collidersToRemove = [];
	}

	public function reset() {
		entities = [];
		grid.reset();
		colliders = [];
		collidersToRemove = [];
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

	public function removeCollider(ownerId: Int) {
		collidersToRemove.push(ownerId);
	}

	public function querySegment(p0: Point, p1: Point): Array<SegQueryRes> {
		return grid.querySegment(p0, p1);
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
					// only call onCollide if collides with physical object
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
			if (col.owner.isAlive() && !collidersToRemove.contains(col.owner.id)) {
				newColliders.push(col);
			}
		}
		colliders = newColliders;
		collidersToRemove = [];

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

		ScoringSystem.instance.update(time);
	}
}
