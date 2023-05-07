package org.skyfire2008.avoider.ui;

import js.html.KeyboardEvent;
import js.lib.Object;
import js.html.HtmlElement;

import org.skyfire2008.avoider.game.Controller;
import org.skyfire2008.avoider.util.StorageLoader;

import knockout.Knockout;
import knockout.Observable;

private typedef KeyBindingParams = {
	var action: String;
	var key: Observable<String>;
}

@:keep
private class KeyBinding {
	private static var currentId: Int = 0;

	private var id: String;
	private var action: String;
	private var key: Observable<String>;
	private var isFocused: Observable<Bool>;

	public function new(action: String, key: Observable<String>) {
		this.action = action;
		this.key = key;
		this.id = "keyBinding" + (currentId++);
		isFocused = Knockout.observable(false);
	}

	private function keyText(): String {
		if (isFocused.get()) {
			return "Press a key...";
		} else if (key.get() == null) {
			return "unassigned";
		} else {
			var spaceReg = ~/([a-z])([A-Z0-9])/g;
			var lrReg = ~/(.+)(Left|Right)/g;
			return spaceReg.replace(lrReg.replace(key, "$2$1"), "$1 $2");
		}
	}

	private function getColor() {
		if (isFocused.get()) {
			return "yellow";
		} else if (key.get() == null) {
			return "red";
		} else {
			return null;
		}
	}

	private function onFocus() {
		isFocused.set(true);
	}

	private function onKeyDown(_, e: KeyboardEvent) {
		e.preventDefault();
		e.stopPropagation();
		isFocused.set(false);
		SettingsUI.instance.rebind(action, e.code);
		return false;
	}

	public static function register() {
		Knockout.components.register("key-binding", {
			viewModel: {
				createViewModel: function(params: Dynamic, componentInfo: Dynamic) {
					return new KeyBinding(params.action, params.key);
				}
			},
			template: "
			<label data-bind='text: action, attr: {for: id}' class='bindingLabel'></label>
			<input data-bind='value: keyText(), attr: {id: id}, hasFocus: isFocused, style: {color: getColor()}, event: {focus: onFocus, keydown: onKeyDown}' type='text' class='keyInput'></input>
			"
		});
	}
}

@:keep
class SettingsUI {
	// this instance contains the main Settings menu that can be accessed from the inventory
	public static var instance(default, null): SettingsUI;

	private var keyBindings: Array<KeyBindingParams>;
	private var isDisplayed: Observable<Bool>;
	private var masterVolume: Observable<String>;
	private var musicVolume: Observable<String>;
	private var isMain: Bool;

	public static function setInstance(instance: SettingsUI) {
		SettingsUI.instance = instance;
	}

	public function new(main: Bool) {
		keyBindings = [];
		var data = StorageLoader.instance.data.keyBindings;
		var props = Object.getOwnPropertyNames(data);
		for (action in props) {
			var key: String = untyped data[action];
			keyBindings.push({action: action, key: Knockout.observable(key)});
		}

		isDisplayed = Knockout.observable(!main);
		StorageLoader.instance.subscribe((data) -> {
			var newBindings = data.keyBindings;
			for (binding in keyBindings) {
				binding.key.set(untyped newBindings[binding.action]);
			}

			masterVolume.set("" + data.masterVolume);
			musicVolume.set("" + data.musicVolume);
		});

		masterVolume = Knockout.observable("" + StorageLoader.instance.data.masterVolume);
		masterVolume.subscribe((rawValue) -> {
			var value = Std.parseFloat(rawValue);
			if (StorageLoader.instance.data.masterVolume != value) {
				StorageLoader.instance.data.masterVolume = value;
				StorageLoader.instance.save();
			}
		});
		musicVolume = Knockout.observable("" + StorageLoader.instance.data.musicVolume);
		musicVolume.subscribe((rawValue) -> {
			var value = Std.parseFloat(rawValue);
			if (StorageLoader.instance.data.musicVolume != value) {
				StorageLoader.instance.data.musicVolume = value;
				StorageLoader.instance.save();
			}
		});

		isMain = main;
	}

	public function show() {
		isDisplayed.set(true);
	}

	public function rebind(action: String, key: String) {
		StorageLoader.instance.rebindKey(action, key);
		StorageLoader.instance.save();
		Controller.instance.remap(StorageLoader.instance.data.keyBindings);
	}

	private function goBack() {
		isDisplayed.set(false);
	}

	public static function register() {
		KeyBinding.register();
		Knockout.components.register("settings", {
			viewModel: {
				createViewModel: function(params: Dynamic, componentInfo: Dynamic) {
					var element: HtmlElement = componentInfo.element;
					if (element.attributes.getNamedItem("data-main-settings") != null) {
						return instance;
					} else {
						return new SettingsUI(false);
					}
				}
			},
			template: "
			<!-- ko if: isDisplayed -->
				<div data-bind='css: {ui: isMain}'>
					<div class='settingsWrapper'>
						<div class='settings'>
							<div class='settingsHeader' style='color: #ffff40'>Settings</div>
							<div class='settingsBlocks'>
								<div class='keyBindings'>
									<!-- ko foreach: keyBindings -->
										<key-binding params='action: $data.action, key: $data.key'></key-binding>
									<!-- /ko -->
								</div>
								<div>
									<div class='settingsHeader' style='color: #ffff40'>Sound:</div>
									<div class='volumeSlider'>
										<label>Master volume</label>
										<input type='range' min='0' max='1' step='0.01' data-bind='value: masterVolume'></input>
									</div>
									<div class='volumeSlider'>
										<label>Music volume</label>
										<input type='range' min='0' max='1' step='0.01' data-bind='value: musicVolume'></input>
									</div>
								</div>
							</div>
							<!-- ko if: isMain -->
								<button data-bind='click: goBack'>Return</button>
							<!-- /ko -->
						</div>
					</div>
				</div>
			<!-- /ko -->
			"
		});
	}
}
