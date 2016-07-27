//Main part of the program, contains all global variables and setup() and draw()

import controlP5.*;
ControlP5 cp5;

ArrayList<NodeHarness> nodeHarnesses = new ArrayList<NodeHarness>();
ArrayList<VolumeHarness> volumeHarnesses = new ArrayList<VolumeHarness>();

BrickFactory brickFactory;
NodeHarness node001;
VolumeHarness gv0;

void setup() {
  background(175);
  size(800, 800);
  cp5 = new ControlP5(this);

  ellipseMode(CORNER);
  rectMode(CORNER);
  
  node001 = new NodeHarness("node001", 50, 200, 100, 50 );
  gv0 = new VolumeHarness( "gv0", 200, 300, 100, 50 );
  
  nodeHarnesses.add( node001 );
  volumeHarnesses.add( gv0 );
  
  brickFactory = new BrickFactory( 25, 50, 50, 50 );
  brickFactory.setColor( color( 0, 0, 255 ) );
}

void draw() {
  background(175);
  brickFactory.update();
  node001.update();
  gv0.update();
}