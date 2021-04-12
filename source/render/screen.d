module render.screen;
version(Client):

import derelict.opengl3.gl3;
import derelict.sdl2.sdl;

import std.conv;
import std.format;

import input.movement;
import render.level;
import render.text;

enum int WIDTH = 960, HEIGHT = 720;
enum int INTERNAL_WIDTH = 320, INTERNAL_HEIGHT = 240;
//enum int INTERNAL_WIDTH = 160, INTERNAL_HEIGHT = 120;

private:

SDL_Window* window;
SDL_GLContext context;

Pixel[INTERNAL_WIDTH * INTERNAL_HEIGHT] framebuffer;
GLuint framebufferTexture;
GLuint framebufferFbo;

public:

shared string debugText;

int fpsDisplay = 60;

struct Pixel {
	ubyte r, g, b;
}

void initScreen() {
	DerelictSDL2.load();
	DerelictGL3.load();
	if (SDL_Init(SDL_INIT_VIDEO) < 0) {
		throw new Exception("Failed to intialize SDL " ~ to!string(SDL_GetError()));
	}
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MAJOR_VERSION, 3);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_MINOR_VERSION, 2);
	SDL_GL_SetAttribute(SDL_GL_CONTEXT_PROFILE_MASK, SDL_GL_CONTEXT_PROFILE_CORE);
	SDL_GL_SetAttribute(SDL_GL_RED_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_GREEN_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_BLUE_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_ALPHA_SIZE, 8);
	SDL_GL_SetAttribute(SDL_GL_DEPTH_SIZE, 24);
	SDL_GL_SetAttribute(SDL_GL_DOUBLEBUFFER, 1);
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLEBUFFERS, 0);
    SDL_GL_SetAttribute(SDL_GL_MULTISAMPLESAMPLES, 0);
	window = SDL_CreateWindow("Retro Shooter", SDL_WINDOWPOS_CENTERED, SDL_WINDOWPOS_CENTERED, WIDTH, HEIGHT, SDL_WINDOW_OPENGL | SDL_WINDOW_HIDDEN);
	if (!window) {
		throw new Exception("Failed to create an SDL window " ~ to!string(SDL_GetError()));
	}
	context = SDL_GL_CreateContext(window);
	DerelictGL3.reload();

	glGenTextures(1, &framebufferTexture);
	glBindTexture(GL_TEXTURE_2D, framebufferTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, INTERNAL_WIDTH, INTERNAL_HEIGHT, 0, GL_RGB, GL_UNSIGNED_BYTE, &(framebuffer[0]));

	glGenFramebuffers(1, &framebufferFbo);
	glBindFramebuffer(GL_READ_FRAMEBUFFER, framebufferFbo);
	glFramebufferTexture2D(GL_READ_FRAMEBUFFER, GL_COLOR_ATTACHMENT0, GL_TEXTURE_2D, framebufferTexture, 0);

	initLevelRenderer();

	drawScreen();
	SDL_ShowWindow(window);

	SDL_SetRelativeMouseMode(SDL_TRUE);
}

void setPixel(int x, int y, Pixel p) {
	framebuffer[x + ((INTERNAL_HEIGHT - 1) - y) * INTERNAL_WIDTH] = p;
}

bool pollScreen() {
	static SDL_Event e;
	while (SDL_PollEvent(&e) != 0) {
		if (e.type == SDL_QUIT) {
			return true;
		} else if (e.type == SDL_WINDOWEVENT) {
			if (e.window.event == SDL_WINDOWEVENT_CLOSE) {
				return true;
			}
		} else if (e.type == SDL_KEYDOWN) {
			if (e.key.keysym.sym == SDLK_w) {
				moveForward = true;
			} else if (e.key.keysym.sym == SDLK_a) {
				moveLeft = true;
			} else if (e.key.keysym.sym == SDLK_s) {
				moveBackward = true;
			} else if (e.key.keysym.sym == SDLK_d) {
				moveRight = true;
			} else if (e.key.keysym.sym == SDLK_LEFT) {
				turnLeft = true;
			} else if (e.key.keysym.sym == SDLK_RIGHT) {
				turnRight = true;
			} else if (e.key.keysym.sym == SDLK_ESCAPE) {
				SDL_SetRelativeMouseMode(SDL_FALSE);
			}
		} else if (e.type == SDL_KEYUP) {
			if (e.key.keysym.sym == SDLK_w) {
				moveForward = false;
			} else if (e.key.keysym.sym == SDLK_a) {
				moveLeft = false;
			} else if (e.key.keysym.sym == SDLK_s) {
				moveBackward = false;
			} else if (e.key.keysym.sym == SDLK_d) {
				moveRight = false;
			} else if (e.key.keysym.sym == SDLK_LEFT) {
				turnLeft = false;
			} else if (e.key.keysym.sym == SDLK_RIGHT) {
				turnRight = false;
			}
		} else if (e.type == SDL_MOUSEBUTTONDOWN) {
			if (e.button.button == SDL_BUTTON_LEFT) {
				SDL_SetRelativeMouseMode(SDL_TRUE);
			}
		} else if (e.type == SDL_MOUSEMOTION) {
			if (SDL_GetRelativeMouseMode()) {
				int xo = e.motion.xrel;
				playerRotation += xo / 500.0;
			}
		}
	}
	return false;
}

void drawScreen() {
	glClearColor(1.0, 0.6, 0.9, 1.0);
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

	//import std.datetime.stopwatch;
	//StopWatch sw;
	//sw.start();
	drawLevel();
	//import std.stdio: writeln;
	//writeln(sw.peek.total!"msecs", " ms to draw level");
	drawText("%s fps".format(fpsDisplay), 2, 2);
	drawText(debugText, 2, 20);

	glBindTexture(GL_TEXTURE_2D, framebufferTexture);
	glTexImage2D(GL_TEXTURE_2D, 0, GL_RGB, INTERNAL_WIDTH, INTERNAL_HEIGHT, 0, GL_RGB, GL_UNSIGNED_BYTE, &(framebuffer[0]));

	glDisable(GL_MULTISAMPLE);
	glBindFramebuffer(GL_READ_FRAMEBUFFER, framebufferFbo);
	glBindFramebuffer(GL_DRAW_FRAMEBUFFER, 0);
	glBlitFramebuffer(0, 0, INTERNAL_WIDTH, INTERNAL_HEIGHT, 0, 0, WIDTH, HEIGHT, GL_COLOR_BUFFER_BIT, GL_NEAREST);

	SDL_GL_SwapWindow(window);
}