package org.skyfire2008.avoider.util;

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
	public static function copyDir(src: String, dst: String): Void {
		if (!FileSystem.exists(dst)) {
			FileSystem.createDirectory(dst);
		}

		for (file in FileSystem.readDirectory(src)) {
			var curSrcPath = Path.join([src, file]);
			var curDstPath = Path.join([dst, file]);

			if (FileSystem.isDirectory(curSrcPath)) {
				copyDir(curSrcPath, curDstPath);
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
}
#end
