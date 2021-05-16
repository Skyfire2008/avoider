package org.skyfire2008.avoider.graphics;

import js.html.webgl.Program;
import js.html.webgl.RenderingContext;
import js.html.webgl.GL;
import js.html.webgl.extension.OESVertexArrayObject;
import js.html.webgl.Shader;
import js.html.webgl.UniformLocation;

// adapted from TDS
class Renderer {
	public var gl(default, null): RenderingContext;
	private var ext: OESVertexArrayObject;
	private var prog: Program;

	private var rotationLoc: UniformLocation;
	private var posLoc: UniformLocation;
	private var scaleLoc: UniformLocation;
	private var colorMultLoc: UniformLocation;
	private var blackRectangle: Shape;

	public static var instance(default, null): Renderer;

	public var trailsEnabled = false;

	public static function setInstance(instance: Renderer) {
		Renderer.instance = instance;
	}

	public function new(gl: RenderingContext, vertSrc: String, fragSrc: String) {
		this.gl = gl;
		ext = gl.getExtension("OES_vertex_array_object");
		prog = Renderer.initGLProgram(gl, vertSrc, fragSrc);

		trace(gl.getExtension("OES_element_index_uint"));

		gl.clearColor(0.0, 0.0, 0.0, 1.0);

		posLoc = gl.getUniformLocation(prog, "pos");
		rotationLoc = gl.getUniformLocation(prog, "rotation");
		scaleLoc = gl.getUniformLocation(prog, "scale");
		colorMultLoc = gl.getUniformLocation(prog, "colorMult");

		blackRectangle = new Shape([0, 0, 0, 720, 1280, 0, 1280, 720], [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], [0, 1, 2, 1, 2, 3]);
		blackRectangle.init(gl);
	}

	public inline function start() {
		gl.useProgram(prog);
	}

	public inline function clear() {
		if (!trailsEnabled) {
			gl.clear(GL.COLOR_BUFFER_BIT);
		} else {
			gl.blendFunc(GL.ONE, GL.CONSTANT_COLOR);

			render(blackRectangle, 0, 0, 0, 1, [1, 1, 1]);
			gl.uniform2f(scaleLoc, 1, 1);
			gl.uniform1f(rotationLoc, 0);
			gl.uniform2f(posLoc, 0, 0);
			gl.uniform3f(colorMultLoc, 1, 1, 1);

			ext.bindVertexArrayOES(blackRectangle.vao);

			gl.drawElements(GL.TRIANGLES, blackRectangle.indexNum, GL.UNSIGNED_INT, 0);
			gl.blendFunc(GL.ONE, GL.ZERO);
		}
	}

	public inline function render(shape: Shape, posX: Float, posY: Float, rotation: Float, scale: Float, colorMult: ColorMult) {
		gl.uniform2f(scaleLoc, scale, scale);
		gl.uniform1f(rotationLoc, rotation);
		gl.uniform2f(posLoc, posX, posY);
		gl.uniform3f(colorMultLoc, colorMult.r, colorMult.g, colorMult.b);

		ext.bindVertexArrayOES(shape.vao);

		gl.drawElements(GL.LINES, shape.indexNum, GL.UNSIGNED_INT, 0);
	}

	public static function initGLProgram(gl: RenderingContext, vertSrc: String, fragSrc: String): Program {
		var result = gl.createProgram();

		var vert = Renderer.loadShader(gl, GL.VERTEX_SHADER, vertSrc);
		var frag = Renderer.loadShader(gl, GL.FRAGMENT_SHADER, fragSrc);

		gl.attachShader(result, vert);
		gl.attachShader(result, frag);

		gl.bindAttribLocation(result, 0, "vert"); // TODO: don't hardcode this
		gl.bindAttribLocation(result, 1, "rgb");

		gl.linkProgram(result);

		if (!gl.getProgramParameter(result, GL.LINK_STATUS)) {
			throw "Error while linking the program: " + gl.getProgramInfoLog(result);
		}

		trace(gl.getAttribLocation(result, "rgb"));

		return result;
	}

	public static inline function loadShader(gl: RenderingContext, type: Int, src: String): Shader {
		var result: Shader = gl.createShader(type);
		gl.shaderSource(result, src);
		gl.compileShader(result);

		if (!gl.getShaderParameter(result, GL.COMPILE_STATUS)) {
			throw "Error occurred while compiling shader: " + gl.getShaderInfoLog(result);
		}

		return result;
	}
}
