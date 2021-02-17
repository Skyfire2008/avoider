package org.skyfire2008.avoider.game;

import js.html.EventTarget;
import js.html.KeyboardEvent;
import js.lib.Map;
import js.lib.Set;

import org.skyfire2008.avoider.game.components.Interfaces.KBComponent;

typedef KeyBindings = {
	var up: String;
	var left: String;
	var right: String;
	var down: String;
};

typedef DownAction = () -> Void;
typedef HeldAction = (Float) -> Void;

class Controller {
	private var heldKeys: Set<String>;

	private var downActions: Map<String, DownAction>;
	private var upActions: Map<String, DownAction>;
	private var heldActions: Map<String, HeldAction>;

	private var components: Array<KBComponent>;

	public var pauseAction: DownAction;

	public static var instance(default, null): Controller;

	public function new(config: KeyBindings) {
		downActions = new Map<String, DownAction>();
		upActions = new Map<String, DownAction>();
		heldActions = new Map<String, HeldAction>();
		components = [];
		heldKeys = new Set<String>();

		remap(config);
	}

	public static function setInstance(instance: Controller) {
		Controller.instance = instance;
	}

	public function reset() {
		components = [];
	}

	public function addComponent(component: KBComponent) {
		components.push(component);
	}

	public function removeComponent(component: KBComponent) {
		components.remove(component);
	}

	public function remap(config: KeyBindings) {
		heldActions.clear();

		downActions.clear();
		downActions.set(config.up, () -> {
			for (component in components) {
				component.addDir(0, -1);
			}
		});
		downActions.set(config.left, () -> {
			for (component in components) {
				component.addDir(-1, 0);
			}
		});
		downActions.set(config.down, () -> {
			for (component in components) {
				component.addDir(0, 1);
			}
		});
		downActions.set(config.right, () -> {
			for (component in components) {
				component.addDir(1, 0);
			}
		});

		upActions.clear();
		upActions.set(config.up, () -> {
			for (component in components) {
				component.addDir(0, 1);
			}
		});
		upActions.set(config.left, () -> {
			for (component in components) {
				component.addDir(1, 0);
			}
		});
		upActions.set(config.down, () -> {
			for (component in components) {
				component.addDir(0, -1);
			}
		});
		upActions.set(config.right, () -> {
			for (component in components) {
				component.addDir(-1, 0);
			}
		});
	}

	private function onKeyDown(e: KeyboardEvent) {
		var downAction = downActions.get(e.code);
		if (downAction != null && !heldKeys.has(e.code)) {
			downAction();
		}

		heldKeys.add(e.code);
	}

	private function onKeyUp(e: KeyboardEvent) {
		heldKeys.delete(e.code);
		var action = upActions.get(e.code);
		if (action != null) {
			action();
		}
	}

	public function update(time: Float) {
		for (key in heldKeys.iterator()) {
			var action = heldActions.get(key);
			if (action != null) {
				action(time);
			}
		}
	}

	public function register(target: EventTarget) {
		target.addEventListener("keydown", onKeyDown);
		target.addEventListener("keyup", onKeyUp);
	}

	public function deregister(target: EventTarget) {
		target.removeEventListener("keydown", onKeyDown);
		target.removeEventListener("keyup", onKeyUp);
	}
}
