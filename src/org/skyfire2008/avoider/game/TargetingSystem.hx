package org.skyfire2008.avoider.game;

import js.lib.Map;

import org.skyfire2008.avoider.geom.Point;

using js.lib.HaxeIterator;

typedef TargetObserver = (Array<{id: Int, pos: Point}>) -> Void;
typedef TargetDeathObserver = () -> Void;

class TargetingSystem {
	private var targetGroups: Map<String, Map<Int, Point>>;
	private var targetObservers: Map<String, Array<TargetObserver>>;
	private var targetDeathObservers: Map<Int, Array<TargetDeathObserver>>;

	public static var instance(default, null): TargetingSystem = new TargetingSystem();

	private function new() {
		targetGroups = new Map<String, Map<Int, Point>>();
		targetObservers = new Map<String, Array<TargetObserver>>();
		targetDeathObservers = new Map<Int, Array<TargetDeathObserver>>();
	}

	public function reset() {
		targetGroups.clear();
		targetDeathObservers.clear();
		targetObservers.clear();
	}

	public function addTargetGroupObserver(groupName: String, obs: TargetObserver) {
		var group = targetGroups.get(groupName);
		// if group is empty...
		if (group == null || group.size == 0) {
			// add the observer to map
			var observers = targetObservers.get(groupName);
			if (observers == null) {
				targetObservers.set(groupName, [obs]);
			} else {
				observers.push(obs);
			}
		} else {
			// if group is not empty, just call the observer
			var foo: Array<{id: Int, pos: Point}> = [];
			for (entry in group.entries()) {
				foo.push({id: entry.key, pos: entry.value});
			}
			obs(foo);
		}
	}

	public function addTargetDeathObserver(targetId: Int, obs: TargetDeathObserver) {
		var observers = targetDeathObservers.get(targetId);
		if (observers == null) {
			targetDeathObservers.set(targetId, [obs]);
		} else {
			observers.push(obs);
		}
	}

	/**
	 * Adds a new target to be aimed at
	 * @param entId	id of entity that this target represents
	 * @param pos target's position
	 * @param groupName name of target group
	 */
	public function addTarget(entId: Int, pos: Point, groupName: String) {
		var group = targetGroups.get(groupName);
		if (group == null) {
			group = new Map<Int, Point>();
			targetGroups.set(groupName, group);
		}
		// if group was empty previously, notify target group observers
		if (group.size == 0) {
			var observers = targetObservers.get(groupName);
			if (observers != null) {
				for (obs in observers) {
					obs([{id: entId, pos: pos}]);
				}
			}
		}
		group.set(entId, pos);
	}

	public function removeTarget(entId: Int, groupName: String) {
		targetGroups.get(groupName).delete(entId);
		// notify all observers waiting for death of target and remove them
		var observers = targetDeathObservers.get(entId);
		if (observers != null) {
			for (obs in observers) {
				obs();
			}
		}
		targetDeathObservers.delete(entId);
	}
}
