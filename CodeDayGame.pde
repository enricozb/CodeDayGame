import fisica.*;
import ddf.minim.*;

Minim minim;
AudioPlayer song;

import java.util.ArrayList;
import java.util.LinkedList;
import java.util.Map.Entry;

final float TIME_STEP = .03;
final float MAX_COUNT = 1024;
final float LEVEL_PERCENT_THRESHOLD = .7;
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
    {new FinalPlatform(WIDTH - 70 , HEIGHT-15/2f - 5, 60, 15), new Player(50, 450, 32), new TextObject(WIDTH - 70 , HEIGHT-30, "PLAY",12), new TextObject(WIDTH/2 , HEIGHT/2, "SIXTY-FOUR",36) },
    {new Player(50, 50, 32), new MovingPlatform(WIDTH - 100, WIDTH - 100, HEIGHT/4 + 70, HEIGHT - 30, 200f, 32f, 0f),new FinalPlatform(WIDTH - 60f , 150, 60f, 32f)},
    {new Player(50, 450, 32), new MovingPlatform(WIDTH/2, WIDTH/2, HEIGHT/2 - 20, HEIGHT/2 - 20, 32, HEIGHT, 0), new Spike(25,25,210,210,20,20,1, 0), new MovingPlatform(50,50,400,400,100,20,0), new FinalPlatform(WIDTH - 70 , HEIGHT-15/2f - 5, 60, 15)},
   	{new Player(50, 300, 32),
   							new FinalPlatform(WIDTH, HEIGHT, 60, 300),
   							new MovingPlatform(0,0,HEIGHT-60,HEIGHT + 30,80,180,0),
   							new MovingPlatform(60,60,HEIGHT-60,HEIGHT + 30,80,180,radians(10)),
   							new MovingPlatform(120,120,HEIGHT-60,HEIGHT + 30,80,180,radians(20)),
   							new MovingPlatform(180,180,HEIGHT-60,HEIGHT + 30,80,180,radians(30)),
   							new MovingPlatform(240,240,HEIGHT-60,HEIGHT + 30,80,180,radians(40)),
   							new MovingPlatform(300,300,HEIGHT-60,HEIGHT + 30,80,180,radians(50)),
							new MovingPlatform(360,360,HEIGHT-60,HEIGHT + 30,80,180,radians(60)),
							new MovingPlatform(420,420,HEIGHT-60,HEIGHT + 30,80,180,radians(70)),
							new MovingPlatform(480,480,HEIGHT-60,HEIGHT + 30,80,180,radians(80)),
							new MovingPlatform(540,540,HEIGHT-60,HEIGHT + 30,80,180,radians(90)),
							new MovingPlatform(600,600,HEIGHT-60,HEIGHT + 30,80,180,radians(100)),
							new MovingPlatform(660,660,HEIGHT-60,HEIGHT + 30,80,180,radians(110)),
   							new MovingPlatform(720,720,HEIGHT-60,HEIGHT + 30,80,180,radians(120)),
   							new MovingPlatform(780,780,HEIGHT-60,HEIGHT + 30,80,180,radians(130)),
   							new MovingPlatform(840,840,HEIGHT-60,HEIGHT + 30,80,180,radians(140)),
   							new MovingPlatform(900,900,HEIGHT-60,HEIGHT + 30,80,180,radians(150)),
							new MovingPlatform(960,960,HEIGHT-60,HEIGHT + 30,80,180,radians(160)),
							new MovingPlatform(1020,1020,HEIGHT-60,HEIGHT + 30,80,180,radians(170)),
							new MovingPlatform(1080,1080,HEIGHT-60,HEIGHT + 30,80,180,radians(180)),
							new MovingPlatform(1140,1140,HEIGHT-60,HEIGHT + 30,80,180,radians(190)),
							new MovingPlatform(1200,1200,HEIGHT-60,HEIGHT + 30,80,180,radians(200)),
							new MovingPlatform(1260,1260,HEIGHT-60,HEIGHT + 30,80,180,radians(210)),
							new Spike(75,75,0,HEIGHT/2,120,500,1,radians(20)),
							new Spike(135,135,0,HEIGHT/2,120,500,1,radians(30)),
							new Spike(195,195,0,HEIGHT/2,120,500,1,radians(40)),
							new Spike(255,255,0,HEIGHT/2,120,500,1,radians(50)),
							new Spike(315,315,0,HEIGHT/2,120,500,1,radians(60)),
							new Spike(375,375,0,HEIGHT/2,120,500,1,radians(70)),
							new Spike(435,435,0,HEIGHT/2,120,500,1,radians(80)),
							new Spike(495,495,0,HEIGHT/2,120,500,1,radians(90)),
							new Spike(555,555,0,HEIGHT/2,120,500,1,radians(100))},
    {new Player(50, 50, 32), new MovingPlatform(WIDTH/2, WIDTH/2, HEIGHT, HEIGHT/4, 128, 32,10), new MovingPlatform(3 * WIDTH/4, 3 * WIDTH/4, HEIGHT, HEIGHT/4, 128, 32,0),
    	new FinalPlatform(WIDTH - 80f , 50f, 60f, 32f),
    	new Spike(WIDTH/4,WIDTH/4, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 15,WIDTH/4 + 15, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 30,WIDTH/4 + 30, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 45,WIDTH/4 + 45, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 60,WIDTH/4 + 60, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 75,WIDTH/4 + 75, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 90,WIDTH/4 + 90, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 105,WIDTH/4 + 105, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 120,WIDTH/4 + 120, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 135,WIDTH/4 + 135, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 150,WIDTH/4 + 150, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 165,WIDTH/4 + 165, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 180,WIDTH/4 + 180, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),
    	new Spike(WIDTH/4 + 195,WIDTH/4 + 195, HEIGHT/2- 10, HEIGHT/2- 10, 30,30,-1,0),

    },

   // {new Player(50f, 50f, 32f), new MovingPlatform(WIDTH/4 - 100, WIDTH/4 - 100, HEIGHT - 100, HEIGHT, 70, 400, 0), new Spike(WIDTH/2, WIDTH/2, HEIGHT/2, HEIGHT/2,WIDTH,30f,1f,0)}
};
int level = 0;

