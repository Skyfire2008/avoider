package org.skyfire2008.avoider.game.components;

import spork.core.Entity;

import howler.Howl;

import org.skyfire2008.avoider.geom.Point;

class PlaysSoundOn implements Interfaces.DeathComponent implements Interfaces.InitComponent implements Interfaces.DamageComponent {
	private var sound: Howl;
	private var soundSrc: String;
	private var on: Array<String>;
	private var playOnInit = false;

	@prop("position")
	private var pos: Point;

	public function new(soundSrc: String, on: Array<String>) {
		this.soundSrc = soundSrc;
		this.on = on;
		playOnInit = on.contains("init");
	}

	public function attach(ent: Entity) {
		this.owner = ent;
		ent.initComponents.push(this);
		if (on.contains("death")) {
			ent.deathComponents.push(this);
		}
		if (on.contains("damage")) {
			ent.damageComponents.push(this);
		}
	}

	public function onInit() {
		sound = SoundSystem.instance.getSound(soundSrc);
		if (playOnInit) {
			SoundSystem.instance.playSound(sound, pos.x, true);
		}
	}

	public function onDeath() {
		SoundSystem.instance.playSound(sound, pos.x, true);
	}

	public function onDamage(dmg: Float) {
		SoundSystem.instance.playSound(sound, pos.x, true);
	}
}
