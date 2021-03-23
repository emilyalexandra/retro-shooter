import std.format;
import std.stdio;
import std.datetime.stopwatch;

import render.screen;
import render.texture;

void main() {
	version(Client) {
		initTextures();
		initScreen();
	}
	gameLoop();
}

void gameLoop() {
	int ticks = 0;
	StopWatch sw;
	sw.start();
	while (true) {
		version(Client) {
			if (pollScreen()) {
				return;
			}
			drawScreen();
		}
		ticks++;
		if (sw.peek > dur!"msecs"(1000)) {
			writeln("%s ticks passed in a second".format(ticks));
			ticks = 0;
			sw.setTimeElapsed(sw.peek - dur!"msecs"(1000));
		}
	}
}
