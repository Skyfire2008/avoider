package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.ui.GameOverUI;

class CausesGameOver implements Interfaces.DeathComponent {
	private static var callback: () -> Void;

	public function new() {}

	public function onDeath() {
		GameOverUI.instance.isDisplayed.set(true);
	}
}
