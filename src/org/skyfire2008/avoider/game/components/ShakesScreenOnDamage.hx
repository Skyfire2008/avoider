package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.graphics.Renderer;

class ShakesScreenOnDamage implements Interfaces.DamageComponent {
	public function new() {}

	public function onDamage(dmg: Int) {
		Renderer.instance.startScreenShake();
	}
}
