package org.skyfire2008.avoider.game.properties;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.game.Side;

import spork.core.Wrapper;

class MyHolder {
	public var colorMult: Wrapper<Float>;
	public var position: Point;
	public var velocity: Point;
	public var rotation: Wrapper<Float>;
	public var angVel: Wrapper<Float>;
	public var scale: Wrapper<Float>;
	public var side: Wrapper<Side>;
	public var colliderRadius: Wrapper<Float>;
	public var timeToLive: Wrapper<Float>;
}
