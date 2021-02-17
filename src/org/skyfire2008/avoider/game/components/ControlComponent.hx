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
	private var maxSpeed: Float;
	// TODO: put mju into a separate file
	private var mju: Float;
	private var vel: Point;
	private var rotation: Wrapper<Float>;

	public function new(a: Float, maxSpeed: Float, mju: Float) {
		dir = new Point();
		normDir = new Point();
		this.a = a;
		this.maxSpeed = maxSpeed;
		this.mju = mju;
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
		normDir.normalize();
	}

	public function onInit() {
		Controller.instance.addComponent(this);
	}

	public function onUpdate(time: Float) {
		var friction = Math.pow(mju, time * 60);
		if (Util.sgn(vel.x) != Util.sgn(dir.x)) {
			vel.x *= friction;
		}
		if (Util.sgn(vel.y) != Util.sgn(dir.y)) {
			vel.y *= friction;
		}

		vel.add(Point.scale(normDir, a * time));

		var velLength = vel.length;
		if (velLength > maxSpeed) {
			vel.mult(velLength / maxSpeed);
		}

		rotation.value = vel.angle;
	}

	public function onDeath() {
		Controller.instance.removeComponent(this);
	}
}
