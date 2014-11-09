import fisica.*;

final float TIME_STEP = .001;

ArrayList<GameObject> objects;
FWorld world;
boolean[] keys;

float globalTime;

void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	world.setEdges();
	world.setGravity(0,1e3);
}

void initElse() {
	keys = new boolean[4]; //0 = E, 1 = N, 2 = W, 3 = S
	objects = new ArrayList<GameObject>();
}

void updateWorld() {
	world.step();
	globalTime += TIME_STEP;
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

abstract class Moving extends GameObject{
	float minx, maxx, miny, maxy;

	Moving(float minx, float maxx, float miny, float maxy, float sx, float sy) {
		super(minx, miny, sx, sy);
		this.minx = minx;
		this.maxx = maxx;
		this.miny = miny;
		this.maxy = maxy;
	}

}

class Player extends GameObject {
	Player(float x, float y, float s) {
		super(x,y,s,s);
	}

	@Override
	void update() {

	}

	private void split() {

	}
};

class Spike extends Moving {

	Spike(float minx, float maxx, float miny, float maxy, float sx, float sy) {
		super(minx, maxx, miny, maxy, sx, sy);
		this.miny = miny;
		this.maxy = maxy;
		sensorize();
		
	}

	@Override
	void update() {
		body.setPosition(minx, map(noise(globalTime), 0, 1, miny, maxy));
	}
};