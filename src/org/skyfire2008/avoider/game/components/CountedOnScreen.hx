package org.skyfire2008.avoider.game.components;

class CountedOnScreen implements Interfaces.InitComponent implements Interfaces.DeathComponent {
	public function new() {}

	public function onInit() {
		// SpawnSystem.instance.incCount();
	}

	public function onDeath() {
		SpawnSystem.instance.decCount();
	}
}
