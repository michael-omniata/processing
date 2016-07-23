//The BrickFactory class is used to create Brick objects

class BrickFactory extends Harness {
  Bang button;
  processing.core.PApplet canvas;
  ArrayList<BrickHarness> brickHarnesses = new ArrayList<BrickHarness>();

  BrickFactory( int x, int y, int l, int h) {
    super( x, y, l, h );
    button = cp5.addBang(this, "createHarness")
      .setPosition(x, y)
      .setSize(l, h)
      .setTriggerEvent(Bang.RELEASE)
      .setLabel("Create Harness with brick")
      ;
  }
  void createHarness() {
    BrickHarness brickHarness = new BrickHarness( 250, 250, 100, 50 );
    brickHarness.install( new Brick( 200, 0, false ) );
    brickHarnesses.add( brickHarness );
  }
  void update() {
    super.update();
    for (BrickHarness harness : brickHarnesses) {
      harness.update();
    }
    if ( mousePressed && button.isMouseOver()) {
      button.setPosition(xPos, yPos);
    }
  }
}