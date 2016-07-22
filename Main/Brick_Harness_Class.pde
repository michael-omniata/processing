class BrickHarness {
  int xPos, yPos;
  int boxSize;
  int sliderUsageValue;
  Brick brick;
  Slider usageSlider;
  Toggle statusToggle;
  Textfield cli;
  Node container;

  BrickHarness( processing.core.PApplet theParent, int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
    container = null;
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
    cli = cp5.addTextfield("cli")
      .setPosition(x, y-105)
      .setAutoClear(false)
      .setSize(50, 20)
      ;
  }
  void cliCallback() {
  }
  void setContainer( Node _node ) {
    container = _node;
    statusToggle( true );
    statusToggle.setValue(true);
    println( "Attached by "+container.getNodeName() );
  }
  Node getContainer() {
    return container;
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
      cli.setPosition(xPos, yPos-105);
    }
    if ( container == null ) {
      String input = cli.getText();
      if ( !input.equals("") ) {
        println( "input is "+input );
        NodeHarness nodeHarness;
        if ( (nodeHarness = findNodeHarness( input )) != null) {
          nodeHarness.attach( this );
        }
      }
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