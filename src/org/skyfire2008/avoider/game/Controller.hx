package org.skyfire2008.avoider.game;

import js.html.FocusEvent;
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
	private var mouseMoveActions: Array<MouseAction>;

	private var components: Array<KBComponent>;

	public static var instance(default, null): Controller;

	public function new(config: KeyBindings) {
		downActions = new Map<String, DownAction>();
		upActions = new Map<String, DownAction>();
		heldActions = new Map<String, HeldAction>();
		components = [];
		heldKeys = new Set<String>();
		mouseDownActions = new Map<Int, MouseAction>();
		mouseUpActions = new Map<Int, MouseAction>();
		mouseMoveActions = [];

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
		heldActions.clear();
		heldActions.set(config.up, (time) -> {
			for (component in components) {
				component.setDirY(-1);
			}
		});
		heldActions.set(config.left, (time) -> {
			for (component in components) {
				component.setDirX(-1);
			}
		});
		heldActions.set(config.down, (time) -> {
			for (component in components) {
				component.setDirY(1);
			}
		});
		heldActions.set(config.right, (time) -> {
			for (component in components) {
				component.setDirX(1);
			}
		});

		downActions.set(config.bulletTime, () -> {
			for (component in components) {
				component.setTimeStretch(true);
			}
		});
		downActions.set(config.blink, () -> {
			for (component in components) {
				component.blink();
			}
		});
		downActions.set(config.slowdown, () -> {
			for (component in components) {
				component.setWalk(true);
			}
		});
		downActions.set(config.pause, Game.instance.togglePause);

		upActions.clear();
		upActions.set(config.bulletTime, () -> {
			for (component in components) {
				component.setTimeStretch(false);
			}
		});
		upActions.set(config.slowdown, () -> {
			for (component in components) {
				component.setWalk(false);
			}
		});

		mouseDownActions.clear();
		mouseDownActions.set(0, (x: Float, y: Float) -> {
			for (component in components) {
				component.blink();
			}
		});
		mouseDownActions.set(2, (x: Float, y: Float) -> {
			for (component in components) {
				component.setWalk(true);
			}
		});

		mouseUpActions.clear();
		mouseUpActions.set(2, (x: Float, y: Float) -> {
			for (component in components) {
				component.setWalk(false);
			}
		});

		mouseMoveActions = [];
		mouseMoveActions.push((x: Float, y: Float) -> {
			for (component in components) {
				component.onMouseMove(x, y);
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

	private function onMouseMove(e: MouseEvent) {
		for (action in mouseMoveActions) {
			action(e.clientX, e.clientY);
		}
	}

	private function onBlur(e: FocusEvent) {
		Game.instance.setState(Paused);

		heldKeys.clear();
	}

	public function update(time: Float) {
		for (key in heldKeys.iterator()) {
			var action = heldActions.get(key);
			if (action != null) {
				action(time);
			}
		}
	}

	public function register(target: EventTarget, blurEventTarget: EventTarget) {
		target.addEventListener("keydown", onKeyDown);
		target.addEventListener("keyup", onKeyUp);

		// TODO: add support for mouse buttons to settings
		target.addEventListener("mousedown", onMouseDown);
		target.addEventListener("mouseup", onMouseUp);
		target.addEventListener("mousemove", onMouseMove);

		blurEventTarget.addEventListener("blur", onBlur);
	}

	public function deregister(target: EventTarget) {
		target.removeEventListener("keydown", onKeyDown);
		target.removeEventListener("keyup", onKeyUp);
	}
}
