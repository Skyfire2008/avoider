package org.skyfire2008.avoider.game;

import js.html.MouseEvent;
import js.html.EventTarget;
import js.html.KeyboardEvent;
import js.lib.Map;
import js.lib.Set;

import org.skyfire2008.avoider.game.components.Interfaces.KBComponent;
import org.skyfire2008.avoider.util.StorageLoader.KeyBindings;

typedef DownAction = () -> Void;
typedef HeldAction = (Float) -> Void;
typedef MouseAction = (Float, Float) -> Void;

class Controller {
	private var heldKeys: Set<String>;

	private var downActions: Map<String, DownAction>;
	private var upActions: Map<String, DownAction>;
	private var heldActions: Map<String, HeldAction>;
	private var mouseDownActions: Map<Int, MouseAction>;
	private var mouseUpActions: Map<Int, MouseAction>;

	private var components: Array<KBComponent>;

	public var pauseAction: DownAction;

	public static var instance(default, null): Controller;

	public function new(config: KeyBindings) {
		downActions = new Map<String, DownAction>();
		upActions = new Map<String, DownAction>();
		heldActions = new Map<String, HeldAction>();
		components = [];
		heldKeys = new Set<String>();
		mouseDownActions = new Map<Int, MouseAction>();
		mouseUpActions = new Map<Int, MouseAction>();

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

		mouseDownActions.clear();
		mouseDownActions.set(0, (x: Float, y: Float) -> {
			for (component in components) {
				component.blink(x, y);
			}
		});
		mouseDownActions.set(2, (X: Float, y: Float) -> {
			for (component in components) {
				component.setWalk(true);
			}
		});

		mouseUpActions.clear();
		mouseUpActions.set(2, (X: Float, y: Float) -> {
			for (component in components) {
				component.setWalk(false);
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

	private function onMouseDown(e: MouseEvent) {
		var action = mouseDownActions.get(e.button);
		if (e.button == 2) {
			e.stopPropagation();
			e.preventDefault();
		}
		if (action != null) {
			action(e.clientX, e.clientY);
		}
	}

	private function onMouseUp(e: MouseEvent) {
		var action = mouseUpActions.get(e.button);
		if (e.button == 2) {
			e.stopPropagation();
			e.preventDefault();
		}
		if (action != null) {
			action(e.clientX, e.clientY);
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

		// TODO: add support for mouse buttons to settings
		target.addEventListener("mousedown", onMouseDown);
		target.addEventListener("mouseup", onMouseUp);
	}

	public function deregister(target: EventTarget) {
		target.removeEventListener("keydown", onKeyDown);
		target.removeEventListener("keyup", onKeyUp);
	}
}
