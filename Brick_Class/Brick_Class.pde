//Testing a brick class
Brick testBrick = new Brick(250, 250, 200, 49, true);

void setup() {
 background(175);
 size(800, 800);
 
 frameRate(1);
}

void draw() {
  background(175);
  testBrick.spawn();
}

class Brick {
  boolean status;
  float capacity, usage;
  int xPos, yPos;
  Brick (int x, int y, float cap, float use, boolean stat) {
    xPos = x;
    yPos = y;
    capacity = cap;
    usage = use/100;
    status = stat;
  }
  void spawn() {
    if (status == true) {
      if (usage < .5) fill(usage*255*2, 255, 0);
      else if (usage >= .5) fill(255, (1-usage)*255*2, 0);
      rect(xPos, yPos, 100, 100);
      } 
    else {
     fill(0);
     rect(xPos, yPos, 100, 100);
    }
  }
  void changeStatus(boolean update) {
   status = update; 
  }
  void changeX(int newX) {
   xPos = newX; 
  }
  void changeY(int newY) {
   yPos = newY; 
  }
  void changeCapacity(float newCap) {
   capacity = newCap; 
  }
  void changeUsage(float newUsage) {
   usage = newUsage; 
  }
}