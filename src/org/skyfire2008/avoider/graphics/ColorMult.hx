package org.skyfire2008.avoider.graphics;

abstract ColorMult(Array<Float>) from Array<Float> to Array<Float> {
	public static function fromJson(json: Dynamic): ColorMult {
		return new ColorMult(json[0], json[1], json[2]);
	}

	public var r(get, set): Float;
	public var g(get, set): Float;
	public var b(get, set): Float;

	public inline function new(r: Float, g: Float, b: Float) {
		this = [r, g, b];
	}

	public inline function setAll(v: Float) {
		r = v;
		g = v;
		b = v;
	}

	public inline function set(values: ColorMult) {
		this[0] = values[0];
		this[1] = values[1];
		this[2] = values[2];
	}

	private inline function get_r(): Float {
		return this[0];
	}

	private inline function set_r(r: Float): Float {
		return this[0] = r;
	}

	private inline function get_g(): Float {
		return this[1];
	}

	private inline function set_g(g: Float): Float {
		return this[1] = g;
	}

	private inline function get_b(): Float {
		return this[2];
	}

	private inline function set_b(b: Float): Float {
		return this[2] = b;
	}
}
