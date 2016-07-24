//Main part of the program, contains all global variables and setup() and draw()

import controlP5.*;
ControlP5 cp5;

ArrayList<NodeHarness> nodeHarnesses = new ArrayList<NodeHarness>();


BrickFactory brickFactory;
NodeHarness node001;

void setup() {
  background(175);
  size(800, 800);
  cp5 = new ControlP5(this);

  node001 = new NodeHarness("node001", 50, 200, 100, 50 );
  nodeHarnesses.add( node001 );
  brickFactory = new BrickFactory( 25, 50, 50, 50 );
  brickFactory.setColor( color( 0, 0, 255 ) );
  frameRate(30);
}

void draw() {
  background(175);
  brickFactory.update();
  node001.update();
}