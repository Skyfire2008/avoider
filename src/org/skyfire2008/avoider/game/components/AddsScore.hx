package org.skyfire2008.avoider.game.components;

import spork.core.PropertyHolder;
import spork.core.Entity;
import spork.core.Wrapper;

import org.skyfire2008.avoider.geom.Point;

class AddsScore implements Interfaces.DeathComponent implements Interfaces.UpdateComponent {
	private static inline var bonusTime = 1.5;
	private var time = 0.0;
	@prop("position")
	private var pos: Point;
	@prop
	private var lastCollidedWith: Wrapper<Entity>;

	public function new() {}

	public function onUpdate(dTime: Float) {
		time += dTime;
	}

	public function onDeath() {
		if (lastCollidedWith.value == null) {
			ScoringSystem.instance.addScore();
		} else if (lastCollidedWith.value.templateName != "player.json") {
			ScoringSystem.instance.addScore();
			if (lastCollidedWith.value.templateName == "shooterBeam.json") {
				MessageSystem.instance.createMessage("direct\nhit", pos, {scale: 4, spacing: 2, color: [0.8, 1.0, 0.8]});
				ScoringSystem.instance.addScore();
			}
		}

		if (time <= bonusTime) {
			MessageSystem.instance.createMessage("spawn\nkill", pos, {scale: 4, spacing: 2, color: [1.0, 0.9, 0.8]});
			ScoringSystem.instance.addScore();
			ScoringSystem.instance.addScore();
		}
	}
}
