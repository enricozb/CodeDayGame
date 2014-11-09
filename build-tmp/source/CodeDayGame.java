import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import fisica.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class CodeDayGame extends PApplet {



FWorld world;

public void initFisica() {
	Fisica.init(this);
	world = new FWorld();
	world.setEdges();
	world.setGravity(0,1e3f);
}

public void updateWorld() {
	world.step();
}

public void drawWorld() {
	world.draw();
}

public void setup() {
	size(1280,720,OPENGL);
	initFisica();
}

public void draw() {
	updateWorld();
	drawWorld();
}
  static public void main(String[] passedArgs) {
    String[] appletArgs = new String[] { "CodeDayGame" };
    if (passedArgs != null) {
      PApplet.main(concat(appletArgs, passedArgs));
    } else {
      PApplet.main(appletArgs);
    }
  }
}
