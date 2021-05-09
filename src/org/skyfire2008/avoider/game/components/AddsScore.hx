package org.skyfire2008.avoider.game.components;

class AddsScore implements Interfaces.DeathComponent {
	public function new() {}

	public function onDeath() {
		ScoringSystem.instance.addScore();
	}
}
