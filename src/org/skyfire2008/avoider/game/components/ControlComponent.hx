package org.skyfire2008.avoider.game.components;

import spork.core.Entity;
import spork.core.PropertyHolder;
import spork.core.Wrapper;

import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.game.Controller;
import org.skyfire2008.avoider.game.components.Interfaces.InitComponent;
import org.skyfire2008.avoider.game.components.Interfaces.KBComponent;
import org.skyfire2008.avoider.game.components.Interfaces.DeathComponent;
import org.skyfire2008.avoider.game.components.Interfaces.UpdateComponent;

using org.skyfire2008.avoider.geom.Point;

class ControlComponent implements KBComponent implements InitComponent implements UpdateComponent implements DeathComponent {
	private static inline var blinkDist = 320;
	private static inline var blinkRecharge = 5;

	private var owner: Entity;
	private var dir: Point;
	private var normDir: Point;
	private var a: Float;
	private var brakeMult: Float;
	private var maxSpeed: Float;
	private var pos: Point;
	private var side: Wrapper<Side>;
	private var vel: Point;
	private var rotation: Wrapper<Float>;
	private var blinkTime: Float = blinkRecharge;

	private var isRunning = false;

	public function new(a: Float, maxSpeed: Float, brakeMult: Float) {
		dir = new Point();
		normDir = new Point();
		this.a = a;
		this.maxSpeed = maxSpeed;
		this.brakeMult = brakeMult;
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
		rotation = holder.rotation;
		side = holder.side;
	}

	public function addDir(x: Float, y: Float) {
		dir.x += x;
		dir.y += y;
		normDir.x = dir.x;
		normDir.y = dir.y;
		// normalize to make sure that diagonal movement is not faster
		// normDir.normalize();
	}

	public function setRun(value: Bool): Void {
		// TODO: just multiplying max speed and acceleraiton is not the best solution
	}

	public function blink(x: Float, y: Float): Void {
		if (blinkTime >= blinkRecharge) {
			TargetingSystem.instance.removeTarget(owner.id, side.value);
			var dir = new Point(x, y);
			dir.sub(pos);
			var dirLength = dir.length;
			if (dirLength > blinkDist) {
				dir.mult(blinkDist / dirLength);
			}
			pos.x += dir.x;
			pos.y += dir.y;
			TargetingSystem.instance.addTarget(owner.id, pos, side.value);
			blinkTime = 0;
			Game.instance.blinkCallback(blinkTime / blinkRecharge);
		}
	}

	public function onInit() {
		Controller.instance.addComponent(this);
		Game.instance.blinkCallback(blinkTime / blinkRecharge);
	}

	public function onUpdate(time: Float) {
		if (blinkTime < blinkRecharge) {
			blinkTime += time;
			if (blinkTime > blinkRecharge) {
				blinkTime = blinkRecharge;
			}
			Game.instance.blinkCallback(blinkTime / blinkRecharge);
		}

		var friction = Math.pow(brakeMult, time * 60);

		// applies friction only if no movement keys are held
		/*if (dir.x == 0 && dir.y == 0) {
			vel.mult(friction);
		}*/

		if (Util.sgn(vel.x) != Util.sgn(dir.x)) {
			vel.x *= friction;
		}
		if (Util.sgn(vel.y) != Util.sgn(dir.y)) {
			vel.y *= friction;
		}

		// applies scale based on direciton difference between velocity and movement direction
		/*var normVel = vel.copy();
			normVel.normalize();
			var fricScale = normDir.dot(normVel);
			if (fricScale < 0) {
				fricScale = 0;
			}
			fricScale = 1 - fricScale;
			vel.mult((1 - fricScale) + friction * fricScale); */

		vel.add(Point.scale(normDir, a * time));

		var velLength = vel.length;
		if (velLength > maxSpeed) {
			vel.mult(maxSpeed / velLength);
		}

		rotation.value = vel.angle;
	}

	public function onDeath() {
		Controller.instance.removeComponent(this);
	}
}
