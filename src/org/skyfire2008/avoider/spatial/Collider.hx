package org.skyfire2008.avoider.spatial;

import polygonal.ds.Hashable;

import spork.core.Entity;

import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.geom.Rectangle;

class Collider implements Hashable {
	public var owner(default, null): Entity;
	public var pos(default, null): Point;
	public var x(get, set): Float;
	public var y(get, set): Float;
	public var radius(default, null): Float;
	public var side: Side;
	public var ephemeral: Bool;
	public var key(default, null): Int;

	public function new(owner: Entity, pos: Point, radius: Float, side: Side, ephemeral: Bool = false) {
		this.owner = owner;
		this.pos = pos;
		this.radius = radius;
		this.side = side;
		this.ephemeral = ephemeral;
		this.key = owner.id;
	}

	public function rect(): Rectangle {
		return new Rectangle(x - radius, y - radius, radius * 2, radius * 2);
	}

	public function intersects(other: Collider): Bool {
		var dx = x - other.x;
		var dy = y - other.y;
		var rSum = radius + other.radius;

		return dx * dx + dy * dy < rSum * rSum;
	}

	// GETTERS AND SETTERS
	private inline function get_x(): Float {
		return pos.x;
	}

	private inline function set_x(x: Float): Float {
		return pos.x = x;
	}

	private inline function get_y(): Float {
		return pos.y;
	}

	private inline function set_y(y: Float): Float {
		return pos.y = y;
	}
}
