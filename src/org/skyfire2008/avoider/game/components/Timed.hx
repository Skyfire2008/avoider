package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;
import spork.core.Component;

class Timed implements Interfaces.IsAliveComponent implements Interfaces.UpdateComponent {
	private var timeToLive: Wrapper<Float>;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		timeToLive = holder.timeToLive;
	}

	public function isAlive(): Bool {
		return timeToLive.value > 0;
	}

	public function kill() {
		timeToLive.value = 0;
	}

	public function onUpdate(time: Float) {
		this.timeToLive.value -= time;
	}
}
