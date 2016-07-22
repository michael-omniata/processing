//The BrickHarness class is the GUI for a Brick, attributes can be adjusted through ControlP5 for testing

class BrickHarness extends Harness {
  int sliderUsageValue;
  Brick brick;
  Slider usageSlider;
  Toggle statusToggle;
  Textfield cli;
  Node container;

  BrickHarness( int x, int y, int size ) {
    super( x, y, size );
    container = null;
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
    cli = cp5.addTextfield(this, "cli")
      .setPosition(x, y-105)
      .setAutoClear(false)
      .setSize(50, 20)
      ;
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
    super.update();
    if ( mousePressed && mouseHovering() ) {
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
          super.setColor(color(usage*255*2, 255, 0));
        } else if (usage >= .5) {
          super.setColor(color(255, (1-usage)*255*2, 0));
        }
      } else {
        super.setColor(color(0));
      }
      rect(xPos, yPos, boxSize/2, boxSize/2);
    }
  }
  void statusToggle(boolean state) {
    if ( brick == null ) return;
    brick.setStatus( state );
  }
}