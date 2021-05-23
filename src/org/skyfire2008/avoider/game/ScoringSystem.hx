package org.skyfire2008.avoider.game;

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
			multTime = Math.max(0, multTime - time);
			if (multTime == 0) {
				mult = baseMult;
				multCallback(mult);
			}
			multBarCallback(multTime / multDecay);
		}
	}

	public function incBaseMult() {
		baseMult++;
		if (mult < baseMult) {
			mult = baseMult;
			multCallback(mult);
		}
	}

	public function addScore() {
		score += mult;
		mult++;
		multTime = multDecay;
		scoreCallback(score);
		multCallback(mult);
		multBarCallback(multTime / multDecay);
	}

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
