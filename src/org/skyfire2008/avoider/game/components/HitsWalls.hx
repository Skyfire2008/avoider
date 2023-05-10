package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;

import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.game.Constants;

class HitsWalls implements Interfaces.UpdateComponent {
	private var k: Float;

	@prop("position")
	private var pos: Point;
	@prop("velocity")
	private var vel: Point;

	public function new(?k: Float) {
		this.k = (k == null) ? Constants.k : k;
	}

	public function onUpdate(time: Float) {
		if (pos.x < 0) {
			pos.x = -pos.x * k;
			vel.x = -vel.x * k;
		} else if (pos.x > Constants.gameWidth) {
			var offset = pos.x - Constants.gameWidth;
			pos.x = Constants.gameWidth - offset * k;
			vel.x = -vel.x * k;
		}

		if (pos.y < 0) {
			pos.y = -pos.y * k;
			vel.y = -vel.y * k;
		} else if (pos.y > Constants.gameHeight) {
			var offset = pos.y - Constants.gameHeight;
			pos.y = Constants.gameHeight - offset * k;
			vel.y = -vel.y * k;
		}
	}
}
