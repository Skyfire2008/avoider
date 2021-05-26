package org.skyfire2008.avoider;

import org.skyfire2008.avoider.game.SoundSystem;

import howler.Howl;

import org.skyfire2008.avoider.game.TargetingSystem;

import js.html.ButtonElement;
import js.Browser;
import js.lib.Promise;
import js.html.Document;
import js.html.Element;
import js.html.CanvasElement;
import js.html.webgl.GL;

import haxe.Json;
import haxe.ds.StringMap;

import spork.core.JsonLoader;
import spork.core.JsonLoader.EntityFactoryMethod;

import org.skyfire2008.avoider.game.components.CausesGameOver;
import org.skyfire2008.avoider.game.SpawnSystem;
import org.skyfire2008.avoider.game.ScoringSystem;
import org.skyfire2008.avoider.game.Constants;
import org.skyfire2008.avoider.game.Controller;
import org.skyfire2008.avoider.game.Game;
import org.skyfire2008.avoider.graphics.Renderer;
import org.skyfire2008.avoider.graphics.Shape;
import org.skyfire2008.avoider.util.Util;
import org.skyfire2008.avoider.util.StorageLoader;
import org.skyfire2008.avoider.util.Scripts.DirContent;
import org.skyfire2008.avoider.geom.Point;

using Lambda;

class Main {
	private static var document: Document;
	private static var gl: GL;

	private static var running: Bool = true;
	private static var prevTime: Float = -1;
	private static var timeStore: Float = 0;
	private static var timeCount: Float = 0;

	private static var mainCanvas: Element;
	private static var playerHpDisplay: Element;
	private static var blinkBar: Element;
	private static var scoreDisplay: Element;
	private static var multDisplay: Element;
	private static var multBar: Element;
	private static var gameOverStuff: Element;
	private static var restartButton: ButtonElement;

	public static function main() {
		Browser.window.addEventListener("load", init);
	}

	private static function onEnterFrameFirst(timestamp: Float) {
		prevTime = timestamp;
		Browser.window.requestAnimationFrame(onEnterFrame);
	}

	private static function onEnterFrame(timestamp: Float) {
		var delta = (timestamp - prevTime) / 1000;
		timeStore += delta;
		timeCount++;
		if (timeCount >= 600) {
			trace("fps: " + timeCount / timeStore);
			timeStore = 0;
			timeCount = 0;
		}
		prevTime = timestamp;

		if (running) {
			Controller.instance.update(delta);
			Game.instance.update(delta);
		}
		Browser.window.requestAnimationFrame(onEnterFrame);
	}

	private static function init() {
		document = Browser.document;

		document.addEventListener('contextmenu', e -> e.preventDefault());
		mainCanvas = document.getElementById("mainCanvas");
		gl = cast(mainCanvas, CanvasElement).getContextWebGL({preserveDrawingBuffer: true});
		if (gl == null) {
			Browser.alert("WebGL is not supported!");
		}
		gl.enable(GL.BLEND);
		gl.blendFunc(GL.ONE, GL.ONE);
		gl.blendColor(0.95, 0.95, 0.95, 0);

		// get elements
		playerHpDisplay = document.getElementById("playerHpDisplay");
		blinkBar = document.getElementById("blinkBar");
		scoreDisplay = document.getElementById("scoreDisplay");
		multDisplay = document.getElementById("multDisplay");
		multBar = document.getElementById("multBar");
		gameOverStuff = document.getElementById("gameOverStuff");
		restartButton = cast(document.getElementById("restartButton"));
		restartButton.addEventListener("click", (e) -> {
			gameOverStuff.style.display = "none";
			Game.instance.reset();
			TargetingSystem.instance.reset();
			ScoringSystem.instance.reset();
			SpawnSystem.instance.reset();
			Game.instance.addEntity(Game.instance.entMap.get("player.json")((holder) -> {
				holder.position = new Point(Constants.gameWidth / 2, Constants.gameHeight / 2);
			}));
			Game.instance.addEntity(Game.instance.entMap.get("bgEnt.json")(), true);
		});

		CausesGameOver.init(() -> {
			gameOverStuff.style.display = "block";
		});

		ScoringSystem.setInstance(new ScoringSystem((score) -> {
			scoreDisplay.innerText = "Score: " + score;
		}, (mult) -> {
			multDisplay.innerText = "Mult : " + mult;
		}, (value) -> {
			multBar.style.width = Std.int(value * 100) + "%";
		}));
		ScoringSystem.instance.reset();

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
			var soundsDir = contents.find((item) -> {
				return item.path == "sounds";
			});

			// load all sounds
			var sounds: StringMap<Howl> = new StringMap<Howl>();
			for (kid in soundsDir.kids) {
				loadPromises.push(new Promise<String>((resolve, reject) -> {
					var howl = new Howl({
						src: ["assets/sounds/" + kid.path],
						onload: () -> {
							trace("loaded " + kid.path);
							resolve(null);
						}
					});
					sounds.set(kid.path, howl);
				}));
			}
			SoundSystem.setInstance(new SoundSystem(sounds));

			// load all shapes
			var shapes: StringMap<Shape> = new StringMap<Shape>();
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
				Shape.setShapes(shapes);
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
					var game = new Game(entFactories, (value) -> {
						playerHpDisplay.innerText = "Lives: " + value;
					}, (value) -> {
						blinkBar.style.width = Std.int(value * 100) + "%";
					});
					Game.setInstance(game);

					SpawnSystem.setInstance(new SpawnSystem());

					var storage = new StorageLoader();
					StorageLoader.setInstance(storage);

					var controller = new Controller(storage.data.keyBindings, () -> {
						running = !running;
					});
					controller.register(document);
					Controller.setInstance(controller);

					// init components
					org.skyfire2008.avoider.game.components.ChaserBehaviour.init();
					org.skyfire2008.avoider.game.components.ShooterBehaviour.init();
					org.skyfire2008.avoider.game.components.HowitzerBehaviour.init();
					org.skyfire2008.avoider.game.components.ControlComponent.init();

					game.addEntity(Game.instance.entMap.get("player.json")((holder) -> {
						holder.position = new Point(Constants.gameWidth / 2, Constants.gameHeight / 2);
					}));
					game.addEntity(entFactories.get("bgEnt.json")(), true);

					SpawnSystem.instance.reset();

					/*for (i in 0...50) {
						game.addEntity(entFactories.get("shooter.json")((holder) -> {
							holder.position = new Point(Std.random(Constants.gameWidth), Std.random(Constants.gameHeight));
						}));
					}*/

					Browser.window.requestAnimationFrame(onEnterFrameFirst);
				});
			});
		});
	}
}
