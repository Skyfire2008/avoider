package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;

import org.skyfire2008.avoider.graphics.ColorMult;
import org.skyfire2008.avoider.util.StorageLoader;

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

class AlwaysBlinkWarning implements Interfaces.UpdateComponent {
	private var halfTime = 0.1;
	private var curTime = 0.0;
	private var flip = false;

	@prop
	private var colorMult: ColorMult;

	public function new() {}

	public function onUpdate(time: Float) {
		var color0 = StorageLoader.instance.data.warnColor;
		var color1 = new ColorMult(0, 0, 0);
		color1.setInterpolation(StorageLoader.instance.data.warnColor, [0.0, 0.0, 0.0], 0.5);
		var mult = curTime / halfTime;
		if (flip) {
			colorMult.setInterpolation(color0, color1, mult);
		} else {
			colorMult.setInterpolation(color1, color0, mult);
		}

		curTime += time;
		while (curTime > halfTime) {
			curTime -= halfTime;
			flip = !flip;
		}
	}
}
