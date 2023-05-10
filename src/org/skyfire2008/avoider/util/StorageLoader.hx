package org.skyfire2008.avoider.util;

import haxe.Json;
import haxe.ds.StringMap;

import js.Browser;
import js.lib.Object;
import js.html.Storage;

typedef KeyBindings = {
	var ?up: String;
	var ?left: String;
	var ?right: String;
	var ?down: String;
	var ?blink: String;
	var ?slowdown: String;
	var ?bulletTime: String;
	var ?pause: String;
}

typedef StoredData = {
	var ?keyBindings: KeyBindings;
	var ?musicVolume: Float;
	var ?masterVolume: Float;
	var ?safeColor: Array<Float>;
	var ?warnColor: Array<Float>;
	var ?dangerColor: Array<Float>;
}

private typedef Callback = (data: StoredData) -> Void;

class StorageLoader {
	public static var instance: StorageLoader;
	private static var storageName = "avoider_data";

	private var storage: Storage = null;
	private var keyActions: StringMap<String>;
	private var subs: Array<Callback> = [];

	public var data(default, null): StoredData;
	public var firstLoad(default, null): Bool;
	public var loadFailed(default, null): Bool;

	private static var defaultData: StoredData = {
		keyBindings: {
			up: "KeyW",
			left: "KeyA",
			down: "KeyS",
			right: "KeyD",
			bulletTime: "Space",
			blink: "KeyF",
			slowdown: "LeftShift",
			pause: "KeyP"
		},
		musicVolume: 0.5,
		masterVolume: 1.0,
		safeColor: [0, 1, 0],
		warnColor: [1, 1, 0],
		dangerColor: [1, 0, 0]
	};

	public static function setInstance(instance: StorageLoader) {
		StorageLoader.instance = instance;
	}

	public function new() {
		var data: StoredData = {};
		try {
			storage = Browser.getLocalStorage();
			data = Json.parse(storage.getItem(storageName));
			loadFailed = false;
			firstLoad = (data == null);
		} catch (e) {
			loadFailed = true;
			firstLoad = true;
			trace(e);
		}

		// assign default values
		this.data = Object.assign({}, defaultData, data);
		keyActions = new StringMap<String>();

		for (action in Object.getOwnPropertyNames(this.data.keyBindings)) {
			keyActions.set(untyped this.data.keyBindings[action], action);
		}

		// save data on first load
		if (!loadFailed && firstLoad) {
			save();
		}
	}

	public function rebindKey(action: String, key: String) {
		// remove the old key bound to this action
		var oldKey = untyped data.keyBindings[action];
		keyActions.remove(oldKey);

		// if there already is an action bound to this key, clear it
		var boundAction = keyActions.get(key);
		if (boundAction != null) {
			untyped data.keyBindings[boundAction] = null;
			keyActions.remove(key);
		}

		untyped data.keyBindings[action] = key;
		keyActions.set(key, action);
	}

	/**
	 * Subscribes to saving of local storage
	 * @param func 	callback function
	 */
	public function subscribe(func: Callback) {
		subs.push(func);
	}

	public function unsubscribe(func: Callback) {
		subs.remove(func);
	}

	public function save() {
		if (storage != null) {
			storage.setItem(storageName, Json.stringify(this.data));
		}

		for (func in subs) {
			func(this.data);
		}
	}
}
