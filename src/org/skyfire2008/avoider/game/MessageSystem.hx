package org.skyfire2008.avoider.game;

import org.skyfire2008.avoider.game.components.Timed;
import org.skyfire2008.avoider.game.components.ChangesColorMult;
import org.skyfire2008.avoider.game.components.RenderComponent;

import haxe.ds.StringMap;

import spork.core.Entity;
import spork.core.PropertyHolder;
import spork.core.Wrapper;
import spork.core.Component;

import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.geom.Point;

typedef CharData = {
	var pos: Point;
	var shape: Shape;
};

class MessageSystem {
	public static var instance(default, null): MessageSystem;
	private static inline var chars = "abcdefghijklmnopqrstuvwxyz";
	private static var charSize = new Point(4, 5);

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

	public function createMessage(message: String, pos: Point, scale: Float, timeToLive: Float, spacing: Float) {
		message = message.toLowerCase();
		var dx = charSize.x + spacing;
		var dy = charSize.y + spacing;

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
					x += dx;
					currentRow.push({pos: new Point(x, y), shape: charSet.get(char)});
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
			holder.scale = new Wrapper(scale);
			holder.position = Point.scale(data.pos, scale);
			holder.position.add(pos);
			holder.colorMult = [1, 1, 1];
			holder.timeToLive = new Wrapper(timeToLive);

			var ent = new Entity("character");
			var compos: Array<Component> = [];
			compos.push(new RenderComponent(data.shape, 0.5));
			compos.push(new ChangesColorMult([1, 1, 1], [0, 0, 0]));
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