FWorld world;
boolean[] keys;

float globalTime;

void initEdges() {
	world.setEdges(colors[3]);
	world.top.setNoStroke();
	world.bottom.setNoStroke();
	world.left.setNoStroke();
	world.right.setNoStroke();
}

void initMinim(){
	minim = new Minim(this);
	song = minim.loadFile("bg.mp3");
	song.play();
	song.loop();
}

void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	initEdges();
	world.setGravity(0,1e3);
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
	loadLevel();
}

void loadLevel() {
	objects.clear();
	world.clear();
	initEdges();
	currentCount = 0;
	for(GameObject go: gos[level]) {
		go.init();
		objects.add(go);
	}
}

void updateWorld() {
	world.step();
	int liveCount = 0;
	for(GameObject go : objects){
		if(go instanceof Player)
			liveCount++;
		go.update();
	}

	boolean b1 = liveCount == 0;
	boolean b2 = currentHeight > 0;
	boolean b3 = currentCount/MAX_COUNT < LEVEL_PERCENT_THRESHOLD;
	boolean b4 = currentHeight/HEIGHT < currentCount/MAX_COUNT;
	boolean b5 = currentHeight < HEIGHT;

	println("1 " + b1);
	println("2 " + b2);
	println("3 " + b3);
	println("4 " + b4);
	println("5 " + b5);

	if(b1 && b2 && b3)
	{
		println("minus");
		currentHeight -= HEIGHT_STEP;
	}
	if(b1 && !b2 && b3)
	{
		loadLevel();
	}
	if(!b3 && !b4 && !b5)
	{
		nextLevel();
	}
	if((b4 && !b3) || (!b1 && b4))
	{
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
	for(GameObject go : objects){
		if(go instanceof TextObject)
			go.draw();
	}
	popStyle();
	world.draw();
}

void keyPressed() {
	switch(keyCode) {
		case RIGHT: keys[0] = true; break;
		case UP: keys[1] = true; break;
		case LEFT: keys[2] = true; break;
		case DOWN: keys[3] = true; break; 

	}
	if(keyCode == 'R') {
		loadLevel();
	}
	if(key == 'n')
		nextLevel();
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
	smooth(8);
	initFisica();
	initElse();
	initMinim();
	loadLevel();
	textAlign(CENTER, CENTER);
	stroke(colors[3]);
	noStroke();
	textMode(SHAPE);
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
	int fontSize;
	TextObject(float x, float y, String message, int fontSize) {
		super(x,y,10,10);
		this.message = message;
		this.fontSize = fontSize;
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
		textSize(fontSize);
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
		dead = false;
		body.setName(PLAYER_NAME);
		body.setFriction(0);
		body.setFillColor(colors[0]);
	}

	@Override
	void update() {

		if(body.getX() < 0 || body.getX() > WIDTH || body.getY() < 0 || body.getY() > HEIGHT)
		{
			dead = true;
			objectsToRemove.add(this);
			world.remove(body);
			body.removeFromWorld();
		}
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
					body.setVelocity(body.getVelocityY(), -700);
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
				objectsToRemove.add(this);
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