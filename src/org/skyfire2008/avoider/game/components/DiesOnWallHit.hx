package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.geom.Point;

class DiesOnWallHit implements Interfaces.UpdateComponent {
	public function new() {}

	@prop("position")
	private var pos: Point;

	public function onUpdate(dTime: Float) {
		if (pos.x < 0 || pos.x > Constants.gameWidth || pos.y < 0 || pos.y > Constants.gameHeight) {
			owner.kill();
		}
	}
}
