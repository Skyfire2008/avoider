package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;

import org.skyfire2008.avoider.graphics.ColorMult;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.graphics.Renderer;
import org.skyfire2008.avoider.geom.Point;

class HasIndicator implements Interfaces.UpdateComponent {
	@prop("position")
	private var pos: Point;
	@prop
	private var rotation: Wrapper<Float>;
	@prop
	private var scale: Wrapper<Float>;
	@prop("indicatorColorMult")
	private var colorMult: ColorMult;
	@prop("indicatorShape")
	private var shape: Wrapper<Shape>;

	private var depth: Float;

	public function new(depth: Float) {
		this.depth = depth;
	}

	public function onUpdate(dTime: Float) {
		Renderer.instance.render(shape.value, pos.x, pos.y, rotation.value, scale.value, colorMult, depth);
	}
}
