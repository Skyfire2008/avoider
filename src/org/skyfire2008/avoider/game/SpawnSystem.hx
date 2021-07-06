package org.skyfire2008.avoider.game;

import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.geom.Point;

class SpawnSystem {
	public static var instance(default, null): SpawnSystem;
	private static inline var border = 30.0;

	private var expectedEnemiesOnScreen = 0;
	private var enemiesOnScreen = 0;
	private var enemiesTotal = 2;
	public var wave(default, null) = 1;

	private var warningSpawnFunc: EntityFactoryMethod;
	private var chaserSpawnFunc: EntityFactoryMethod;
	private var shooterSpawnFunc: EntityFactoryMethod;
	private var howitzerSpawnFunc: EntityFactoryMethod;
	private var launcherSpawnFunc: EntityFactoryMethod;

	public static function setInstance(instance: SpawnSystem) {
		SpawnSystem.instance = instance;
	}

	public function new() {
		warningSpawnFunc = Game.instance.entMap.get("warning.json");
		chaserSpawnFunc = Game.instance.entMap.get("chaser.json");
		launcherSpawnFunc = Game.instance.entMap.get("launcher.json");
		shooterSpawnFunc = Game.instance.entMap.get("shooter.json");
		howitzerSpawnFunc = Game.instance.entMap.get("howitzer.json");
	}

	public function reset() {
		wave = 1;
		enemiesOnScreen = 0;
		enemiesTotal = 2;
		expectedEnemiesOnScreen = 2;
		for (i in 0...2) {
			spawnEnemy();
		}
	}

	private function spawnEnemy() {
		var shooterProb = 0.5 - 4 / (wave + 4);
		var spawnFunc: EntityFactoryMethod;

		if (Math.random() < shooterProb) {
			var howitzerProb = 0.5 - 6 / (wave + 6);
			if (Math.random() < howitzerProb) {
				spawnFunc = howitzerSpawnFunc;
			} else {
				spawnFunc = shooterSpawnFunc;
			}
		} else {
			var launcherProb = 0.6 - 10 / (wave + 10);
			if (Math.random() < launcherProb) {
				spawnFunc = launcherSpawnFunc;
			} else {
				spawnFunc = chaserSpawnFunc;
			}
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

		startPos.x = Math.max(border, startPos.x);
		startPos.x = Math.min(Constants.gameWidth - border, startPos.x);
		startPos.y = Math.max(border, startPos.y);
		startPos.y = Math.min(Constants.gameHeight - border, startPos.y);

		var warning = warningSpawnFunc((holder) -> {
			holder.position = startPos;
			holder.warningFunc = spawnFunc;
		});
		Game.instance.addEntity(warning);
		incCount();
	}

	private function incWave() {
		wave++;
		ScoringSystem.instance.notifyOfWaveInc();
		enemiesTotal = Std.int(wave * 1.5);
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
