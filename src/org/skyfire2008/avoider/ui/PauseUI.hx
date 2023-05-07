package org.skyfire2008.avoider.ui;

import knockout.Knockout;
import knockout.Observable;

import org.skyfire2008.avoider.util.StorageLoader;

@:keep
class PauseUI {
	public static var instance(default, null): PauseUI;

	public var isDisplayed(default, null): Observable<Bool>;
	private var hideText: Observable<String>;

	public static function setInstance(instance: PauseUI) {
		PauseUI.instance = instance;
	}

	public function new() {
		isDisplayed = Knockout.observable(false);
		hideText = Knockout.observable();
		sub(StorageLoader.instance.data);
		StorageLoader.instance.subscribe(sub);
	}

	private function sub(data) {
		var key = data.keyBindings.pause;
		if (key != null) {
			var spaceReg = ~/([a-z])([A-Z0-9])/g;
			var lrReg = ~/(.+)(Left|Right)/g;
			key = spaceReg.replace(lrReg.replace(key, "$2$1"), "$1 $2");
			hideText.set('Press ${key} to unpause');
		} else {
			hideText.set('Assign a pause key...');
		}
	}

	private function dispose() {
		StorageLoader.instance.unsubscribe(sub);
	}

	public static function register() {
		Knockout.components.register("pauseui", {
			viewModel: {
				createViewModel: () -> {
					return instance;
				}
			},
			template: "
				<!-- ko if: isDisplayed -->
					<div class='ui'>
						<div class='pauseWrapper'>
							<div class='pauseMessage'>Paused</div>
							<div data-bind='text: hideText'></div>
							<settings></settings>
						</div>
					</div>
				<!-- /ko -->
			"
		});
	}
}
