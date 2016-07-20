import controlP5.*;
ControlP5 cp5;


//Testing a brick class
BrickHarness brickHarness;

void setup() {
  background(175);
  rectMode(RADIUS); 
  size(800, 800);

  brickHarness = new BrickHarness( this, 250, 250, 100 );
  Brick testBrick = new Brick(200, 49, true);
  
  brickHarness.install( testBrick );
}

void draw() {
  background(175);
  brickHarness.update();
}

class BrickHarness {
  int xPos, yPos;
  int boxSize;
  int sliderUsageValue;
  Brick brick;
  Slider usageSlider;
  Button statusToggle;

  BrickHarness( processing.core.PApplet theParent, int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
    cp5 = new ControlP5(theParent);
    usageSlider = cp5.addSlider(this, "sliderUsageValue")
      .setPosition(100, 50)
      .setRange(0, 100)
      .setValue(0)
      ;

    statusToggle = cp5.addButton(this, "statusToggle")
      .setValue(0)
      .setPosition(100, 100)
      .setSize(100, 19)
      .setCaptionLabel("State")
      ;
  }
  boolean install( Brick newBrick ) {
    if ( brick != null ) return false;
    brick = newBrick;
    usageSlider.setValue( brick.getUsage() );
    return true;
  }
  void remove() {
    brick = null;
    usageSlider.setValue( 0 );
  }
  void update() {
    if ( mousePressed && mouseHovering() ) {
      setX( mouseX );
      setY( mouseY );
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
  void statusToggle() {
    if ( brick == null ) return;
    brick.setStatus( !brick.getStatus() );
  }
  boolean mouseHovering() {
    return (
      (mouseX > xPos-boxSize) && (mouseX < (xPos+boxSize)) &&
      (mouseY > yPos-boxSize) && (mouseY < (yPos+boxSize))
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