package org.skyfire2008.avoider.game.components;

import org.skyfire2008.avoider.geom.Point;

import howler.Howl;

class PlaysSoundOnDeath implements Interfaces.DeathComponent implements Interfaces.InitComponent {
	private var sound: Howl;
	private var soundSrc: String;

	@prop("position")
	private var pos: Point;

	public function new(soundSrc: String) {
		this.soundSrc = soundSrc;
	}

	public function onInit() {
		sound = SoundSystem.instance.getSound(soundSrc);
	}

	public function onDeath() {
		SoundSystem.instance.playSound(sound, pos.x, true);
	}
}
