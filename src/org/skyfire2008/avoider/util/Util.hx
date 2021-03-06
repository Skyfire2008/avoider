package org.skyfire2008.avoider.util;

import spork.core.Wrapper;

import js.html.XMLHttpRequest;
import js.html.ProgressEvent;
import js.lib.Promise;

using org.skyfire2008.avoider.geom.Point;

class Util {
	/**
	 * Turns an entity towards its target
	 * @param pos entity position
	 * @param vel entity velocity
	 * @param rotation entity rotation
	 * @param angVel entity's angular velocity in this frame
	 * @param targetPos target position
	 */
	public static inline function turnTo(pos: Point, vel: Point, rotation: Wrapper<Float>, angVel: Float, targetPos: Point) {
		var dir = targetPos.difference(pos);
		var yAxis = new Point(-vel.y, vel.x);

		var requiredAngle = Math.acos(Point.dot(dir, vel) / (dir.length * vel.length));
		angVel = angVel >= requiredAngle ? requiredAngle : angVel;

		if (dir.dot(yAxis) > 0) {
			vel.turn(angVel);
			rotation.value += angVel;
		} else {
			vel.turn(-angVel);
			rotation.value -= angVel;
		}
	}

	public static inline function max(a: Int, b: Int): Int {
		return a > b ? a : b;
	}

	public static inline function min(a: Int, b: Int): Int {
		return a < b ? a : b;
	}

	public static inline function sgn(a: Float): Int {
		var result: Int = 0;
		if (a != 0) {
			result = (a > 0) ? 1 : -1;
		}
		return result;
	}

	public static inline function rand(val: Float): Float {
		return val * (Math.random() - 0.5);
	}

	public static inline function fetchFile(path: String): Promise<String> {
		return new Promise<String>((resolve, reject) -> {
			var xhr = new XMLHttpRequest();
			xhr.addEventListener("load", (e: ProgressEvent) -> {
				resolve(xhr.responseText);
			});
			xhr.addEventListener("error", () -> {
				reject('Could not fetch file $path');
			});
			xhr.open("GET", path);
			xhr.send();
		});
	}
}
