package org.skyfire2008.avoider.game;

import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.geom.Point;

class SpawnSystem {
	public static var instance(default, null): SpawnSystem;

	private var expectedEnemiesOnScreen = 0;
	private var enemiesOnScreen = 0;
	private var enemiesTotal = 2;
	private var wave = 0;

	private var chaserSpawnFunc: EntityFactoryMethod;
	private var shooterSpawnFunc: EntityFactoryMethod;

	public static function setInstance(instance: SpawnSystem) {
		SpawnSystem.instance = instance;
	}

	public function new() {
		chaserSpawnFunc = Game.instance.entMap.get("chaser.json");
		shooterSpawnFunc = Game.instance.entMap.get("shooter.json");
		incWave();
	}

	private function spawnEnemy() {
		var shooterProb = 0.5 - 5 / (wave + 5);
		var spawnFunc: EntityFactoryMethod;

		if (Math.random() < shooterProb) {
			spawnFunc = shooterSpawnFunc;
		} else {
			spawnFunc = chaserSpawnFunc;
		}

		var startPos = new Point(0, 0);
		var foobar = Std.random(4);
		if (foobar == 0 || foobar == 2) {
			startPos.x = Math.random() * Constants.gameWidth;
		} else {
			startPos.y = Math.random() * Constants.gameHeight;
		}

		if (foobar == 1) {
			startPos.x = Constants.gameWidth;
		} else if (foobar == 2) {
			startPos.y = Constants.gameHeight;
		}

		var ent = spawnFunc((holder) -> {
			holder.position = startPos;
		});
		Game.instance.addEntity(ent);
	}

	private function incWave() {
		wave++;
		enemiesTotal = wave * 2;
		expectedEnemiesOnScreen = Std.int(wave / 2) + 1;
	}

	public function incCount() {
		enemiesOnScreen++;
		enemiesTotal--;
	}

	public function decCount() {
		enemiesOnScreen--;
		if (enemiesTotal <= 0 && enemiesOnScreen < 2) {
			incWave();
		}

		while (enemiesOnScreen < expectedEnemiesOnScreen && enemiesTotal > 0) {
			spawnEnemy();
		}
	}
}
