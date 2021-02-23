package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.game.Constants;

class HitsWalls implements Interfaces.UpdateComponent {
	private var pos: Point;
	private var vel: Point;

	public function new() {}

	public function onUpdate(time: Float) {
		if (pos.x < 0) {
			pos.x = -pos.x * Constants.k;
			vel.x = -vel.x * Constants.k;
		} else if (pos.x > Constants.gameWidth) {
			var offset = pos.x - Constants.gameWidth;
			pos.x = Constants.gameWidth - offset * Constants.k;
			vel.x = -vel.x * Constants.k;
		}

		if (pos.y < 0) {
			pos.y = -pos.y * Constants.k;
			vel.y = -vel.y * Constants.k;
		} else if (pos.y > Constants.gameHeight) {
			var offset = pos.y - Constants.gameHeight;
			pos.y = Constants.gameHeight - offset * Constants.k;
			vel.y = -vel.y * Constants.k;
		}
	}

	public function assignProps(holder: PropertyHolder) {
		pos = holder.position;
		vel = holder.velocity;
	}
}
