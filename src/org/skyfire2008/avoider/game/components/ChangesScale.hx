package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

class ChangesScale implements Interfaces.UpdateComponent {
	private var scale1: Float;
	private var scale2: Float;
	private var totalTime: Float;
	private var timeToLive: Wrapper<Float>;
	private var scale: Wrapper<Float>;
	private var startScale: Float;

	public function new(scale1: Float, scale2: Float) {
		this.scale1 = scale1;
		this.scale2 = scale2;
	}

	public function assignProps(holder: PropertyHolder) {
		timeToLive = holder.timeToLive;
		totalTime = timeToLive.value;
		scale = holder.scale;
		startScale = scale.value;
	}

	public function onUpdate(time: Float) {
		scale.value = startScale;
		scale.value *= (scale2 * (totalTime - timeToLive.value) + scale1 * timeToLive.value) / totalTime;
	}
}
