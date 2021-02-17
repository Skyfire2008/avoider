package org.skyfire2008.avoider.game.components;

import spork.core.Entity;
import spork.core.PropertyHolder;

class AlwaysAlive implements Interfaces.IsAliveComponent {
	private var value: Bool = true;
	private var owner: Entity;

	public function new() {}

	public function isAlive(): Bool {
		return value;
	}

	public function kill() {
		value = false;
	}
}
