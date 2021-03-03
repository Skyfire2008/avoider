package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.game.components.Interfaces.CollisionComponent;
import org.skyfire2008.avoider.game.components.Interfaces.UpdateComponent;
import org.skyfire2008.avoider.game.components.Interfaces.InitComponent;
import org.skyfire2008.avoider.game.TargetingSystem;
import org.skyfire2008.avoider.spatial.Collider;

class ChaserBehaviour implements InitComponent implements UpdateComponent implements CollisionComponent {
	public function new() {}

	public function onInit() {}

	public function onUpdate(time: Float) {}

	public function onCollide(other: Collider) {}
}
