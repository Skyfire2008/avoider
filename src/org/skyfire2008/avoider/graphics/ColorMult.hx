package org.skyfire2008.avoider.graphics;

abstract ColorMult(Array<Float>) from Array<Float> to Array<Float> {
	public static function fromJson(json: Dynamic): ColorMult {
		return new ColorMult(json[0], json[1], json[2]);
	}

	public static function toHexCode(mult: ColorMult): String {
		var r = Std.int(mult.r * 255);
		var g = Std.int(mult.g * 255);
		var b = Std.int(mult.b * 255);
		return '#${StringTools.hex(r, 2)}${StringTools.hex(g, 2)}${StringTools.hex(b, 2)}';
	}

	public static function fromHexCode(code: String): ColorMult {
		var value = Std.parseInt('0x${code.substring(1)}');
		var r = (value >> 16) & 0xff;
		var g = (value >> 8) & 0xff;
		var b = value & 0xff;
		return [r / 255.0, g / 255.0, b / 255.0];
	}

	public var r(get, set): Float;
	public var g(get, set): Float;
	public var b(get, set): Float;

	public function setInterpolation(c0: ColorMult, c1: ColorMult, mult: Float) {
		var invMult = 1.0 - mult;
		r = c0.r * invMult + c1.r * mult;
		g = c0.g * invMult + c1.g * mult;
		b = c0.b * invMult + c1.b * mult;
	}

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
