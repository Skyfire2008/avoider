package org.skyfire2008.avoider.game;

import haxe.ds.StringMap;

import howler.Howl;

import spork.core.Wrapper;
import spork.core.Component;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.geom.Point;

typedef SpawnerConfig = {
	var entityName: String;
	var spawnTime: Float;
	var spawnVel: Float;
	var spawnNum: Int;
	var relVelMult: Float;
	@:optional var velRand: Float;
	@:optional var spreadAngle: Float;
	@:optional var angleRand: Float;
	@:optional var soundSrc: String;
	@:optional var randomize: Bool;
}

class Spawner {
	public var spawnFunc: EntityFactoryMethod;
	public var config: SpawnerConfig;
	public var extraComponents: Array<() -> Component>;

	private var curTime: Float = 0;
	private var isSpawning: Bool = false;

	public var howl(default, null): Howl = null;

	public function new(config: SpawnerConfig) {
		if (config.velRand == null) {
			config.velRand = 0;
		}
		if (config.spreadAngle == null) {
			config.spreadAngle = 0;
		}
		if (config.angleRand == null) {
			config.angleRand = 0;
		}
		if (config.soundSrc != null) {
			howl = new Howl({src: [config.soundSrc]});
		}
		if (config.randomize == true) {
			this.curTime = Math.random() * config.spawnTime;
		}
		this.config = config;

		extraComponents = [];
	}

	public function init() {
		spawnFunc = Game.instance.entMap.get(config.entityName);
	}

	public function clone(): Spawner {
		return new Spawner({
			entityName: config.entityName,
			spawnTime: config.spawnTime,
			spawnVel: config.spawnVel,
			spawnNum: config.spawnNum,
			relVelMult: config.relVelMult,
			velRand: config.velRand,
			spreadAngle: config.spreadAngle,
			angleRand: config.angleRand,
			soundSrc: config.soundSrc,
			randomize: config.randomize
		});
	}

	public function startSpawn() {
		isSpawning = true;
	}

	public function stopSpawn() {
		isSpawning = false;
	}

	public function spawn(pos: Point, rotation: Float, vel: Point) {
		var baseAngle = config.spawnNum * config.spreadAngle / 2.0;

		for (i in 0...config.spawnNum) {
			// create extra components
			var extras: Array<Component> = [];
			for (func in extraComponents) {
				extras.push(func());
			}

			var ent = spawnFunc((holder) -> {
				var angle = i * config.spreadAngle + Util.rand(config.angleRand);
				angle -= baseAngle;
				holder.position = pos.copy();
				holder.rotation = new Wrapper<Float>(rotation + angle);
				holder.angVel = new Wrapper<Float>(0);

				holder.velocity = Point.fromPolar(angle + rotation, config.spawnVel + Util.rand(config.velRand));
				holder.velocity.x += vel.x * config.relVelMult;
				holder.velocity.y += vel.y * config.relVelMult;

				// assign properties to extras
				for (component in extras) {
					component.assignProps(holder);
				}
			});

			// attach extra components
			for (component in extras) {
				component.attach(ent);
			}

			Game.instance.addEntity(ent);
		}

		if (howl != null && !howl.playing()) {
			howl.play();
		}
	}

	public function update(time: Float, pos: Point, rotation: Float, vel: Point) {
		if (isSpawning) {
			curTime += time;
			while (curTime >= config.spawnTime) {
				spawn(pos, rotation, vel);
				curTime -= config.spawnTime;
			}
		} else {
			if (curTime < config.spawnTime) {
				curTime += time;
			}
		}
	}
}
