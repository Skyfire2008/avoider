package org.skyfire2008.avoider.spatial;

import polygonal.ds.Hashable;

import spork.core.Entity;
import spork.core.Wrapper;

import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.geom.Rectangle;

enum LineIntersectionType {
	Segment;
	Beam;
}

class Collider implements Hashable {
	public var owner(default, null): Entity;
	public var pos(default, null): Point;
	public var x(get, set): Float;
	public var y(get, set): Float;
	public var radius(default, null): Float;
	public var side: Wrapper<Side>;
	public var ephemeral: Bool;
	public var key(default, null): Int;

	public function new(owner: Entity, pos: Point, radius: Float, side: Wrapper<Side>, ephemeral: Bool = false) {
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

	public function intersectsLine(p0: Point, p1: Point, type: LineIntersectionType): Float {
		// find intersection by solving the system of equations line-circle
		var k = Point.difference(p1, p0);
		var d = Point.difference(p0, pos);

		var a = Point.dot(k, k);
		var b = 2 * Point.dot(d, k);
		var c = Point.dot(d, d) - radius * radius;

		var D = Math.sqrt(b * b - 4 * a * c); // discriminant
		if (Math.isNaN(D)) {
			return Math.NaN;
		} else {
			// two possible solutions, filter them then select the closest one to p0
			var t = [(-b - D) / (2 * a), (-b + D) / (2 * a)];
			if (type == Segment) {
				t = t.filter((elem) -> {
					return elem >= 0 && elem <= 1;
				});
			} else {
				t = t.filter((elem) -> {
					return elem >= 0;
				});
			}

			if (t.length > 0) {
				return t[0];
			} else {
				return Math.NaN;
			}
		}
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
