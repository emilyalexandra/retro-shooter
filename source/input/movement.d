module input.movement;

import std.math;

import util.math;

bool moveLeft, moveRight, moveForward, moveBackward, turnLeft, turnRight;

Vec3 playerPosition = Vec3(0, 0, 0);

double playerRotation = 0;

void tickMovement() {
	if (turnLeft) {
		playerRotation -= 0.05;
	}
	if (turnRight) {
		playerRotation += 0.05;
	}
	if (moveLeft || moveRight || moveForward || moveBackward) {
		double angle;
		int forward, sideways;
		if (moveForward) {
			forward -= 1;
		}
		if (moveBackward) {
			forward += 1;
		}
		if (moveLeft) {
			sideways += 1;
		}
		if (moveRight) {
			sideways -= 1;
		}
		if (forward == 0) {
			angle = PI + sideways * PI_2;
		} else if (sideways == 0) {
			angle = PI_2 + forward * PI_2;
		} else {
			angle = PI_2 + forward * PI_2;
			if (forward > 0) {
				angle += sideways * PI_4;
			} else {
				angle -= sideways * PI_4;
			}
		}
		angle += playerRotation;
		playerPosition = playerPosition + Vec3(sin(angle) * 0.1, 0, cos(angle) * 0.1);
	}
}