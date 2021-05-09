package org.skyfire2008.avoider.game.components;

class CausesGameOver implements Interfaces.DeathComponent {
	private static var callback: () -> Void;

	public static function init(callback: () -> Void) {
		CausesGameOver.callback = callback;
	}

	public function new() {}

	public function onDeath() {
		callback();
	}
}
