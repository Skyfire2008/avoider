package org.skyfire2008.avoider.game.components;

import howler.Howl;

class PlaysSoundOnDeath implements Interfaces.DeathComponent {
	private var sound: Howl;
	private var soundSrc: String;

	public static function fromJson(json: Dynamic) {
		return new PlaysSoundOnDeath(new Howl({src: [json.soundSrc]}));
	}

	public function new(sound: Howl) {
		this.sound = sound;
	}

	public function onDeath() {
		sound.play();
	}
}
