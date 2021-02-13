package org.skyfire2008.avoider;

import js.Browser;
import js.lib.Promise;
import js.html.Document;
import js.html.Element;
import js.html.CanvasElement;
import js.html.KeyboardEvent;
import js.html.webgl.RenderingContext;
import js.html.webgl.GL;

import haxe.Json;
import haxe.ds.StringMap;

import spork.core.JsonLoader;
import spork.core.JsonLoader.EntityFactoryMethod;
import spork.core.PropertyHolder;

import org.skyfire2008.avoider.game.Game;
import org.skyfire2008.avoider.graphics.Renderer;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.util.Scripts.DirContent;
import org.skyfire2008.avoider.geom.Point;
import org.skyfire2008.avoider.game.components.RenderComponent;

using Lambda;

class Main {
	private static var document: Document;
	private static var gl: GL;

	private static var shapes: StringMap<Shape> = new StringMap<Shape>();

	public static function main() {
		Browser.window.addEventListener("load", init);
	}

	private static function init() {
		document = Browser.document;

		gl = cast(document.getElementById("mainCanvas"), CanvasElement).getContextWebGL();
		if (gl == null) {
			Browser.alert("WebGL is not supported!");
		}
		gl.enable(GL.BLEND);
		gl.blendFunc(GL.ONE, GL.ONE);

		// load shaders
		var rendererPromises = [
			Util.fetchFile("assets/shaders/basic.vert"),
			Util.fetchFile("assets/shaders/basic.frag")
		];

		// when shaders are loaded, init renderer
		Promise.all(rendererPromises).then((shaders) -> {
			Renderer.setInstance(new Renderer(gl, shaders[0], shaders[1]));
		});

		var loadPromises: Array<Promise<Dynamic>> = [];
		Util.fetchFile("assets/contents.json").then((text) -> {
			// get contents
			var contents: Array<DirContent> = Json.parse(text);
			var shapesDir = contents.find((item) -> {
				return item.path == "shapes";
			});
			var entsDir = contents.find((item) -> {
				return item.path == "entities";
			});

			// load all shapes
			for (kid in shapesDir.kids) {
				loadPromises.push(Util.fetchFile('assets/shapes/${kid.path}').then((file) -> {
					var shape = Shape.fromJson(Json.parse(file));
					shape.init(gl);
					shapes.set(kid.path, shape);
					return;
				}));
			}

			// when shapes are loaded...
			Promise.all(loadPromises).then((_) -> {
				// init render component
				RenderComponent.setShapes(shapes);
				Renderer.instance.start();

				// load entities
				var entFactories = new StringMap<EntityFactoryMethod>();
				var entPromises: Array<Promise<Void>> = [];
				for (kid in entsDir.kids) {
					entPromises.push(Util.fetchFile('assets/entities/${kid.path}').then((file) -> {
						entFactories.set(kid.path, JsonLoader.makeLoader(Json.parse(file)));
						return;
					}));
				}

				Promise.all(entPromises).then((_) -> {
					var game = new Game(entFactories);
					Game.setInstance(game);
				});
			});
		});
	}
}
