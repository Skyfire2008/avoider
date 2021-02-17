package org.skyfire2008.avoider.util;

import js.html.XMLHttpRequest;
import js.html.ProgressEvent;
import js.lib.Promise;

class Util {
	public static inline function max(a: Int, b: Int): Int {
		return a > b ? a : b;
	}

	public static inline function min(a: Int, b: Int): Int {
		return a < b ? a : b;
	}

	public static inline function sgn(a: Float): Int {
		var result: Int = 0;
		if (a != 0) {
			result = (a > 0) ? 1 : -1;
		}
		return result;
	}

	public static inline function rand(val: Float): Float {
		return val * (Math.random() - 0.5);
	}

	public static inline function fetchFile(path: String): Promise<String> {
		return new Promise<String>((resolve, reject) -> {
			var xhr = new XMLHttpRequest();
			xhr.addEventListener("load", (e: ProgressEvent) -> {
				resolve(xhr.responseText);
			});
			xhr.addEventListener("error", () -> {
				reject('Could not fetch file $path');
			});
			xhr.open("GET", path);
			xhr.send();
		});
	}
}
