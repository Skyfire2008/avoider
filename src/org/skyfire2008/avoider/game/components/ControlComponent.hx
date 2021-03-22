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
	private var owner: Entity;
	private var dir: Point;
	private var normDir: Point;
	private var a: Float;
	private var brakeMult: Float;
	private var maxSpeed: Float;
	private var vel: Point;
	private var rotation: Wrapper<Float>;

	public function new(a: Float, maxSpeed: Float, brakeMult: Float) {
		dir = new Point();
		normDir = new Point();
		this.a = a;
		this.maxSpeed = maxSpeed;
		this.brakeMult = brakeMult;
		trace(maxSpeed);
	}

	public function assignProps(holder: PropertyHolder) {
		vel = holder.velocity;
		rotation = holder.rotation;
	}

	public function addDir(x: Float, y: Float) {
		dir.x += x;
		dir.y += y;
		normDir.x = dir.x;
		normDir.y = dir.y;
		// normalize to make sure that diagonal movement is not faster
		// normDir.normalize();
	}

	public function onInit() {
		Controller.instance.addComponent(this);
	}

	public function onUpdate(time: Float) {
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
