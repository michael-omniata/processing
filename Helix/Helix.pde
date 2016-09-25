

void setup() {
 size(500, 500, P3D);
 background(255);
}

void draw() {
  helix(1, 30, 30, 30);
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