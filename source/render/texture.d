module render.texture;
version(Client):

import imageformats;

import std.math;

import render.screen: Pixel;

Texture wall, bunny;

void initTextures() {
	wall = Texture(read_png_from_mem(cast(const(ubyte[])) import("wall.png"), ColFmt.RGBA));
	bunny = Texture(read_png_from_mem(cast(const(ubyte[])) import("bunny.png"), ColFmt.RGBA));
}

struct Texture {
	IFImage img;
	
	this(IFImage img) {
		this.img = img;
	}

	Pixel sample(double u, double v) {
		uint x = cast(uint) (u * img.w);
		uint y = cast(uint) (v * img.h);
		// This assumes width is 32 to do bit magic
		uint off = (x << 2) + (y << 7);
		return *(cast(Pixel*) &(img.pixels[off]));
	}
}