package org.skyfire2008.avoider.game.components;

import haxe.ds.StringMap;

import spork.core.Wrapper;
import spork.core.Entity;
import spork.core.PropertyHolder;

import org.skyfire2008.avoider.game.components.Interfaces.UpdateComponent;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.graphics.Renderer;
import org.skyfire2008.avoider.geom.Point;

class RenderComponent implements UpdateComponent {
	private var shape: Shape;
	private var pos: Point;
	private var rotation: Wrapper<Float>;
	private var owner: Entity;
	private var colorMult: Wrapper<Float>;
	private var scale: Wrapper<Float>;

	/**
	 * Factory function to create a ShapeRenderComponent from JSON template
	 * Properties: shapeRef
	 * @param json json object containing the configuration
	 * @return ShapeRenderComponent
	 */
	public static function fromJson(json: Dynamic): RenderComponent {
		var shape = Shape.getShape(json.shapeRef);
		if (shape == null) {
			throw 'No shape for ${json.shapeRef} exists';
		}
		return new RenderComponent(shape);
	}

	public function new(shape: Shape) {
		this.shape = shape;
		this.colorMult = new Wrapper<Float>(1.0);
		this.scale = new Wrapper<Float>(1.0);
	}

	public function onUpdate(time: Float): Void {
		Renderer.instance.render(shape, pos.x, pos.y, rotation.value, scale.value, colorMult.value);
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		rotation = holder.rotation;
	}

	public function createProps(holder: PropertyHolder) {
		holder.colorMult = colorMult;
		holder.scale = scale;
	}
}
