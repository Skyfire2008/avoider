package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.graphics.ColorMult;
import org.skyfire2008.avoider.graphics.Renderer;

class AnimComponent implements Interfaces.UpdateComponent {
	@prop("position")
	private var pos: Point;
	@prop
	private var rotation: Wrapper<Float>;
	@prop
	private var colorMult: ColorMult;
	@prop
	private var scale: Wrapper<Float>;

	private var timings: Array<Float>;
	private var shapes: Array<Shape>;
	private var totalTime: Float;
	private var depth: Float;
	private var time = 0.0;
	private var freezeMult = 1.0;
	private var curFrame = 0;

	public static function fromJson(json: Dynamic) {
		var shapes: Array<Shape> = [];
		for (i in 0...json.shapes.length) {
			var shapeRef = json.shapes[i];
			var shape = Shape.getShape(shapeRef);
			if (shape == null) {
				throw 'No shape for $shapeRef exists';
			}
			shapes.push(shape);
		}

		return new AnimComponent(json.timings, shapes, json.totalTime, json.depth);
	}

	public function new(timings: Array<Float>, shapes: Array<Shape>, totalTime: Float, depth: Float) {
		this.timings = timings;
		this.shapes = shapes;
		this.totalTime = totalTime;
		this.depth = depth;
	}

	public function onUpdate(dTime: Float) {
		Renderer.instance.render(shapes[curFrame], pos.x, pos.y, rotation.value, scale.value,
			[colorMult.r * freezeMult, colorMult.g * freezeMult, colorMult.b / freezeMult], depth);

		time += dTime;
		while (time > totalTime) {
			time -= totalTime;
			curFrame = 0;
		}

		while (curFrame + 1 < shapes.length && time > timings[curFrame + 1]) {
			curFrame++;
		}
	}
}
