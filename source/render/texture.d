module render.texture;
version(Client):

import imageformats;

import std.math;
import std.format;
import std.traits;

import render.screen: Pixel;

enum int TEXTURE_WIDTH = 32;

// 32x32
Texture hi, bunny, wall;

// 256x256
Texture font;

void initTextures() {
	// Assign every Texture variable in this module to the imported png file of their name, because I'm lazy
	static foreach(member; __traits(allMembers, render.texture)) {
		static if (__traits(compiles, typeof(__traits(getMember, render.texture, member)))) {
			static if (is(typeof(__traits(getMember, render.texture, member)) == Texture)) {
				mixin(q{
					%s = Texture(read_png_from_mem(cast(const(ubyte[])) import("%s.png"), ColFmt.RGBA));
				}.format(member, member));
			}
		}
	}
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