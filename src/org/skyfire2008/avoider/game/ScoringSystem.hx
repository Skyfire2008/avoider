package org.skyfire2008.avoider.game;

import org.skyfire2008.avoider.util.Util;

class ScoringSystem {
	public static var instance(default, null): ScoringSystem;
	private static inline var multDecay = 6;

	private var scoreCallback: (value: Int) -> Void;
	private var multCallback: (value: Int) -> Void;
	private var multBarCallback: (value: Float) -> Void;
	private var score = 0;
	private var mult = 1;
	private var baseMult = 1;
	private var multTime = 0.0;

	public static function setInstance(instance: ScoringSystem) {
		ScoringSystem.instance = instance;
	}

	public function new(scoreCallback: (value: Int) -> Void, multCallback: (value: Int) -> Void, multBarCallback: (value: Float) -> Void) {
		this.scoreCallback = scoreCallback;
		this.multCallback = multCallback;
		this.multBarCallback = multBarCallback;
	}

	public function update(time: Float) {
		if (multTime > 0) {
			multTime -= time;
			if (multTime <= 0) {
				mult = baseMult;
				multCallback(mult);
				if (mult > baseMult) {
					multTime += multDecay;
				} else {
					multTime = 0;
				}
			}
			multBarCallback(multTime / multDecay);
		}
	}

	public function notifyOfWaveInc() {
		var x = SpawnSystem.instance.wave / 3;
		x = Math.max(x * Math.sqrt(x), 1);
		baseMult = Std.int((x));
		if (mult < baseMult) {
			mult = baseMult;
			multCallback(mult);
		}
	}

	public function addScore() {
		score += mult;
		mult += baseMult;
		multTime = multDecay;
		scoreCallback(score);
		multCallback(mult);
		multBarCallback(multTime / multDecay);
	}

	/*public function reduceMult() {
		mult = Util.max(baseMult, mult >> 1);
		multTime = 0;
		multCallback(mult);
		multBarCallback(multTime / multDecay);
	}*/
	public function resetMult() {
		mult = baseMult;
		multTime = 0;
		multCallback(mult);
		multBarCallback(multTime / multDecay);
	}

	public function reset() {
		baseMult = 1;
		resetMult();
		score = 0;
		scoreCallback(score);
	}
}
