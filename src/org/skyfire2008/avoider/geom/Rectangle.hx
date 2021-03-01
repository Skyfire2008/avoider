package org.skyfire2008.avoider.geom;

class Rectangle {
	public var x: Float;
	public var y: Float;
	public var width: Float;
	public var height: Float;

	public var right(get, set): Float;
	public var bottom(get, set): Float;

	public static inline function union(a: Rectangle, b: Rectangle) {
		var x = (a.x < b.x) ? a.x : b.x;
		var y = (a.y < b.y) ? a.y : b.y;
		var right = (a.right > b.right) ? a.right : b.right;
		var bottom = (a.bottom > b.bottom) ? a.bottom : b.bottom;

		return new Rectangle(x, y, right - x, bottom - y);
	}

	public function new(x: Float = 0, y: Float = 0, width: Float = 0, height: Float = 0) {
		this.x = x;
		this.y = y;
		this.width = width;
		this.height = height;
	}

	public inline function intersection(other: Rectangle): Rectangle {
		var result: Rectangle = null;

		var x0 = Math.max(x, other.x);
		var x1 = Math.min(right, other.right);
		var y0 = Math.max(y, other.y);
		var y1 = Math.min(bottom, other.bottom);

		if (x0 < x1 && y0 < y1) {
			result = new Rectangle(x0, y0, x1 - x0, y1 - y0);
		}

		return result;
	}

	public inline function intersects(other: Rectangle): Bool {
		/*var x0 = Math.max(x, other.x);
			var x1 = Math.min(right, other.right);
			var y0 = Math.max(y, other.y);
			var y1 = Math.min(bottom, other.bottom);

			return x0 < x1 && y0 < y1; */

		return intersection(other) != null;
	}

	// GETTERS AND SETTERS
	private inline function get_right(): Float {
		return x + width;
	}

	private inline function set_right(_right: Float): Float {
		width = _right - x;
		return _right;
	}

	private inline function get_bottom(): Float {
		return y + height;
	}

	private inline function set_bottom(_bottom: Float): Float {
		height = _bottom - y;
		return _bottom;
	}
}
