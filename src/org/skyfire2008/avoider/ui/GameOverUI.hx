package org.skyfire2008.avoider.ui;

import knockout.DependentObservable;
import knockout.Knockout;
import knockout.Observable;

import org.skyfire2008.avoider.game.Game;
import org.skyfire2008.avoider.game.TargetingSystem;
import org.skyfire2008.avoider.game.ScoringSystem;
import org.skyfire2008.avoider.game.SpawnSystem;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.game.Constants;

@:keep
class GameOverUI {
	public static var instance(default, null): GameOverUI;

	public var isDisplayed(default, null): Observable<Bool>;
	private var calcDisplay: DependentObservable<Bool>;

	public static function setInstance(instance: GameOverUI) {
		GameOverUI.instance = instance;
	}

	public function new() {
		this.isDisplayed = Knockout.observable(false);
		calcDisplay = Knockout.pureComputed(() -> {
			return isDisplayed.get() && !PauseUI.instance.isDisplayed.get();
		});
	}

	private function restart() {
		isDisplayed.set(false);
		Game.instance.reset();
		TargetingSystem.instance.reset();
		ScoringSystem.instance.reset();
		SpawnSystem.instance.reset();
		Game.instance.addEntity(Game.instance.entMap.get("player.json")((holder) -> {
			holder.position = new Point(Constants.gameWidth / 2, Constants.gameHeight / 2);
		}));
		Game.instance.addEntity(Game.instance.entMap.get("bgEnt.json")(), true);
	}

	public static function register() {
		Knockout.components.register("gameoverui", {
			viewModel: {
				createViewModel: () -> {
					return instance;
				}
			},
			template: "
				<!-- ko if: calcDisplay -->
					<div class='display' style='color: red; font-size: 72px; left: 461px; top: 100px'>
						Game Over
					</div>
					<button style='top: 200px; left: 600px; position: absolute;' data-bind='click: restart'>Restart!</button>
				<!-- /ko -->
			"
		});
	}
}
