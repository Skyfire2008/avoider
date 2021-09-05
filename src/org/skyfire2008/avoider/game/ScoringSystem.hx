package org.skyfire2008.avoider.game;

import org.skyfire2008.avoider.geom.Point;

class ScoringSystem {
	public static var instance(default, null): ScoringSystem;
	private static inline var multDecay = 6;

	private var scoreCallback: (value: Int) -> Void;
	private var multCallback: (value: Int) -> Void;
	private var multBarCallback: (value: Float) -> Void;
	private var lastScore = 0;
	private var lastScoreTime = 0.0;
	private var lastScoreCount = 0;
	private var playerPos: Point;
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

	public function setPlayerPos(pos: Point) {
		playerPos = pos;
	}

	public function update(time: Float) {
		if (multTime > 0) {
			multTime -= time;
			if (multTime <= 0) {
				resetMult();
			}
			multBarCallback(multTime / multDecay);
		}

		lastScoreTime += time;
		if (lastScoreTime >= 0.1) {
			if (lastScore > 0) {
				var color: Array<Float>;
				var hangTime = 1.0;
				if (lastScoreCount <= 1) {
					color = [0.5, 0.5, 0.5];
				} else if (lastScoreCount <= 3) {
					color = [1, 1, 1];
				} else if (lastScoreCount <= 5) {
					color = [0.5, 1, 0.5];
					hangTime = 2.0;
				} else if (lastScoreCount <= 8) {
					color = [0.5, 0.5, 1];
					hangTime = 3.0;
				} else {
					color = [1, 0.5, 1];
					hangTime = 4.0;
				}

				MessageSystem.instance.createMessage("+" + lastScore, playerPos, {
					appearTime: 0,
					hangTime: hangTime,
					fadeTime: 1.0,
					scale: 3,
					color: color,
					style: Score
				});
			}
			lastScoreTime = 0;
			lastScore = 0;
			lastScoreCount = 0;
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
		lastScore += mult;
		lastScoreCount++;
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
		if (mult > baseMult && playerPos != null) {
			MessageSystem.instance.createMessage("multiplier\nreset", playerPos, {
				appearTime: 0,
				hangTime: 1.0,
				fadeTime: 1.0,
				scale: 4,
				color: [0.8, 0.5, 0.5],
				style: Score
			});
		}
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
