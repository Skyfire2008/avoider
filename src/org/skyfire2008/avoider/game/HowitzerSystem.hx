package org.skyfire2008.avoider.game;

import haxe.ds.IntMap;

class HowitzerSystem {
	public static var instance(default, null): HowitzerSystem;

	public static function setInstance(inst: HowitzerSystem) {
		instance = inst;
	}

	private var impactMap: IntMap<IntMap<Int>>;

	public function new() {
		impactMap = new IntMap<IntMap<Int>>();
	}

	public function addImpact(id: Int) {
		impactMap.set(id, new IntMap<Int>());
	}

	public function addTarget(impactId: Int, targetId: Int) {
		impactMap.get(impactId).set(targetId, targetId);
	}

	public function removeImpactCountTargets(id: Int): Int {
		var map = impactMap.get(id);

		var result = 0;
		for (i in map.keys()) {
			result++;
		}

		impactMap.remove(id);
		return result;
	}
}
