import peasy.*;

PeasyCam cam;

ArrayList<PVector> myHelix;


void setup() {
  size(1000, 1000, P3D);
  cam = new PeasyCam(this, 100);
//  cam.setMinimumDistance(50);
//  cam.setMaximumDistance(500);
  myHelix = helix(1, 30, 32, 50);
  smooth();
}

void draw() {
  background(0);
  translate( 0, 0, 0 );
  noStroke();
  pushMatrix();
  for ( PVector p : myHelix ) {
    translate( p.x, p.y, p.z );
    fill(255);
    sphere(10);
  }
  popMatrix();
}

public ArrayList<PVector> helix(float zIncrement, float increment, float numItems, float radius) {
  float x = 0, y = 0, z = 0, inc = 0;
  ArrayList<PVector> locations = new ArrayList<PVector>();
  for(int i = 0; i < numItems; i++) {
    x = radius * cos(radians(inc));
    y = radius * sin(radians(inc));
    inc += increment;
    z += zIncrement;
    PVector p = new PVector(x, y, z);
    locations.add(p);
  }
  return locations;
}
