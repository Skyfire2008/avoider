package org.skyfire2008.avoider.game;

class PlayerProps {
	public static var instance(default, null): PlayerProps;

	public var blinkDist(default, null): Float;

	public static function setInstance(inst: PlayerProps) {
		PlayerProps.instance = inst;
	}

	public function new(blinkDist: Float) {
		this.blinkDist = blinkDist;
	}

	public function update(time: Float) {}
}
