import controlP5.*;
ControlP5 cp5;


//Testing a brick class
BrickFactory brickFactory;

void setup() {
  background(175);
  rectMode(RADIUS); 
  size(800, 800);

  brickFactory = new BrickFactory( this, 300, 400 );
}

void draw() {
  background(175);
  brickFactory.update();
}

class BrickFactory {
  int xPos, yPos;
  int boxSize;
  Bang button;
  processing.core.PApplet canvas;
  ArrayList<BrickHarness> brickHarnesses = new ArrayList<BrickHarness>();

  BrickFactory( processing.core.PApplet theParent, int x, int y ) {
    xPos = x;
    yPos = y;
    cp5 = new ControlP5(theParent);
    canvas = theParent;
    button = cp5.addBang(this, "createHarness")
      .setPosition(40, 300)
      .setSize(280, 40)
      .setTriggerEvent(Bang.RELEASE)
      .setLabel("Create Harness with brick")
      ;
  }
  void createHarness() {
    BrickHarness brickHarness = new BrickHarness( canvas, 250, 250, 100 );
    brickHarness.install( new Brick( 200, 49, true ) );
    brickHarnesses.add( brickHarness );
  }
  void update() {
    for (BrickHarness harness : brickHarnesses) {
      harness.update();
    }
  }
}


class BrickHarness {
  int xPos, yPos;
  int boxSize;
  int sliderUsageValue;
  Brick brick;
  Slider usageSlider;
  Toggle statusToggle;

  BrickHarness( processing.core.PApplet theParent, int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
    cp5 = new ControlP5(theParent);
    usageSlider = cp5.addSlider(this, "sliderUsageValue")
      .setPosition(x-(boxSize/2), y-65)
      .setRange(0, 100)
      .setValue(0)
      ;

    statusToggle = cp5.addToggle(this, "statusToggle")
      .setPosition(x-(boxSize/2), y-105)
      .setSize(50, 20)
      .setCaptionLabel("State")
      ;
  }
  boolean install( Brick newBrick ) {
    if ( brick != null ) return false; // Harness already has a brick
    brick = newBrick;
    usageSlider.setValue( brick.getUsage() );
    statusToggle.setValue( brick.getStatus() );
    return true;
  }
  Brick remove() { // remove brick from harness and return it.
    if ( brick == null ) return null; // Harness is empty, can't remove brick
    Brick removedBrick = brick;
    brick = null;
    usageSlider.setValue( 0 );
    statusToggle.setValue( false );
    return removedBrick;
  }
  Brick getBrick() {
    return brick;
  }
  void update() {
    if ( mousePressed && mouseHovering() ) {
      setX( mouseX );
      setY( mouseY );
      usageSlider.setPosition(xPos-(boxSize/2), yPos-65);
      statusToggle.setPosition(xPos-(boxSize/2), yPos-105);
    }
    if ( brick != null ) {
      brick.update();
      if (brick.getStatus() == true) {
        brick.setUsage( sliderUsageValue );
        float usage = (float)brick.getUsage() / 100;
        if (usage < .5) {
          fill(usage*255*2, 255, 0);
        } else if (usage >= .5) {
          fill(255, (1-usage)*255*2, 0);
        }
      } else {
        fill(0);
      }
      rect(xPos, yPos, boxSize/2, boxSize/2);
    }
  }
  void statusToggle(boolean state) {
    if ( brick == null ) return;
    brick.setStatus( state );
  }
  boolean mouseHovering() {
    return (
      (mouseX > xPos-(boxSize/2)) && (mouseX < (xPos+(boxSize/2))) &&
      (mouseY > yPos-(boxSize/2)) && (mouseY < (yPos+(boxSize/2)))
      );
  }
  int getX() { 
    return xPos;
  }
  int getY() { 
    return yPos;
  }
  void setX(int newX) { 
    xPos = newX;
  }
  void setY(int newY) { 
    yPos = newY;
  }
}


class Brick {
  boolean status;
  float capacity;
  int usage;

  Brick (float cap, int use, boolean state) {
    capacity = cap;
    usage = use;
    status = state;
  }
  void update() {
    // this might be used to periodically get the *actual* status of the brick
  }
  void setStatus(boolean update) { 
    status = update;
  }
  boolean getStatus() { 
    return status;
  }
  void setCapacity(float newCap) {
    capacity = newCap;
  }
  float getCapacity() {
    return capacity;
  }
  void setUsage(int newUsage) { 
    usage = newUsage;
  }
  int getUsage() {
    return usage;
  }
}