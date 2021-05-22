package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

import org.skyfire2008.avoider.graphics.ColorMult;

class ChangesColorMult implements Interfaces.UpdateComponent {
	private var mult1: ColorMult;
	private var mult2: ColorMult;
	private var totalTime: Float;
	private var timeToLive: Wrapper<Float>;
	private var mult: ColorMult;
	private var originalMult: ColorMult;

	public function new(mult1: ColorMult, mult2: ColorMult) {
		this.mult1 = mult1;
		this.mult2 = mult2;
	}

	public function assignProps(holder: PropertyHolder) {
		timeToLive = holder.timeToLive;
		totalTime = timeToLive.value;
		mult = holder.colorMult;
		originalMult = new ColorMult(mult.r, mult.g, mult.b);
	}

	public function onUpdate(time: Float) {
		for (i in 0...3) {
			mult[i] = (mult2[i] * (totalTime - timeToLive.value) + mult1[i] * timeToLive.value) / totalTime;
			mult[i] *= originalMult[i];
		}
	}
}
