package org.skyfire2008.avoider.util;

import org.skyfire2008.avoider.game.Constants;
import org.skyfire2008.avoider.graphics.Shape.ShapeJson;

#if macro
import haxe.Json;
import haxe.io.Path;

import sys.io.File;
import sys.FileSystem;
#end

typedef DirContent = {
	path: String,
	kids: Array<DirContent>
};

#if macro
class Scripts {
	// I use initialization macros instead of writing scripts
	public static function copyDir(src: String, dst: String, ?filter: String): Void {
		var reg: EReg = null;
		if (filter != null) {
			reg = new EReg(filter, "i");
		}

		if (!FileSystem.exists(dst)) {
			FileSystem.createDirectory(dst);
		}

		for (file in FileSystem.readDirectory(src)) {
			// skip if filter defined and filename doesn't match it
			if (reg != null && !reg.match(file)) {
				continue;
			}

			var curSrcPath = Path.join([src, file]);
			var curDstPath = Path.join([dst, file]);

			if (FileSystem.isDirectory(curSrcPath)) {
				copyDir(curSrcPath, curDstPath, filter);
			} else {
				File.copy(curSrcPath, curDstPath);
			}
		}
	}

	private static function getContent(parent: String, path: String): DirContent {
		var result: DirContent = {
			path: path,
			kids: []
		};
		var parentPath = Path.join([parent, path]);

		for (file in FileSystem.readDirectory(parentPath)) {
			if (FileSystem.isDirectory(Path.join([parentPath, file]))) {
				result.kids.push(getContent(parentPath, file));
			} else {
				result.kids.push({path: file, kids: null});
			}
		}

		return result;
	}

	public static function createContentsJson(path: String): Void {
		var contents: Array<DirContent> = [];

		for (file in FileSystem.readDirectory(path)) {
			if (FileSystem.isDirectory(Path.join([path, file]))) {
				contents.push(getContent(path, file));
			} else {
				contents.push({path: file, kids: null});
			}
		}

		var output = File.write(Path.join([path, "contents.json"]), false);
		output.writeString(Json.stringify(contents, "   "));
		output.close();
	}

	public static function makeBgShape(path: String, step: Int, color1: String, color2: String): Void {
		// if (!FileSystem.exists(path)) {
		var shape: ShapeJson = {
			points: [],
			lines: []
		};

		// border
		/*shape.points.push({x: 0, y: 0, color: color2});
			shape.points.push({x: Constants.gameWidth, y: 0, color: color2});
			shape.points.push({x: 0, y: Constants.gameHeight, color: color2});
			shape.points.push({x: Constants.gameWidth, y: Constants.gameHeight, color: color2});

			shape.lines.push({from: 0, to: 1});
			shape.lines.push({from: 1, to: 3});
			shape.lines.push({from: 3, to: 2});
			shape.lines.push({from: 2, to: 0}); */

		// grid
		var pointNum = 0;
		var endNum: Int = Std.int(Constants.gameWidth / step);
		for (i in 1...endNum) {
			shape.points.push({x: i * step + 0.5, y: 0 - step, color: color2});
			shape.points.push({x: i * step + 0.5, y: Constants.gameHeight * 0.5, color: color1});
			shape.points.push({x: i * step + 0.5, y: Constants.gameHeight + step, color: color2});

			shape.lines.push({from: pointNum, to: pointNum + 1});
			shape.lines.push({from: pointNum + 1, to: pointNum + 2});
			pointNum += 3;
		}

		endNum = Std.int(Constants.gameHeight / step);
		for (i in 1...endNum) {
			shape.points.push({y: i * step + 0.5, x: 0 - step, color: color2});
			shape.points.push({y: i * step + 0.5, x: Constants.gameWidth * 0.5, color: color1});
			shape.points.push({y: i * step + 0.5, x: Constants.gameWidth + step, color: color2});

			shape.lines.push({from: pointNum, to: pointNum + 1});
			shape.lines.push({from: pointNum + 1, to: pointNum + 2});
			pointNum += 3;
		}

		var output = File.write(path, false);
		output.writeString(Json.stringify(shape));
		output.close();
	}

	// }
}
#end
