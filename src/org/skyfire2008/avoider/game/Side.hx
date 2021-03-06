package org.skyfire2008.avoider.game;

@:enum
abstract Side(String) from String to String {
	var Player = "Player";
	var Enemy = "Enemy";
	var Hostile = "Hostile";

	public static inline function isValid(value: String): Bool {
		switch (value) {
			case Player:
				return true;
			case Enemy:
				return true;
			case Hostile:
				return true;
			default:
				return false;
		}
	}

	public function opposite(): Side {
		switch (this) {
			case Player:
				return Enemy;
			case Enemy:
				return Player;
			case Hostile:
				return Hostile;
			default:
				return null;
		}
	}
}
