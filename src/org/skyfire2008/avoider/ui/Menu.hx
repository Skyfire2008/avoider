package org.skyfire2008.avoider.ui;

import knockout.Knockout;

class Menu {
	public static var instance: Menu;

	public static function setInstance(instance: Menu) {
		Menu.instance = instance;
	}

	public function new() {}

	public static function register() {
		Knockout.components.register("avoider-menu", {
			viewModel: function(params: Dynamic, componentInfo: Dynamic) {
				return instance;
			},
			template: "
			<div>Avoider</div>
			<div>
				<button>New Game</button>
				<button>Tutorial</button>
				<button>Settings</button>
				<button>Leaderboards</button>
			</div>
			"
		});
	}
}
