package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;
import spork.core.PropertyHolder;

import org.skyfire2008.avoider.game.Side;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.spatial.Collider;

class InvulnerableOnCollision implements Interfaces.CollisionComponent implements Interfaces.UpdateComponent {
	private var side: Wrapper<Side>;
	private var colorMult: Wrapper<Float>;
	private var radius: Wrapper<Float>;
	private var pos: Point;

	private var blinkTime: Float;
	private var invulnTime: Float;
	private var curTime: Float;
	private var curBlinkTime: Float;
	private var isInvuln: Bool;

	public function new(invulnTime: Float, blinkTime: Float) {
		this.invulnTime = invulnTime;
		this.blinkTime = blinkTime;

		curTime = 0;
		curBlinkTime = 0;
		isInvuln = false;
	}

	public function assignProps(holder: PropertyHolder) {
		side = holder.side;
		colorMult = holder.colorMult;
		radius = holder.colliderRadius;
		pos = holder.position;
	}

	public function onCollide(other: Collider) {
		if (this.side.value == Side.Hostile || this.side.value != other.side.value) {
			isInvuln = true;
			curBlinkTime = 0;
			colorMult.value = 0;
			Game.instance.removeCollider(owner.id);
		}
	}

	public function onUpdate(time: Float) {
		if (isInvuln) {
			curTime += time;
			curBlinkTime += time;
			if (curBlinkTime >= blinkTime) {
				curBlinkTime -= blinkTime;
				colorMult.value = 1.0 - colorMult.value;
			}
			if (curTime >= invulnTime) {
				colorMult.value = 1;
				curTime = 0;
				isInvuln = false;
				Game.instance.addCollider(new Collider(owner, pos, radius.value, side));
			}
		}
	}
}
