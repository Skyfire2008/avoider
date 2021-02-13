package org.skyfire2008.avoider.game.components;

import spork.core.Component;

import org.skyfire2008.avoider.game.Game;

interface UpdateComponent extends Component {
	@callback
	function onUpdate(time: Float): Void;
}

interface InitComponent extends Component {
	@callback
	function onInit(): Void;
}

@singular
interface IsAlivecomponent extends Component {
	@callback
	function isAlive(): Bool;
	@callback
	function kill(): Void;
}

interface DeathComponent extends Component {
	@callback
	function onDeath(): Void;
}

interface KBComponent {
	function addDir(x: Float, y: Float): Void;
}
