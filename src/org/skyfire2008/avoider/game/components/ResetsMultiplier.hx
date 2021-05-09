package org.skyfire2008.avoider.game.components;

class ResetsMultiplier implements Interfaces.DamageComponent {
	public function new() {}

	public function onDamage(dmg: Int) {
		ScoringSystem.instance.resetMult();
	}
}
