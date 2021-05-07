package org.skyfire2008.avoider.game.components;

import spork.core.Wrapper;
import spork.core.PropertyHolder;

class HasHp implements Interfaces.IsAliveComponent implements Interfaces.DamageComponent implements Interfaces.HealComponent {
	private var hp: Wrapper<Int>;
	private var maxHp: Int;

	public function new() {}

	public function assignProps(holder: PropertyHolder) {
		hp = holder.hp;
		maxHp = hp.value;
	}

	public function onDamage(dmg: Int) {
		hp.value -= dmg;
	}

	public function onHeal(heal: Int) {
		hp.value += heal;
		if (hp.value > maxHp) {
			hp.value = maxHp;
		}
	}

	public function isAlive(): Bool {
		return hp.value > 0;
	}

	public function kill() {
		owner.onDamage(hp.value);
	}
}
