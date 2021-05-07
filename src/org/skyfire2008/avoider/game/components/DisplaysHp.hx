package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;
import spork.core.PropertyHolder;

class DisplaysHp implements Interfaces.InitComponent implements Interfaces.DamageComponent implements Interfaces.HealComponent {
	private var hp: Wrapper<Int>;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		this.hp = holder.hp;
	}

	public function onInit() {
		Game.instance.livesCallback(hp.value);
	}

	public function onDamage(dmg: Int) {
		Game.instance.livesCallback(hp.value);
	}

	public function onHeal(heal: Int) {
		Game.instance.livesCallback(hp.value);
	}
}
