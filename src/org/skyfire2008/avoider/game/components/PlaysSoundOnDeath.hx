package org.skyfire2008.avoider.game.components;

import howler.Howl;

class PlaysSoundOnDeath implements Interfaces.DeathComponent implements Interfaces.InitComponent {
	private var sound: Howl;
	private var soundSrc: String;

	public function new(soundSrc: String) {
		this.soundSrc = soundSrc;
	}

	public function onInit() {
		sound = SoundSystem.instance.getSound(soundSrc);
	}

	public function onDeath() {
		sound.play();
	}
}
