module render.level;
version(Client):

import std.algorithm: min, max;
import std.math;

import render.screen;
import render.texture;
import util.math;

Square[] squares = [
	Square(Vec3(0, 0, 7), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(2, 0, 7), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(3, 0, 6), Vec3(-1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(4, 0, 5), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(6, 0, 5), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(8, 0, 5), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(9, 0, 6), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(9, 0, 4), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(9, 0, 2), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-1, 0, 8), Vec3(-1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-2, 0, 9), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-4, 0, 9), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-6, 0, 9), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-8, 0, 9), Vec3(0, 0, 1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-9, 0, 8), Vec3(-1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-9, 0, 6), Vec3(-1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-9, 0, 4), Vec3(-1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-9, 0, 2), Vec3(-1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-9, 0, 0), Vec3(-1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(0, 0, -9), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(9, 0, 0), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(8, 0, -1), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(6, 0, -1), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(5, 0, -2), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(5, 0, -4), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(5, 0, -6), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(5, 0, -8), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(6, 0, -9), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(4, 0, -9), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(2, 0, -9), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-2, 0, -9), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-4, 0, -9), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-6, 0, -9), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-7, 0, -8), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-7, 0, -6), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-7, 0, -4), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-8, 0, -3), Vec3(0, 0, -1).normalize(), -1, -1, 1, 1, true),
	Square(Vec3(-9, 0, -2), Vec3(1, 0, 0).normalize(), -1, -1, 1, 1, true),
];

enum LIGHTING_VECTOR = Vec3(0.3, 0.1, -0.8).normalize();

Vec3[INTERNAL_HEIGHT][INTERNAL_WIDTH] cachedProjections; 

Vec3[INTERNAL_WIDTH] cachedHorizontalProjections; 

void initLevelRenderer() {
	for (int x = 0; x < INTERNAL_WIDTH; x++) {
		cachedHorizontalProjections[x] = Vec3((cast(double) x / INTERNAL_WIDTH - 0.5) * 1.4, 0, 1).normalize();
		for (int y = 0; y < INTERNAL_HEIGHT; y++) {
			cachedProjections[x][y] = Vec3((cast(double) x / INTERNAL_WIDTH - 0.5) * 1.4, (cast(double) y / INTERNAL_WIDTH - 0.5) * 1.86, 1).normalize();
		}
	}
	//squares[0].texture = &wall;
	//squares[1].texture = &bunny;
	for (int i = 0; i < squares.length; i++) {
		squares[i].texture = &wall;
	}
}

void drawLevel() {

	import input.movement: playerPosition, playerRotation;
	Vec3 origin = playerPosition;
	double sinTheta = sin(playerRotation);
	double cosTheta = cos(playerRotation);
	for (int x = 0; x < INTERNAL_WIDTH; x++) {
		Vec3 proj = cachedHorizontalProjections[x];
		double px = proj.x, pz = proj.z;
		proj.x = px * cosTheta + pz * sinTheta;
		proj.z = pz * cosTheta - px * sinTheta;

		// Probably bigger than it'll ever need to be
		static RenderStrip[10] strips;
		int stripIndex = 0;
		int stripTop = INTERNAL_HEIGHT, stripBottom = 0;
		foreach (Square square; squares) {
			Vec3 point = getIntersection(square.plane, square.planeNormal, origin, proj);
			Vec3 diff = square.plane - point;
			diff.y = (square.minY + square.maxY) / 2;
			double horizontalMagnitude = diff.magnitude;
			if (proj.dot(point - origin) > 0 && horizontalMagnitude < square.maxX) {
				double mag = (origin - point).magnitude;
				if (square.planeOrientation.dot(diff) < 0) {
					horizontalMagnitude = -horizontalMagnitude;
				}
				int lighting = 255 - cast(int) (-(square.planeNormal.dot(LIGHTING_VECTOR) - 1) * 30);
				int u = cast(int) ((square.maxX + horizontalMagnitude) * TEXTURE_WIDTH / (square.maxX * 2));
				double vert = INTERNAL_HEIGHT / mag; 
				int minY = cast(int) (INTERNAL_HEIGHT / 2 - vert * square.maxY);
				int maxY = cast(int) (INTERNAL_HEIGHT / 2 + vert * -square.minY);
				int minV = 0, maxV = TEXTURE_WIDTH;
				int height = maxY - minY;
				if (height == 0) {
					height = 1;
				}
				if (minY < 0) {
					minV = -minY * TEXTURE_WIDTH / height;
					minY = 0;
				}
				if (maxY >= INTERNAL_HEIGHT) {
					maxV = (height - (maxY - INTERNAL_HEIGHT)) * TEXTURE_WIDTH / height;
					maxY = INTERNAL_HEIGHT;
				}
				strips[stripIndex++] = RenderStrip(minY, maxY, mag, lighting, u, minV, maxV, square.texture);
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
			setPixel(x, y, Pixel(95, 64, 37));
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
					Pixel p = strip.texture.sample(strip.u, v);
					p.r = p.r * 255 / strip.lighting;
					p.g = p.g * 255 / strip.lighting;
					p.b = p.b * 255 / strip.lighting;
					setPixel(x, y, p);
				}
			}
		}
		for (int y = stripBottom; y < INTERNAL_HEIGHT; y++) {
			setPixel(x, y, Pixel(76, 66, 56));
		}
	}
}

Vec3 getIntersection(Vec3 plane, Vec3 planeNormal, Vec3 point, Vec3 projection) {
	double t = (planeNormal.dot(plane) - planeNormal.dot(point)) / planeNormal.dot(projection);
	return point + projection * Vec3(t, t, t);
}

struct Square {
	Vec3 plane, planeNormal;
	Vec3 planeOrientation;
	Texture* texture;
	double minX, minY, maxX, maxY;
	bool renderThrough;

	this(Vec3 plane, Vec3 planeNormal, double minX, double minY, double maxX, double maxY, bool renderThrough) {
		this.plane = plane;
		this.planeNormal = planeNormal;
		this.minX = minX;
		this.minY = minY;
		this.maxX = maxX;
		this.maxY = maxY;
		this.renderThrough = renderThrough;
		double sinTheta = sin(-PI_2);
		double cosTheta = cos(-PI_2);
		double px = planeNormal.x, pz = planeNormal.z;
		planeOrientation = Vec3(px * cosTheta + pz * sinTheta, planeNormal.y, pz * cosTheta - px * sinTheta);
	}
}

struct RenderStrip {
	int min, max;
	double depth;
	int lighting;
	int u;
	int minV, maxV;
	Texture* texture;
}