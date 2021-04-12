import core.thread;

import std.format;
import std.stdio;
import std.datetime.stopwatch;

import network.network;
import render.screen;
import render.texture;

void main() {
	version(Client) {
		initTextures();
		initScreen();
	}
	Thread thread = new Thread(&networkThread);
	thread.isDaemon = true;
	thread.start();
	gameLoop();
}

void gameLoop() {
	enum Duration TICK_TIME = dur!"seconds"(1) / 60;
	int ticks = 0;
	StopWatch sw;
	sw.start();
	while (true) {
		version(Client) {
			if (pollScreen()) {
				return;
			}
			import input.movement: tickMovement;
			tickMovement();
			drawScreen();
			ticks++;
			if (sw.peek > dur!"msecs"(1000)) {
				fpsDisplay = ticks;
				ticks = 0;
				sw.setTimeElapsed(sw.peek - dur!"msecs"(1000));
			}
		}
		version(Server) {
			if (sw.peek > TICK_TIME) {
				ticks++;
				if (ticks > 60) {
					ticks = 0;
					//writeln("hi mom");
				}
				sw.setTimeElapsed(sw.peek - TICK_TIME);
			} else {
				Thread.sleep(TICK_TIME - sw.peek);
			}
		}
	}
}
