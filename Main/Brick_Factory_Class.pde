//The BrickFactory class is used to create Brick objects

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
    brickHarness.install( new Brick( 200, 49, false ) );
    brickHarnesses.add( brickHarness );
  }
  void update() {
    for (BrickHarness harness : brickHarnesses) {
      harness.update();
    }
  }
}