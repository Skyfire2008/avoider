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

using Lambda;

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

	public function createMessage(message: String, pos: Point, params: MessageParams): Array<Entity> {
		params = Object.assign({}, defaultParams, params);
		message = message.toLowerCase();
		var lines = message.split('\n');
		var lineLengths: Array<Float> = [];

		// calculate the size of message
		var longest = 0.0;
		for (line in lines) {
			var length = line.length * charSize.x + (line.length - 1) * params.spacing;
			lineLengths.push(length);
			if (length > longest) {
				longest = length;
			}
		}

		var msgDim = new Point(longest, lines.length * charSize.y + (lines.length) * params.spacing);
		msgDim.mult(params.scale);

		// fit the message into the screen
		var startPos = pos.copy();
		if (startPos.x - msgDim.x / 2 < 0) {
			startPos.x -= startPos.x - msgDim.x / 2;
		} else if (startPos.x + msgDim.x / 2 > Constants.gameWidth) {
			startPos.x -= Constants.gameWidth - (startPos.x - msgDim.x / 2);
		}
		if (startPos.y - msgDim.y / 2 < 0) {
			startPos.y -= startPos.y - msgDim.y / 2;
		} else if (startPos.y + msgDim.y / 2 > Constants.gameHeight) {
			startPos.y -= Constants.gameHeight - (startPos.y - msgDim.y / 2);
		}

		// get top left position
		msgDim.mult(0.5);
		startPos.sub(msgDim);

		// generate char data
		var chars: Array<CharData> = [];
		for (j in 0...lines.length) {
			var line = lines[j];
			var lineMargin = (longest - lineLengths[j]) / 2;
			for (i in 0...line.length) {
				var char = line.charAt(i);
				if (char != " ") {
					var position = new Point(i * (charSize.x + params.spacing) + lineMargin, j * (charSize.x + params.spacing));
					position.mult(params.scale);
					position.add(startPos);
					chars.push({
						pos: position,
						shape: charSet.get(char)
					});
				}
			}
		}

		// create entities
		var result: Array<Entity> = [];
		for (data in chars) {
			var holder = new PropertyHolder();
			holder.rotation = new Wrapper(0.0);
			holder.scale = new Wrapper(params.scale);
			holder.position = data.pos;
			holder.colorMult = [params.color.r, params.color.g, params.color.b];
			holder.timeToLive = new Wrapper(params.appearTime + params.fadeTime + params.hangTime);

			var ent = new Entity("character");
			var compos: Array<Component> = [];
			if (params.style == Message) {
				compos.push(new CharBehaviour(pos, params));
			} else if (params.style == Score) {
				compos.push(new CharBehaviour2(pos, params));
			}

			compos.push(new Timed());
			compos.push(new RenderComponent(data.shape, 0.5));

			for (compo in compos) {
				compo.createProps(holder);
			}
			for (compo in compos) {
				compo.assignProps(holder);
				compo.attach(ent);
			}

			Game.instance.addEntity(ent);
			result.push(ent);
		}

		return result;
	}
}
