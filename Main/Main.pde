import controlP5.*;
ControlP5 cp5;

ArrayList<NodeHarness> nodeHarnesses = new ArrayList<NodeHarness>();

//Testing a brick class
BrickFactory brickFactory;
NodeHarness node001;

void setup() {
  background(175);
  rectMode(RADIUS); 
  size(800, 800);

  node001 = new NodeHarness( this, "node001", 300, 450, 100 );
  nodeHarnesses.add( node001 );
  brickFactory = new BrickFactory( this, 300, 400 );
}

void draw() {
  background(175);
  brickFactory.update();
  node001.update();
}