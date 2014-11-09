import fisica.*;

FWorld world;

void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	world.setEdges();
	world.setGravity(0,1e3);
}

void updateWorld() {
	world.step();
}

void drawWorld() {
	world.draw();
}

void setup() {
	size(1280,720,OPENGL);
	initFisica();
}

void draw() {
	updateWorld();
	drawWorld();
}