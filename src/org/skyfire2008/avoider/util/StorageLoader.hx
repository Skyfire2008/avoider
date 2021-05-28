package org.skyfire2008.avoider.util;

import haxe.Json;

import js.Browser;
import js.lib.Object;
import js.html.Storage;

typedef KeyBindings = {
	var ?up: String;
	var ?left: String;
	var ?right: String;
	var ?down: String;
	var ?bulletTime: String;
	var ?pause: String;
}

typedef StoredData = {
	var ?keyBindings: KeyBindings;
}

class StorageLoader {
	public static var instance: StorageLoader;
	private static var storageName = "avoider_data";

	private var storage: Storage = null;
	public var data(default, null): StoredData;

	private static var defaultData: StoredData = {
		keyBindings: {
			up: "KeyW",
			left: "KeyA",
			down: "KeyS",
			right: "KeyD",
			bulletTime: "Space",
			pause: "KeyP"
		}
	};

	public static function setInstance(instance: StorageLoader) {
		StorageLoader.instance = instance;
	}

	public function new() {
		var data: StoredData = {};
		try {
			storage = Browser.getLocalStorage();
			data = Json.parse(storage.getItem(storageName));
		} catch (e) {
			trace(e);
		}

		this.data = Object.assign({}, data, defaultData);
	}

	public function save() {
		if (storage != null) {
			storage.setItem(storageName, Json.stringify(this.data));
		}
	}
}
