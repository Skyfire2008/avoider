package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

class ChangesColorMult implements Interfaces.UpdateComponent {
	private var mult1: Float;
	private var mult2: Float;
	private var totalTime: Float;
	private var timeToLive: Wrapper<Float>;
	private var mult: Wrapper<Float>;
	private var startScale: Float;

	public function new(mult1: Float, mult2: Float) {
		this.mult1 = mult1;
		this.mult2 = mult2;
	}

	public function assignProps(holder: PropertyHolder) {
		timeToLive = holder.timeToLive;
		totalTime = timeToLive.value;
		mult = holder.colorMult;
		startScale = mult.value;
	}

	public function onUpdate(time: Float) {
		mult.value = startScale;
		mult.value *= (mult2 * (totalTime - timeToLive.value) + mult1 * timeToLive.value) / totalTime;
	}
}
