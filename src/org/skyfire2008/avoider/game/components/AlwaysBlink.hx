package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;

import org.skyfire2008.avoider.graphics.ColorMult;

class AlwaysBlink implements Interfaces.UpdateComponent {
	private var colorMult: ColorMult;

	private var halfTime: Float;
	private var blinkTime: Float;
	private var curTime: Float;
	private var flip: Bool;

	private var startColorMult: ColorMult;
	private var endColorMult: ColorMult;

	public function new(blinkTime: Float, startColorMult: ColorMult, endColorMult: ColorMult) {
		this.blinkTime = blinkTime;
		this.halfTime = 0.5 * blinkTime;
		this.startColorMult = startColorMult;
		this.endColorMult = endColorMult;

		curTime = 0;
		flip = false;
	}

	public function assignProps(holder: PropertyHolder) {
		colorMult = holder.colorMult;
	}

	public function onUpdate(time: Float) {
		if (flip) {
			for (i in 0...3) {
				colorMult[i] = (startColorMult[i] * curTime + endColorMult[i] * (halfTime - curTime)) / halfTime;
			}
		} else {
			for (i in 0...3) {
				colorMult[i] = (endColorMult[i] * curTime + startColorMult[i] * (halfTime - curTime)) / halfTime;
			}
		}

		curTime += time;
		while (curTime > halfTime) {
			curTime -= halfTime;
			flip = !flip;
		}
	}
}
