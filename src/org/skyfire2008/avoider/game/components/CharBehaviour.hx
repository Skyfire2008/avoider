package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Wrapper;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.graphics.ColorMult;

class CharBehaviour implements Interfaces.UpdateComponent {
	private var pos: Point;
	private var scale: Wrapper<Float>;
	private var colorMult: ColorMult;
	private var stage0: Float;
	private var stage1: Float;
	private var stage2: Float;
	private var time = 0.0;

	private var initialMult: ColorMult;
	private var msgPos: Point;
	private var charPos: Point;
	private var params: MessageSystem.MessageParams;

	public function new(msgPos: Point, params: MessageSystem.MessageParams) {
		this.msgPos = msgPos;
		this.params = params;
	}

	public function assignProps(holder: PropertyHolder) {
		this.pos = holder.position;
		this.charPos = pos.copy();
		this.scale = holder.scale;
		this.colorMult = holder.colorMult;
		this.initialMult = [colorMult.r, colorMult.g, colorMult.b];

		stage0 = params.appearTime;
		stage1 = stage0 + params.hangTime;
		stage2 = stage1 + params.fadeTime;
	}

	public function onUpdate(dTime: Float) {
		if (time <= stage0) {
			var mult = time / stage0;
			// spread out the characters from center
			pos.x = charPos.x * mult + msgPos.x * (1.0 - mult);
			pos.y = charPos.y * mult + msgPos.y * (1.0 - mult);
			scale.value = params.scale * mult;
			colorMult.set([initialMult.r * mult, initialMult.g * mult, initialMult.b * mult]);

			// set properties once for hang time
			if (time + dTime > stage0) {
				pos.x = charPos.x;
				pos.y = charPos.y;
				scale.value = params.scale;
				colorMult.set([initialMult.r, initialMult.g, initialMult.b]);
			}
		} else if (time > stage1) {
			var mult = (stage2 - time) / params.fadeTime;
			colorMult.set([initialMult.r * mult, initialMult.g * mult, initialMult.b * mult]);
			pos.x += (pos.x - msgPos.x) * params.spread * (time - stage1);
		}

		time += dTime;
	}
}

class CharBehaviour2 implements Interfaces.UpdateComponent {
	private var pos: Point;
	private var scale: Wrapper<Float>;
	private var colorMult: ColorMult;
	private var stage0: Float;
	private var stage1: Float;
	private var time = 0.0;

	private var initialMult: ColorMult;
	private var msgPos: Point;
	private var charPos: Point;
	private var params: MessageSystem.MessageParams;

	public function new(msgPos: Point, params: MessageSystem.MessageParams) {
		this.msgPos = msgPos;
		this.params = params;
	}

	public function assignProps(holder: PropertyHolder) {
		this.pos = holder.position;
		this.charPos = pos.copy();
		this.scale = holder.scale;
		this.colorMult = holder.colorMult;
		this.initialMult = [colorMult.r, colorMult.g, colorMult.b];

		stage0 = params.hangTime;
		stage1 = stage0 + params.fadeTime;
	}

	public function onUpdate(dTime: Float) {
		if (time > stage0) {
			var mult = (stage1 - time) / params.fadeTime;
			colorMult.set([initialMult.r * mult, initialMult.g * mult, initialMult.b * mult]);
			pos.y -= 60 * dTime;
		}

		time += dTime;
	}
}
