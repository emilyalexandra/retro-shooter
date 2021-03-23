module render.level;
version(Client):

import std.algorithm: min, max;
import std.math;

import render.screen;
import render.texture;
import util.math;

Square[] squares = [
	Square(Vec3(0, 0, 1), Vec3(0, 0, 1).normalize(), null, -1, -1, 1, 1, true),
	Square(Vec3(0, 0, 7.9), Vec3(0.4, 0, 1).normalize(), null, -2, -2, 2, 2, true),
];

Vec3[INTERNAL_HEIGHT][INTERNAL_WIDTH] cachedProjections; 

Vec3[INTERNAL_WIDTH] cachedHorizontalProjections; 

static this(){
	for (int x = 0; x < INTERNAL_WIDTH; x++) {
		cachedHorizontalProjections[x] = Vec3((cast(double) x / INTERNAL_WIDTH - 0.5) * 1.4, 0, 1).normalize();
		for (int y = 0; y < INTERNAL_HEIGHT; y++) {
			cachedProjections[x][y] = Vec3((cast(double) x / INTERNAL_WIDTH - 0.5) * 1.4, (cast(double) y / INTERNAL_WIDTH - 0.5) * 1.86, 1).normalize();
		}
	}
	squares[0].texture = &wall;
	squares[1].texture = &bunny;
}

void drawLevel() {
	static double angle = 0, angle2 = 0;
	angle += 0.05;
	angle2 += 0.031;
	squares[0].planeNormal = Vec3(cos(angle), 0, sin(angle)).normalize();
	squares[0].plane.z = 5 + sin(angle2) * 4;

	Vec3 origin = Vec3(0, 0, 0);
	for (int x = 0; x < INTERNAL_WIDTH; x++) {
		Vec3 proj = cachedHorizontalProjections[x];
		// Probably bigger than it'll ever need to be
		static RenderStrip[10] strips;
		int stripIndex = 0;
		int stripTop = INTERNAL_HEIGHT, stripBottom = 0;
		foreach (Square square; squares) {
			Vec3 point = getIntersection(square.plane, square.planeNormal, origin, proj);
			Vec3 diff = square.plane - point;
			diff.y = (square.minY + square.maxY) / 2;
			double horizontalMagnitude = diff.magnitude;
			if (horizontalMagnitude < square.maxX) {
				double mag = (origin - point).magnitude;
				if ((point.x < square.plane.x) ^ (square.planeNormal.dot(proj) < 0)) {
					horizontalMagnitude = -horizontalMagnitude;
				}
				int u = cast(int) ((square.maxX + horizontalMagnitude) * TEXTURE_WIDTH / (square.maxX * 2));
				double vert = INTERNAL_HEIGHT / mag; 
				int minY = cast(int) (INTERNAL_HEIGHT / 2 - vert * square.maxY);
				int maxY = cast(int) (INTERNAL_HEIGHT / 2 + vert * -square.minY);
				int minV = 0, maxV = TEXTURE_WIDTH;
				int height = maxY - minY;
				if (minY < 0) {
					minV = -minY * TEXTURE_WIDTH / height;
					minY = 0;
				}
				if (maxY >= INTERNAL_HEIGHT) {
					maxV = (height - (maxY - INTERNAL_HEIGHT)) * TEXTURE_WIDTH / height;
					maxY = INTERNAL_HEIGHT;
				}
				strips[stripIndex++] = RenderStrip(minY, maxY, mag, u, minV, maxV, square.texture);
				stripTop = min(minY, stripTop);
				stripBottom = max(maxY, stripBottom);
				if (!square.renderThrough) {
					break;
				}
			}
		}
		stripTop = max(0, stripTop);
		stripBottom = min(INTERNAL_HEIGHT, stripBottom);
		// Prevent double rendering of blank pixels
		stripBottom = max(stripTop, stripBottom);

		for (int y = 0; y < stripTop; y++) {
			setPixel(x, y, Pixel(0, 0, 0));
		}
		static double[INTERNAL_HEIGHT] depths;
		depths = double.max;
		for (int i = 0; i < stripIndex; i++) {
			RenderStrip strip = strips[i];
			int height = strip.max - strip.min;
			int vRange = strip.maxV - strip.minV;
			for (int y = strip.min; y < strip.max; y++) {
				if (strip.depth < depths[y]) {
					depths[y] = strip.depth;
					int v = (y - strip.min) * vRange / height + strip.minV;
					// TODO there is a bug in the maxV generation that makes its range from 0-32 instead of 0-31, figure that out so this can go
					if (v >= 32) {
						v = 31;
					}
					setPixel(x, y, strip.texture.sample(strip.u, v));
				}
			}
		}
		for (int y = stripBottom; y < INTERNAL_HEIGHT; y++) {
			setPixel(x, y, Pixel(0, 0, 0));
		}
	}
}

Vec3 getIntersection(Vec3 plane, Vec3 planeNormal, Vec3 point, Vec3 projection) {
	double t = (planeNormal.dot(plane) - planeNormal.dot(point)) / planeNormal.dot(projection);
	return point + projection * Vec3(t, t, t);
}

struct Square {
	Vec3 plane, planeNormal;
	Texture* texture;
	double minX, minY, maxX, maxY;
	bool renderThrough;
}

struct RenderStrip {
	int min, max;
	double depth;
	int u;
	int minV, maxV;
	Texture* texture;
}