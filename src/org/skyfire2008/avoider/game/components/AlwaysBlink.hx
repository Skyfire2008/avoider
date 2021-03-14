package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;
import spork.core.PropertyHolder;

import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.spatial.Collider;

class AlwaysBlink implements Interfaces.UpdateComponent {
	private var colorMult: Wrapper<Float>;

	private var halfTime: Float;
	private var blinkTime: Float;
	private var curTime: Float;
	private var flip: Bool;

	private var startColorMult: Float;
	private var endColorMult: Float;

	public function new(blinkTime: Float, startColorMult: Float, endColorMult: Float) {
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
			colorMult.value = (startColorMult * curTime + endColorMult * (halfTime - curTime)) / halfTime;
		} else {
			colorMult.value = (endColorMult * curTime + startColorMult * (halfTime - curTime)) / halfTime;
		}

		curTime += time;
		while (curTime > halfTime) {
			curTime -= halfTime;
			flip = !flip;
		}
	}
}
