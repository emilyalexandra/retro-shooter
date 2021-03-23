module render.texture;
version(Client):

import imageformats;

import std.math;

import render.screen: Pixel;

enum int TEXTURE_WIDTH = 32;

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

	Pixel sample(int u, int v) {
		// This assumes width is 32 to do bit magic
		uint off = (u << 2) + (v << 7);
		return *(cast(Pixel*) &(img.pixels[off]));
	}
}