package org.skyfire2008.avoider.game;

import haxe.ds.StringMap;

import howler.Howl;

class SoundSystem {
	public static var instance(default, null): SoundSystem;
	private static inline var halfWidth = Constants.gameWidth / 2;

	private var soundMap(default, null): StringMap<Howl>;

	public static function setInstance(instance: SoundSystem) {
		SoundSystem.instance = instance;
	}

	public function new(soundMap: StringMap<Howl>) {
		this.soundMap = soundMap;
	}

	public function playSound(sound: Howl, pos: Float, repeats: Bool = false) {
		var pan = (pos - halfWidth) / halfWidth;
		if (!repeats) {
			sound.stop();
		}
		sound.stereo(0.75 * pan);
		// sound.rate(Math.random() * 0.2 + 0.9);
		sound.play();
	}

	public function getSound(name: String): Howl {
		return soundMap.get(name);
	}

	public function setRate(rate: Float) {
		for (howl in soundMap.iterator()) {
			howl.rate(rate);
		}
	}
}
