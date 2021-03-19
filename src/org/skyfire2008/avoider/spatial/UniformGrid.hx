package org.skyfire2008.avoider.spatial;

import haxe.ds.Vector;

import polygonal.ds.HashSet;
import polygonal.ds.IntHashSet;

import org.skyfire2008.avoider.geom.Rectangle;
import org.skyfire2008.avoider.geom.Point;

using Lambda;

/**
 * ...
 * @author
 */
class UniformGrid {
	private var cells: Vector<List<Collider>>;
	private var dirtyCells: IntHashSet;

	public var width(default, null): Int;
	public var height(default, null): Int;
	public var cellWidth(default, null): Int;
	public var cellHeight(default, null): Int;

	public function new(width: Int, height: Int, cellWidth: Int, cellHeight: Int) {
		this.width = width;
		this.height = height;
		this.cellWidth = cellWidth;
		this.cellHeight = cellHeight;

		this.cells = new Vector<List<Collider>>(width * height);
		for (i in 0...width * height) {
			this.cells.set(i, new List<Collider>());
		}

		this.dirtyCells = new IntHashSet(43);
	}

	public function add(elem: Collider): Void {
		var rect = elem.rect();

		var startX: Int = Std.int(rect.x / cellWidth);
		startX = startX < 0 ? 0 : startX;

		var startY: Int = Std.int(rect.y / cellHeight);
		startY = startY < 0 ? 0 : startY;

		var endX: Int = Std.int(rect.right / cellWidth);
		endX = endX > width - 1 ? width - 1 : endX;
		endX++;

		var endY: Int = Std.int(rect.bottom / cellHeight);
		endY = endY > height - 1 ? height - 1 : endY;
		endY++;

		for (x in startX...endX) {
			for (y in startY...endY) {
				var ind = cellIndex(x, y);
				cells[ind].add(elem);
				dirtyCells.set(ind);
			}
		}
	}

	public function queryLine(p0: Point, p1: Point): Array<Collider> {
		// uses the Fast Voxel Traversal Algorithm for Ray Tracing: https://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.42.3443&rep=rep1&type=pdf
		// starting cell
		var x = Std.int(p0.x / cellWidth);
		x = (x == width) ? width - 1 : x;
		var y = Std.int(p0.y / cellHeight);
		y = (y == height) ? height - 1 : y;

		// end cell
		var endX = Std.int(p1.x / cellWidth);
		endX = (endX == width) ? width - 1 : endX;
		var endY = Std.int(p1.y / cellHeight);
		endY = (endY == height) ? height - 1 : endY;

		// vector p0->p1
		var v = Point.difference(p1, p0);

		// indicate the direction of traversal
		var stepX = p1.x >= p0.x ? 1 : -1;
		var stepY = p1.y >= p0.y ? 1 : -1;

		// how much does it take to traverse a cell horizontally/vertically in terms of t
		// where t is parameter of line equation p(t)=p0+(p1-p0)t
		var tDeltaX = stepX * cellWidth / v.x;
		var tDeltaY = stepY * cellHeight / v.y;

		// distance to next horizontal border in t
		var tMaxX: Float;
		if (!Math.isFinite(tDeltaX)) { // special case for infinite tDeltaX: tMaxX is set to infinity, cause if p0.x is on cell border, it may result in 0/0 = NaN
			tMaxX = Math.POSITIVE_INFINITY;
		} else if (stepX > 0) {
			tMaxX = ((x + 1) * cellWidth - p0.x) / v.x;
		} else {
			tMaxX = (x * cellWidth - p0.x) / v.x;
		}

		// distance to next vertical border in t
		var tMaxY: Float;
		if (!Math.isFinite(tDeltaY)) {
			tMaxY = Math.POSITIVE_INFINITY;
		} else if (stepY > 0) {
			tMaxY = ((y + 1) * cellHeight - p0.y) / v.y;
		} else {
			tMaxY = (y * cellHeight - p0.y) / v.y;
		}

		var result: Array<Collider> = [];
		while (true) {
			var current = cells[cellIndex(x, y)];
			for (col in current.iterator()) {
				if (col.intersectsLine(p0, p1)) {
					result.push(col);
				}
			}

			if (x == endX && y == endY) {
				break;
			}

			if (tMaxX < tMaxY) {
				tMaxX += tDeltaX;
				x += stepX;
			} else {
				tMaxY += tDeltaY;
				y += stepY;
			}
		}
		return result;
	}

	public function queryRect(rect: Rectangle): Array<Collider> {
		var startX: Int = Std.int(rect.x / cellWidth);
		startX = startX < 0 ? 0 : startX;

		var startY: Int = Std.int(rect.y / cellHeight);
		startY = startY < 0 ? 0 : startY;

		var endX: Int = Std.int(rect.right / cellWidth);
		endX = endX > width - 1 ? width - 1 : endX;
		endX++;

		var endY: Int = Std.int(rect.bottom / cellHeight);
		endY = endY > height - 1 ? height - 1 : endY;
		endY++;

		var res: HashSet<Collider> = new HashSet<Collider>(17, 17);
		for (x in startX...endX) {
			for (y in startY...endY) {
				var ind = cellIndex(x, y);

				cells[ind].iter(function(elem: Collider) {
					if (rect.intersects(elem.rect())) {
						res.set(elem);
					}
				});
			}
		}

		return res.toArray();
	}

	public function reset(): Void {
		for (i in dirtyCells) {
			cells[i] = new List<Collider>();
		}
		dirtyCells.clear();
	}

	private inline function cellIndex(x: Int, y: Int): Int {
		return x + y * width;
	}
}
