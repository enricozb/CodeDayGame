import fisica.*;
import java.util.*;
import java.util.Map.Entry;

final float TIME_STEP = .05;

ArrayList<GameObject> objects;
ArrayList<GameObject> objectsToRemove;
ArrayList<GameObject> objectsToAdd;
HashMap<String, LinkedList<Float>> goData1 = new HashMap<String, LinkedList<Float>>();
FWorld world;
boolean[] keys;

float globalTime;

void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	world.setEdges();
	world.setGravity(0,1e3);
}

void initWorld() {
	goData1.put(GameObject.MOVING_PLATFORM_NAME + "" + " - 1",new LinkedList() {{
		add(0f);add(400f);add(200f);add(400f);add(300f);add(300f);
	}});
}

final void makeWorld() {
	initWorld();
	for(Entry<String,LinkedList<Float>> entry: goData1.entrySet()) {
		LinkedList<Float> t = entry.getValue();
		String name = entry.getKey().split("\\s")[0].trim();

		if(name.equals(GameObject.MOVING_PLATFORM_NAME)) {
			objects.add(new MovingPlatform(t.pop(),t.pop(),t.pop(),t.pop(),t.pop(),t.pop()));
			println(name);	
		}
		else if (name.equals(GameObject.PLATFORM_NAME)) {
			objects.add(new MovingPlatform(t.pop(),t.pop(),t.pop(),t.pop()));
			println(name);
		} else if (name.equals(GameObject.PLAYER_NAME)) {
			objects.add(new MovingPlatform(t.pop(),t.pop(),t.pop(),t.pop()));
			println(name);
		} else if (name.equals(GameObject.SPIKE_NAME)) {
			objects.add(new MovingPlatform(t.pop(),t.pop(),t.pop(),t.pop()));
			println(name);
		}
	}
}
void initElse() {
	keys = new boolean[4]; //0 = E, 1 = N, 2 = W, 3 = S
	objects = new ArrayList<GameObject>();
	objectsToRemove = new ArrayList<GameObject>();
	objectsToAdd = new ArrayList<GameObject>();
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
void setup() {
	size(1280,500,OPENGL);
	initFisica();
	initElse();
	makeWorld();
	objects.add(new Player(width/2, height/2, 25));
	objects.add(new Spike(width/4,width/4, 0, height, 20, 100,true));
}

void draw() {
	updateWorld();
	drawWorld();
}

abstract class GameObject {

	final static String MOVING_PLATFORM_NAME = "mplat";
	final static String PLATFORM_NAME = "plat";
	final static String SPIKE_NAME = "spike";
	final static String PLAYER_NAME = "player";

	FBox body;
	float sx, sy;
	float x, y;
	GameObject(float x, float y, float sx, float sy) {
		body = new FBox(sx, sy);
		body.setPosition(x, y);
		body.setNoStroke();
		this.sx = sx;
		this.sy = sy;
		this.x = x;
		this.y = y;
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
		body.setStatic(true);
	}

}

class Player extends GameObject {

	final static int JUMP_CALL_COUNT_MAX = 40;
	final static float DEATH_SIZE_THRESHOLD = 5;

	boolean dead = false;

	Player(float x, float y, float s) {
		super(x,y,s,s);
		body.setName(PLAYER_NAME);
		body.setFriction(0);
	}

	boolean lastJump = false;
	int jumpCallCount = 0;

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
					break;
				}	
			}
			if(fb.getName() == SPIKE_NAME){
				split();
			}
		}

		if(keys[0]) body.setVelocity(150, body.getVelocityY());
		if(keys[2]) body.setVelocity(-150, body.getVelocityY());
		if(!keys[0] && !keys[2] && bodiesTouching.size() != 0) body.setVelocity(0, body.getVelocityY());
	}

	private void split() {
		objectsToRemove.add(this);
		if(sx > DEATH_SIZE_THRESHOLD && !dead) {
			dead = true;
			Player a = new Player(body.getX() + sx/2, body.getY(), sx/sqrt(2));
			Player b = new Player(body.getX() - sx/2, body.getY(), sx/sqrt(2));
			a.body.setVelocity(300,body.getVelocityY());
			b.body.setVelocity(-300,body.getVelocityY());
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
		body.setName(MOVING_PLATFORM_NAME);
	}
	MovingPlatform(float x, float y, float sx, float sy){
		this(x, x, y, y, sx, sy);
	}

	@Override
	void update() {
		body.setPosition(map(sin(globalTime), -1, 1, minx, maxx), map(sin(globalTime), -1, 1, miny, maxy));
	}

};

class Spike extends Moving {

	FPoly poly;
	boolean spikeDown;
	Spike(float minx, float maxx, float miny, float maxy, float sx, float sy, boolean spikeDown) {
		super(minx, maxx, miny, maxy, sx, sy);
		this.spikeDown = spikeDown;
		sensorize();
		initTriangularBody();
	}

	private void initTriangularBody() {
		poly = new FPoly();
		poly.vertex(minx - sx/2, miny - sy/2 * (spikeDown ? 1 : -1));
		poly.vertex(minx + sx/2, miny - sy/2 * (spikeDown ? 1 : -1));
		poly.vertex(minx, miny + sy/2 * (spikeDown ? 1 : -1));
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