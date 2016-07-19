import controlP5.*;
ControlP5 cp5;

float sliderUsageValue = 10;

//Testing a brick class
Brick testBrick = new Brick(250, 250, 200, 49, true, 100);

void setup() {
 background(175);
 rectMode(RADIUS); 
 size(800, 800);
 cp5 = new ControlP5(this);
 cp5.addSlider("sliderUsageValue")
     .setPosition(100,50)
     .setRange(0,100)
     ;
     
 cp5.addButton("statusChange")
     .setValue(0)
     .setPosition(100,100)
     .setSize(100,19)
     .setCaptionLabel("State")
     ;
}

void statusChange() {
  testBrick.changeStatus( !testBrick.getStatus() );
}
  
  

void draw() {
  background(175);
  testBrick.changeUsage( sliderUsageValue );
  testBrick.spawn();
  if ( mousePressed && testBrick.mouseHovering() ) {
    testBrick.changeX( mouseX );
    testBrick.changeY( mouseY );
  }
}

class Brick {
  boolean status;
  float capacity, usage;
  int xPos, yPos;
  int boxSize;
  Brick (int x, int y, float cap, float use, boolean stat, int size) {
    xPos = x;
    yPos = y;
    capacity = cap;
    usage = use/100;
    status = stat;
    boxSize = size;
  }
  void spawn() {
    if (status == true) {
      if (usage < .5) fill(usage*255*2, 255, 0);
      else if (usage >= .5) fill(255, (1-usage)*255*2, 0);
      rect(xPos, yPos, boxSize/2, boxSize/2);
      } 
    else {
     fill(0);
     rect(xPos, yPos, boxSize/2, boxSize/2);
    }
  }
  void changeStatus(boolean update) {
   status = update; 
  }
  int getX() {
    return xPos;
  }
  int getY() {
    return yPos;
  }
  boolean getStatus() {
    return status;
  }
  boolean mouseHovering() {
    return ( (mouseX > xPos-boxSize) && (mouseX < (xPos+boxSize)) &&
             (mouseY > yPos-boxSize) && (mouseY < (yPos+boxSize)) );
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
   usage = newUsage/100; 
  }
}