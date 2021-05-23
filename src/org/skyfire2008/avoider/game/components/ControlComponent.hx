package org.skyfire2008.avoider.game.components;

import howler.Howl;

import spork.core.Entity;
import spork.core.PropertyHolder;
import spork.core.Wrapper;
import spork.core.JsonLoader.EntityFactoryMethod;

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
	private static inline var ghostDist = 30.0;
	private static var blinkSound = new Howl({src: ["assets/sounds/teleport.wav"]});

	private var ghostMethod: EntityFactoryMethod;

	private var owner: Entity;
	private var dir: Point;
	private var a: Float;
	private var brakeMult: Float;
	private var maxSpeed: Float;
	private var runSpeed: Float;
	private var walkSpeed: Float;
	private var pos: Point;
	private var side: Wrapper<Side>;
	private var vel: Point;
	private var rotation: Wrapper<Float>;
	private var blinkTime: Float = blinkRecharge;

	private var isRunning = false;

	public function new(a: Float, maxSpeed: Float, brakeMult: Float) {
		dir = new Point();
		this.a = a;
		this.maxSpeed = maxSpeed;
		this.runSpeed = maxSpeed;
		this.walkSpeed = maxSpeed / 4;
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
	}

	public function setWalk(value: Bool): Void {
		if (value) {
			maxSpeed = walkSpeed;
		} else {
			maxSpeed = runSpeed;
		}
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

			// add ghosts
			var ghostNum = Std.int(dir.length / ghostDist);
			var uDir = dir.copy();
			uDir.normalize();
			for (i in 0...ghostNum) {
				var ghostPos = uDir.scale(i * ghostDist);
				ghostPos.add(pos);
				var ghost = ghostMethod((holder) -> {
					holder.timeToLive = new Wrapper(0.75 * i / ghostNum);
					holder.position = ghostPos;
					holder.rotation.value = rotation.value;
				});
				Game.instance.addEntity(ghost);
			}

			pos.x += dir.x;
			pos.y += dir.y;
			TargetingSystem.instance.addTarget(owner.id, pos, side.value);
			blinkTime = 0;
			Game.instance.blinkCallback(blinkTime / blinkRecharge);

			blinkSound.play();
		}
	}

	public function onInit() {
		Controller.instance.addComponent(this);
		Game.instance.blinkCallback(blinkTime / blinkRecharge);
		ghostMethod = Game.instance.entMap.get("playerGhost.json");
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

		if (Util.sgn(vel.x) != Util.sgn(dir.x)) {
			vel.x *= friction;
		}
		if (Util.sgn(vel.y) != Util.sgn(dir.y)) {
			vel.y *= friction;
		}

		vel.add(Point.scale(dir, a * time));

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
