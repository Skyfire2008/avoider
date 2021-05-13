package org.skyfire2008.avoider.game.components;

import spork.core.Component;

import org.skyfire2008.avoider.spatial.Collider;

interface UpdateComponent extends Component {
	@callback
	function onUpdate(time: Float): Void;
}

interface InitComponent extends Component {
	@callback
	function onInit(): Void;
}

@singular
interface IsAliveComponent extends Component {
	@callback
	function isAlive(): Bool;
	@callback
	function kill(): Void;
}

interface DeathComponent extends Component {
	@callback
	function onDeath(): Void;
}

interface CollisionComponent extends Component {
	@callback
	function onCollide(other: Collider): Void;
}

interface KBComponent {
	function addDir(x: Float, y: Float): Void;
	function setWalk(value: Bool): Void;
	function blink(x: Float, y: Float): Void;
}

interface DamageComponent extends Component {
	@callback
	function onDamage(dmg: Int): Void;
}

interface HealComponent {
	@callback
	function onHeal(heal: Int): Void;
}
