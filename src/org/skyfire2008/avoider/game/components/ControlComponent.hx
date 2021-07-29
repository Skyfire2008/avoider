package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.graphics.Renderer;

import howler.Howl;

import spork.core.Entity;
import spork.core.PropertyHolder;
import spork.core.Wrapper;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.game.Controller;
import org.skyfire2008.avoider.game.components.Interfaces.InitComponent;
import org.skyfire2008.avoider.game.components.Interfaces.KBComponent;
import org.skyfire2008.avoider.game.components.Interfaces.DeathComponent;
import org.skyfire2008.avoider.game.components.Interfaces.UpdateComponent;

using org.skyfire2008.avoider.geom.Point;

class ControlComponent implements KBComponent implements InitComponent implements UpdateComponent implements DeathComponent {
	private static inline var blinkDist = 320;
	private static inline var blinkCost = 2.5;
	private static inline var totalEnergy = 5;
	private static inline var ghostDist = 30.0;
	private static var blinkSound: Howl;
	private static var enableTimeStretch: (value: Bool) -> Void;

	private var blinkGhost: Shape;
	private var mousePos: Point;
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
	private var energy: Float = totalEnergy;

	private var isRunning = false;
	private var isTimeStretched = false;

	public static function init(enableTimeStretch: (value: Bool) -> Void) {
		ControlComponent.enableTimeStretch = enableTimeStretch;
		blinkSound = SoundSystem.instance.getSound("teleport.wav");
	}

	public function new(a: Float, maxSpeed: Float, brakeMult: Float) {
		dir = new Point();
		this.a = a;
		this.maxSpeed = maxSpeed;
		this.runSpeed = maxSpeed;
		this.walkSpeed = maxSpeed / 4;
		this.brakeMult = brakeMult;
		mousePos = new Point();
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

	public function setTimeStretch(value: Bool): Void {
		enableTimeStretch(value);
		isTimeStretched = value;
	}

	public function blink(x: Float, y: Float): Void {
		if (energy >= blinkCost) {
			TargetingSystem.instance.removeTarget(owner.id, side.value);
			var dir = new Point(x, y);
			dir.sub(pos);
			var angle = dir.angle;
			rotation.value = angle;
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
			energy -= blinkCost;
			Game.instance.blinkCallback(energy / totalEnergy);

			blinkSound.play();
		}
	}

	public function onInit() {
		Controller.instance.addComponent(this);
		ScoringSystem.instance.setPlayerPos(pos);
		Game.instance.blinkCallback(energy / totalEnergy);
		ghostMethod = Game.instance.entMap.get("playerGhost.json");
		blinkGhost = Shape.getShape("blinkGhost.json");
	}

	public function onMouseMove(x: Float, y: Float) {
		mousePos.x = x;
		mousePos.y = y;
	}

	public function onUpdate(time: Float) {
		var spawnBlinkEffect = false;
		if (isTimeStretched) {
			if (energy > 0) {
				energy -= 2 * time / Constants.timeStretchMult;
				Game.instance.blinkCallback(energy / totalEnergy);
			} else {
				setTimeStretch(false);
			}
		} else {
			if (energy < totalEnergy) {
				energy += time;
				if (energy >= blinkCost && energy - time < blinkCost) {
					spawnBlinkEffect = true;
				}
				if (energy > totalEnergy) {
					energy = totalEnergy;
				}
				Game.instance.blinkCallback(energy / totalEnergy);
			}
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

		// draw blink ghost
		var mult = energy / blinkCost;
		if (mult < 0.7) {
			mult = 0;
		} else {
			mult = Math.min((mult - 0.7) / 0.2, 1.0);
		}
		if (spawnBlinkEffect) {
			Game.instance.addEntity(ghostMethod((holder) -> {
				holder.colorMult = [1, 1, 1];
				holder.timeToLive = new Wrapper(0.5);
				holder.position = pos;
				holder.rotation = rotation;
			}));
		}
		Renderer.instance.render(blinkGhost, pos.x, pos.y, rotation.value, 1, [0.01 * mult, 1.0 * mult, 0.5 * mult], 0.1);
	}

	public function onDeath() {
		Controller.instance.removeComponent(this);
		if (isTimeStretched) {
			setTimeStretch(false);
		}
	}
}
