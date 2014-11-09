import fisica.*;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map.Entry;

final float TIME_STEP = .05;

LinkedList<GameObject> objects;
LinkedList<GameObject> objectsToRemove;
LinkedList<GameObject> objectsToAdd;

int WIDTH = 1280;
int HEIGHT = 500;

GameObject[][] gos = {

    {new FinalPlatform(WIDTH - 70 , HEIGHT, 60, 32), new Player(50, 50, 32)},
    {new Player(50, 50, 32), new MovingPlatform(width/2, width, 0, height, 200, 32 )}
};
int level = 0;

FWorld world;
boolean[] keys;

float globalTime;
int countOfPress;

void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	world.setEdges();
	world.setGravity(0,1e3);
}

void mousePressed() {
	if(mouseButton == LEFT)
		print(countOfPress + ": " + mouseX + " " + mouseY + " ");
}

void mouseReleased(){
	if(mouseButton == LEFT) {
		println(mouseX + " " + mouseY);
		countOfPress++;
	}

}

void initElse() {
	keys = new boolean[4]; //0 = E, 1 = N, 2 = W, 3 = S
	objects = new LinkedList<GameObject>();
	objectsToRemove = new LinkedList<GameObject>();
	objectsToAdd = new LinkedList<GameObject>();
}

void incrementLevel() {
}

void loadLevel() {
	for(GameObject go: gos[level]) {
		go.init();
		objects.add(go);
	}
}



void updateWorld() {
	world.step();
	for(GameObject go : objects){
		go.update();
	}

	objects.removeAll(objectsToRemove);
	objects.addAll(objectsToAdd);
	objectsToRemove.clear();
	objectsToAdd.clear();
	globalTime += TIME_STEP;
}


void drawWorld() {
	background(255,0,0);
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

Player p;
Spike s;
void setup() {
	size(1280,500,OPENGL);
	initFisica();
	initElse();
	loadLevel();
}

void draw() {
	// if(frameCount == 1)
	// 	loadLevel();
	updateWorld();
	drawWorld();
}

abstract class GameObject {

	final static String MOVING_PLATFORM_NAME = "mplat";
	final static String FINAL_PLATFORM_NAME = "fplat";
	final static String PLATFORM_NAME = "plat";
	final static String PLAYER_NAME = "player";
	final static String SPIKE_NAME = "spike";

	FBox body;
	float x, y, sx, sy;

	GameObject(float x, float y, float sx, float sy) {
		this.sx = sx;
		this.sy = sy;
		this.x = x;
		this.y = y;
	}

	void init() {
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

	@Override
	void init() {
		super.init();
		body.setStatic(true);
	}

	Moving(float x, float y, float sx, float sy) {
		this(x, x, y, y, sx, sy);
	}

}

class Player extends GameObject {
	final static int JUMP_CALL_COUNT_MAX = 40;
	final static float DEATH_SIZE_THRESHOLD = 10;

	boolean dead = false;

	Player(float x, float y, float s) {
		super(x,y,s,s);
	}

	boolean lastJump = false;
	int jumpCallCount = 0;

	@Override
	void init() {
		super.init();
		body.setName(PLAYER_NAME);
		body.setFriction(0);
	}

	@Override
	void update() {

		ArrayList<FBody> bodiesTouching = body.getTouching();
		if(lastJump){
			if(jumpCallCount >= JUMP_CALL_COUNT_MAX){
				jumpCallCount = 0;
				lastJump = false;
			}
			jumpCallCount++;
		}
		for(FBody fb : bodiesTouching){
			if(keys[1]) {
				if(fb.getY() > body.getY() && !fb.isSensor() && !lastJump) {
					lastJump = true;
					body.setVelocity(body.getVelocityY(), -500);
					body.adjustAngularVelocity(random(-10,10));
					break;
				}	
			}
			if(fb.getName() == SPIKE_NAME) {
				split();
			}
			else if(fb.getName() == FINAL_PLATFORM_NAME) {
				dead = true;
				world.remove(body);
				body.removeFromWorld();
				
			}
			else if(fb.getName() != PLAYER_NAME && !keys[0] && !keys[2]) {
				body.setVelocity(0, body.getVelocityY());
			}
		}

		if(keys[0]) body.setVelocity(150, body.getVelocityY());
		if(keys[2]) body.setVelocity(-150, body.getVelocityY());
	}

	private void split() {
		objectsToRemove.add(this);
		if(sx > DEATH_SIZE_THRESHOLD && !dead) {
			dead = true;
			Player a = new Player(body.getX() + sx/2, body.getY(), sx/sqrt(2));
			Player b = new Player(body.getX() - sx/2, body.getY(), sx/sqrt(2));

			a.init();
			b.init();

			a.body.setVelocity(300,body.getVelocityY());
			b.body.setVelocity(-300,body.getVelocityY());
			a.body.adjustAngularVelocity(random(-10,10));
			b.body.adjustAngularVelocity(random(-10,10));
			objectsToAdd.add(a);
			objectsToAdd.add(b);
		}
		world.remove(body);
		body.removeFromWorld();
	}
};

class MovingPlatform extends Moving {
	MovingPlatform(float minx, float maxx, float miny, float maxy, float sx, float sy) {
		super(minx, maxx, miny, maxy, sx, sy);
	}
	MovingPlatform(float x, float y, float sx, float sy){
		this(x, x, y, y, sx, sy);
	}

	@Override
	void init() {
		super.init();
		body.setName(MOVING_PLATFORM_NAME);
	}

	@Override
	void update() {
		body.setPosition(map(sin(globalTime), -1, 1, minx, maxx), map(sin(globalTime), -1, 1, miny, maxy));
	}

};

class FinalPlatform extends Moving {
	FinalPlatform(float x, float y, float sx, float sy) {
		super(x, y, sx, sy);
	}

	@Override
	void init() {
		super.init();
		body.setName(FINAL_PLATFORM_NAME);
		body.setFill(0,0,255);
	}

};

class Spike extends Moving {
	FPoly poly;
	float spikeDown;
	Spike(float minx, float maxx, float miny, float maxy, float sx, float sy, float spikeDown) {
		super(minx, maxx, miny, maxy, sx, sy);
		this.spikeDown = spikeDown;
	}

	@Override
	void init() {
		super.init();
		sensorize();
		initTriangularBody();
	}

	private void initTriangularBody() {
		poly = new FPoly();
		poly.vertex(minx - sx/2, miny - sy/2 * spikeDown);
		poly.vertex(minx + sx/2, miny - sy/2 * spikeDown);
		poly.vertex(minx, miny + sy/2 * spikeDown);
		poly.setStatic(true);
		poly.setName(SPIKE_NAME);
		poly.setNoStroke();
		world.add(poly);
	}

	@Override
	void update() {
		poly.setPosition(map(sin(globalTime), -1, 1, minx, maxx), map(sin(globalTime), -1, 1, miny, maxy));
	}
};