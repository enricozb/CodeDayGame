import fisica.*;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map.Entry;

final float TIME_STEP = .05;
final float MAX_COUNT = 1024;
final float LEVEL_PERCENT_THRESHOLD = .8;
final float HEIGHT_STEP = 5;

color[] colors = {color(167,197,189), color(229,221,203), color(192,41,66), color(207,70,71) }; //0-Player, 1-Spikes, 2-EndGate, 3-Platforms

LinkedList<GameObject> objects;
LinkedList<GameObject> objectsToRemove;
LinkedList<GameObject> objectsToAdd;

float currentCount;
float currentHeight;

int WIDTH = 1280;
int HEIGHT = 500;

GameObject[][] gos = {

    {new FinalPlatform(WIDTH - 70 , HEIGHT-15/2f - 5, 60, 15), new Player(50, 50, 32), new TextObject(WIDTH/2, HEIGHT/2, "Survive.")},
    {new Player(50, 450, 32), new MovingPlatform(WIDTH/2, WIDTH/2, HEIGHT/2 - 20, HEIGHT/2 - 20, 32, HEIGHT, 0), new Spike(25,25,210,210,20,20,1, 0), new MovingPlatform(50,50,400,400,100,20,0), new FinalPlatform(WIDTH - 70 , HEIGHT-15/2f - 5, 60, 15)},
    {new Player(50, 50, 32), new MovingPlatform(WIDTH/2, WIDTH, 0, HEIGHT, 200, 32, 0)},
};
int level = 0;

FWorld world;
boolean[] keys;

float globalTime;
int countOfPress;

void initEdges() {
	world.setEdges(colors[3]);
	world.top.setNoStroke();
	world.bottom.setNoStroke();
	world.left.setNoStroke();
	world.right.setNoStroke();
}

void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	initEdges();
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

void nextLevel() {
	currentHeight = 0;
	level++;
	objects.clear();
	world.clear();
	initEdges();
	loadLevel();
}

void loadLevel() {
	currentCount = 0;
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
	if(currentCount/MAX_COUNT >= LEVEL_PERCENT_THRESHOLD && currentHeight >= HEIGHT) {
		nextLevel();
	}
	if(currentHeight/HEIGHT < currentCount/MAX_COUNT){
		currentHeight += HEIGHT_STEP;
	}

	objects.removeAll(objectsToRemove);
	objects.addAll(objectsToAdd);
	objectsToRemove.clear();
	objectsToAdd.clear();
	globalTime += TIME_STEP;
}


void drawWorld() {
	background(82,70,86);
	pushStyle();
	fill(103,139,142);
	rect(0,0,width,currentHeight);
	popStyle();
	world.draw();
	for(GameObject go : objects){
		if(go instanceof TextObject)
			go.draw();
	}
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
	size(1280,500,OPENGL);
	initFisica();
	initElse();
	loadLevel();
	textAlign(CENTER, CENTER);
	stroke(colors[3]);
	noStroke();
}

void draw() {
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

	void draw() {}
};

abstract class Moving extends GameObject{
	float minx, maxx, miny, maxy;
	float offset; 
	Moving(float minx, float maxx, float miny, float maxy, float sx, float sy, float offset) {
		super(minx, miny, sx, sy);
		this.minx = minx;
		this.maxx = maxx;
		this.miny = miny;
		this.maxy = maxy;
		this.offset = offset;
	}

	@Override
	void init() {
		super.init();
		body.setStatic(true);
		body.setFillColor(colors[3]);
	}

	Moving(float x, float y, float sx, float sy) {
		this(x, x, y, y, sx, sy, 0);
	}

};

class TextObject extends GameObject {

	String message;
	TextObject(float x, float y, String message) {
		super(x,y,10,10);
		this.message = message;
	}

	@Override
	void init() {
		super.init();
		sensorize();
	}

	@Override
	void draw() {
		pushStyle();
		fill(255);
		text(message, x, y);
		popStyle();
	}

};

class Player extends GameObject {
	final static int JUMP_CALL_COUNT_MAX = 40;
	final static float DEATH_SIZE_THRESHOLD = 5;

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
		body.setFillColor(colors[0]);
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
			else if(fb.getName() == FINAL_PLATFORM_NAME && !dead) {
				dead = true;
				currentCount += pow(body.getWidth(),2);
				world.remove(body);
				body.removeFromWorld();
			}
			else if(fb.getY() > body.getY() && fb.getName() != PLAYER_NAME && !keys[0] && !keys[2]) {
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

			a.body.setVelocity(300,body.getVelocityY() - 100);
			b.body.setVelocity(-300,body.getVelocityY() - 100);
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

	MovingPlatform(float minx, float maxx, float miny, float maxy, float sx, float sy, float offset) {
		super(minx, maxx, miny, maxy, sx, sy, offset);
	}
	MovingPlatform(float x, float y, float sx, float sy){
		this(x, x, y, y, sx, sy, 0);
	}

	@Override
	void init() {
		super.init();
		body.setName(MOVING_PLATFORM_NAME);
	}

	@Override
	void update() {
		body.setPosition(map(sin(globalTime + offset), -1, 1, minx, maxx), map(sin(globalTime + offset), -1, 1, miny, maxy));
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
		body.setFillColor(colors[2]);
	}

};

class Spike extends Moving {
	FPoly poly;
	float spikeDown;
	Spike(float minx, float maxx, float miny, float maxy, float sx, float sy, float spikeDown, float offset) {
		super(minx, maxx, miny, maxy, sx, sy, offset);
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
		poly.setFillColor(colors[1]);
		world.add(poly);
	}

	@Override
	void update() {
		poly.setPosition(map(sin(globalTime + offset), -1, 1, minx, maxx), map(sin(globalTime + offset), -1, 1, miny, maxy));
	}
};