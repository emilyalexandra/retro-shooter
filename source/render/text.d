module render.text;
version(Client):

import render.screen;
import render.texture;
import util.math;

enum Glyph[256] glyphs = genGlyphs();

private Glyph[256] genGlyphs() {
	Glyph[256] ret;
	// Missing char
	ret = Glyph(Vec2i(0, 248), 6);
	ret[' '] = Glyph(Vec2i(6, 248), 4);
	int[] CAPITAL_WIDTHS = [
		6, 6, 6, 6, 5, 5, 7, 6, 5, 6, 6, 5, 8, 7, 6, 6, 7, 6, 6, 7, 6, 6, 8, 6, 7, 6
	];
	int xOff = 0;
	for (int i = 0; i < CAPITAL_WIDTHS.length; i++) {
		ret['A' + i] = Glyph(Vec2i(xOff, 0), CAPITAL_WIDTHS[i]);
		xOff += CAPITAL_WIDTHS[i];
	}
	int[] LOWER_WIDTHS = [
		6, 6, 5, 6, 6, 4, 6, 6, 3, 4, 6, 5, 8, 6, 6, 6, 7, 6, 6, 5, 6, 6, 8, 6, 6, 5
	];
	xOff = 0;
	for (int i = 0; i < LOWER_WIDTHS.length; i++) {
		ret['a' + i] = Glyph(Vec2i(xOff, 8), LOWER_WIDTHS[i]);
		xOff += LOWER_WIDTHS[i];
	}
	int[] NUMBER_WIDTHS = [
		7, 4, 6, 5, 6, 6, 6, 5, 6, 6
	];
	xOff = 0;
	for (int i = 0; i < NUMBER_WIDTHS.length; i++) {
		ret['0' + i] = Glyph(Vec2i(xOff, 16), NUMBER_WIDTHS[i]);
		xOff += NUMBER_WIDTHS[i];
	}
	string SPECIALS = ".,:;'\"!?[](){}/\\|_-+=";
	int[] SPECIAL_WIDTHS = [
		3, 3, 3, 3, 3, 6, 3, 6, 4, 4, 4, 4, 5, 5, 5, 5, 3, 7, 4, 4, 4
	];
	xOff = 0;
	for (int i = 0; i < SPECIAL_WIDTHS.length; i++) {
		ret[SPECIALS[i]] = Glyph(Vec2i(xOff, 24), SPECIAL_WIDTHS[i]);
		xOff += SPECIAL_WIDTHS[i];
	}
	return ret;
}

void drawText(string text, int x, int y, Pixel color = Pixel(255, 255, 255)) {
	int xOff = 0;
	foreach (char c; text) {
		Glyph g = glyphs[c];
		for (int xo = 0; xo < g.width; xo++) {
			for (int yo = 0; yo < 8; yo++) {
				ubyte[4] data = indexFont(g.pos.x + xo, g.pos.y + yo);
				if (data[3] != 0) {
					setPixel(x + xOff + xo, y + yo, color);
				}
			}
		}
		xOff += g.width;
	}
}

ubyte[] indexFont(int x, int y) {
	int off = x * 4 + y * 256 * 4;
	return font.img.pixels[off..off + 4];
}

struct Glyph {
	Vec2i pos;
	int width;
}