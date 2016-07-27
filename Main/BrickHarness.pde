//The BrickHarness class is the GUI for a Brick, attributes can be adjusted through ControlP5 for testing

class BrickHarness extends HarnessRect {
  int sliderUsageValue;
  Brick brick;
  Slider usageSlider;
  Toggle statusToggle;
  Textfield nodeCli;
  Textfield device;
  Textfield volumeCli;
  Node nodeContainer;
  Volume volumeContainer;

  BrickHarness( int x, int y, int l, int h ) {
    super( x, y, l, h );
    nodeContainer = null;
    volumeContainer = null;
    usageSlider = cp5.addSlider(this, "sliderUsageValue")
      .setRange(0, 100)
      .setValue(0)
      .setCaptionLabel("")
      ;
    statusToggle = cp5.addToggle(this, "statusToggle")
      .setSize(50, 20)
      .setCaptionLabel("State")
      ;
    nodeCli = cp5.addTextfield(this, "cli")
      .setAutoClear(false)
      .setSize(50, 20)
      .setCaptionLabel("Node")
      ;
    device = cp5.addTextfield(this, "device")
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    volumeCli = cp5.addTextfield(this, "volumeCli")
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    addController( usageSlider, 0, -15 );
    addController( statusToggle, 0, -50 );
    addController( nodeCli, wth/2, -50 );
    addController( device, 0, -70 );
    addController( volumeCli, wth/2, -70 );
  }
  void setDevice( String _device ) {
    device.setValue( _device );
    brick.setDeviceName( _device );
  }
  void setNodeContainer( Node _node ) {
    nodeContainer = _node;
    nodeCli.setText( _node.getName() );
    statusToggle( true );
    statusToggle.setValue(true);
    println( "Attached by "+nodeContainer.getName() );
  }
  void setVolumeContainer( Volume _volume ) {
    volumeContainer = _volume;
    volumeCli.setText( _volume.getName() );
  }
  Node getNodeContainer() {
    return nodeContainer;
  }
  Volume getVolumeContainer() {
    return volumeContainer;
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
    if ( nodeContainer == null ) {
      String input = nodeCli.getText();
      if ( !input.equals("") ) {
        println( "input is "+input );
        NodeHarness nodeHarness;
        if ( (nodeHarness = findNodeHarness( input )) != null) {
          nodeHarness.attach( this, "/dev/????" );
          device.setValue( brick.getDeviceName() );
        }
      }
    } 
    if ( volumeContainer == null ) {
      String input = volumeCli.getText();
      if ( !input.equals("") ) {
        println( "input is "+input );
        VolumeHarness volumeHarness;
        if ( (volumeHarness = findVolumeHarness( input )) != null) {
          volumeHarness.attach( this );
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
      super.draw();
    }
  }
  void statusToggle(boolean state) {
    if ( brick == null ) return;
    brick.setStatus( state );
  }
}