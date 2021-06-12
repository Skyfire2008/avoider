package org.skyfire2008.avoider.util;

import spork.core.Wrapper;

import js.html.XMLHttpRequest;
import js.html.ProgressEvent;
import js.lib.Promise;

import org.skyfire2008.avoider.game.Constants;

using org.skyfire2008.avoider.geom.Point;

class Util {
	/**
	 * Turns an entity towards its target
	 * @param pos entity position
	 * @param vel entity velocity
	 * @param angVel entity's angular velocity in this frame
	 * @param targetPos target position
	 */
	public static inline function turnTo(pos: Point, vel: Point, angVel: Float, targetPos: Point) {
		var dir = targetPos.difference(pos);
		var yAxis = new Point(-vel.y, vel.x);

		var requiredAngle = Math.acos(Point.dot(dir, vel) / (dir.length * vel.length));
		angVel = angVel >= requiredAngle ? requiredAngle : angVel;

		if (angVel < requiredAngle) {
			if (dir.dot(yAxis) > 0) {
				vel.turn(angVel);
			} else {
				vel.turn(-angVel);
			}
		} else {
			var newVel = Point.fromPolar(dir.angle, vel.length);
			vel.x = newVel.x;
			vel.y = newVel.y;
		}
	}

	/**
	 * Accelerates or decelerates velocity if needed
	 * @param vel velocity vector
	 * @param targetSpeed speed that has to be reached
	 * @param a acceleration
	 * @param dTime time elapsed in this frame
	 */
	public static function accelIfNeeded(vel: Point, targetSpeed: Float, a: Float, dTime: Float) {
		var velLength = vel.length;
		if (vel.length > targetSpeed) {
			var friction = Math.pow(Constants.mju, dTime * 60);
			vel.mult(friction);
		} else {
			var addVel = vel.scale(a * dTime / velLength);
			vel.add(addVel);
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

	public static inline function fetchFile(path: String, startCb: (text: String) -> Void, finishCb: (text: String) -> Void): Promise<String> {
		startCb(path);

		return new Promise<String>((resolve, reject) -> {
			var xhr = new XMLHttpRequest();
			xhr.addEventListener("load", (e: ProgressEvent) -> {
				finishCb(path);
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
