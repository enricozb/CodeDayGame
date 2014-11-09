import fisica.*;

FWorld world;
boolean[] keys;

void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	world.setEdges();
	world.setGravity(0,1e3);
}

void initElse() {
	keys = new boolean[4]; //0 = E, 1 = N, 2 = W, 3 = S
}

void updateWorld() {
	world.step();
}

void drawWorld() {
	world.draw();
}

void keyPressed() {
	switch(keyCode) {
		case RIGHT: keys[0] = true; break;
		case UP: keys[1] = true; break;
		case LEFT: keys[2] = true; break;
		case DOWN: keys[3] = true; break; 
	}
}

void keyReleased() {
	switch(keyCode) {
		case RIGHT: keys[0] = false; break;
		case UP: keys[1] = false; break;
		case LEFT: keys[2] = false; break;
		case DOWN: keys[3] = false; break; 
	}
}

void setup() {
	size(1280,720,OPENGL);
	initFisica();
	initElse();
}

void draw() {
	updateWorld();
	drawWorld();
}

abstract class GameObject {
	FBox body;
	GameObject(float x, float y, float sx, float sy) {
		body = new FBox(sx, sy);
		body.setPosition(x, y);
		body.setNoStroke();
		world.add(body);
	}

	void sensorize() {
		body.setSensor(true);
		body.setStatic(true);
		body.setNoFill();
	}

	void update() {} //To be imlemented in subclasses
};

class Player extends GameObject {
	Player(float x, float y, float s) {
		super(x,y,s,s);
	}

	@Override
	void update() {

	}
};

class Spike extends GameObject {
	Spike(float x, float y, float sx, float sy) {
		super(x,y,sx,sy);
		sensorize();
	}

	@Override
	void update() {

	}
}