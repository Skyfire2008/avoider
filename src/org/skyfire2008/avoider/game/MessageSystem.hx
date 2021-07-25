package org.skyfire2008.avoider.game;

import org.skyfire2008.avoider.game.components.CharBehaviour;

import haxe.ds.StringMap;

import js.lib.Object;

import spork.core.Entity;
import spork.core.PropertyHolder;
import spork.core.Wrapper;
import spork.core.Component;

import org.skyfire2008.avoider.game.components.Timed;
import org.skyfire2008.avoider.game.components.RenderComponent;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.graphics.ColorMult;

enum Style {
	Score;
	Message;
}

typedef CharData = {
	var pos: Point;
	var shape: Shape;
};

typedef MessageParams = {
	?scale: Float,
	?spacing: Float,
	?appearTime: Float,
	?hangTime: Float,
	?fadeTime: Float,
	?color: ColorMult,
	?spread: Float,
	?style: Style
}

class MessageSystem {
	public static var instance(default, null): MessageSystem;
	private static inline var chars = "abcdefghijklmnopqrstuvwxyz0123456789+";
	private static var charSize = new Point(4, 5);
	private static var defaultParams: MessageParams = {
		scale: 4,
		spacing: 2,
		appearTime: 0.25,
		hangTime: 1.0,
		fadeTime: 0.5,
		color: [1.0, 1.0, 1.0],
		spread: 0.1,
		style: Style.Message
	};

	private var charSet: StringMap<Shape>;

	public static function setInstance(instance: MessageSystem) {
		MessageSystem.instance = instance;
	}

	public function new() {
		charSet = new StringMap<Shape>();
		for (i in 0...chars.length) {
			var current = chars.charAt(i);
			var currentShape = Shape.getShape('font/${current}.json');
			if (currentShape == null) {
				throw 'No shape for character ${current} found';
			}
			charSet.set(current, currentShape);
		}
	}

	public function createMessage(message: String, pos: Point, params: MessageParams) {
		params = Object.assign({}, defaultParams, params);
		message = message.toLowerCase();
		var dx = charSize.x + params.spacing;
		var dy = charSize.y + params.spacing;

		var currentRow: Array<CharData> = [];
		var chars: Array<CharData> = [];
		var x = 0.0;
		var y = 0.0;
		for (i in 0...message.length) {
			var char = message.charAt(i);
			switch (char) {
				case " ":
					x += dx;
				case "\n":
					y += dy;
					for (data in currentRow) {
						data.pos.x -= x / 2;
					}
					chars = chars.concat(currentRow);
					currentRow = [];
					x = 0;
				default:
					currentRow.push({pos: new Point(x, y), shape: charSet.get(char)});
					x += dx;
			}
		}

		y += dy;
		for (data in currentRow) {
			data.pos.x -= x / 2;
		}
		chars = chars.concat(currentRow);

		// normalize by height
		for (data in chars) {
			data.pos.y -= y / 2;
		}

		// create entities
		for (data in chars) {
			var holder = new PropertyHolder();
			holder.rotation = new Wrapper(0.0);
			holder.scale = new Wrapper(params.scale);
			holder.position = Point.scale(data.pos, params.scale);
			holder.position.add(pos);
			holder.colorMult = [params.color.r, params.color.g, params.color.b];
			holder.timeToLive = new Wrapper(params.appearTime + params.fadeTime + params.hangTime);

			var ent = new Entity("character");
			var compos: Array<Component> = [];
			if (params.style == Message) {
				compos.push(new CharBehaviour(pos, params));
			} else {
				compos.push(new CharBehaviour2(pos, params));
			}
			compos.push(new RenderComponent(data.shape, 0.5));
			compos.push(new Timed());

			for (compo in compos) {
				compo.createProps(holder);
			}
			for (compo in compos) {
				compo.assignProps(holder);
				compo.attach(ent);
			}

			Game.instance.addEntity(ent);
		}
	}
}
