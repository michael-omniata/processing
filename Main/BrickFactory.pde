//The BrickFactory class is used to create Brick objects

class BrickFactory extends HarnessRect {
  Bang button;
  processing.core.PApplet canvas;
 
  BrickFactory( int x, int y, int l, int h) {
    super( x, y, l, h );
    button = cp5.addBang(this, "createHarness")
      .setSize(l, h)
      .setTriggerEvent(Bang.RELEASE)
      .setLabel("Create Harness with brick")
      ;
    addController( button, x, y );
  }
  void createHarness() {
    BrickHarness brickHarness = new BrickHarness( 250, 250, 100, 50 );
    brickHarness.install( new Brick( 200 ) );
    brickHarnesses.add( brickHarness );
  }
  void update() {
    super.update();

    /*if ( mousePressed && button.isMouseOver()) { <- Currently this makes the button jump around whenever clicked and is a hassle to deal with. Moved button to a reasonable spot and commented out this code
      button.setPosition(xPos, yPos);
    }*/
  }
}
