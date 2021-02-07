package org.skyfire2008.avoider.game.components;

import spork.core.Component;

interface UpdateComponent extends Component {
	@callback
	function onUpdate(time: Float): Void;
}

interface InitComponent extends Component {
	@callback
	function onInit(): Void;
}

interface DeathComponent extends Component {
	@callback
	function onDeath(): Void;
}
