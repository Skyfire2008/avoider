package org.skyfire2008.avoider.game.properties;

import spork.core.Entity;
import spork.core.Wrapper;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.graphics.ColorMult;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.graphics.Shape;

class MyHolder {
	public var colorMult: ColorMult;
	public var position: Point;
	public var velocity: Point;
	public var rotation: Wrapper<Float>;
	public var angVel: Wrapper<Float>;
	public var scale: Wrapper<Float>;
	public var side: Wrapper<Side>;
	public var colliderRadius: Wrapper<Float>;
	public var timeToLive: Wrapper<Float>;
	public var hp: Wrapper<Int>;
	public var warningFunc: EntityFactoryMethod;
	public var missileTargetPos: Point;
	public var missileLauncherId: Wrapper<Int>;
	public var lastCollidedWith: Wrapper<Entity>;
	public var message: Wrapper<String>;

	@fromJson("org.skyfire2008.avoider.game.properties.MyHolder.makeIndicatorShape")
	public var indicatorShape: Wrapper<Shape>;
	public var indicatorColorMult: ColorMult;

	public static function makeIndicatorShape(shapeRef: String) {
		return new Wrapper(Shape.getShape(shapeRef));
	}
}
