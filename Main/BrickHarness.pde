//The BrickHarness class is the GUI for a Brick, attributes can be adjusted through ControlP5 for testing

class BrickHarness extends HarnessRect {
  int sliderUsageValue;
  Brick brick;
  Slider usageSlider;
  Toggle statusToggle;
  Textfield nodeCli;
  Textfield device;
  Textfield volumeCli;
  public NodeHarness nodeHarnessContainer;
  public VolumeHarness volumeHarnessContainer;

  BrickHarness( int x, int y, int l, int h ) {
    super( x, y, l, h );
    nodeHarnessContainer = null;
    volumeHarnessContainer = null;
    usageSlider = cp5.addSlider(this, "sliderUsageValue")
      .setRange(0, 100)
      .setValue(0)
      .setCaptionLabel("")
      ;
    statusToggle = cp5.addToggle(this, "statusToggle")
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    nodeCli = cp5.addTextfield(this, "cli")
      .setAutoClear(false)
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    device = cp5.addTextfield(this, "device")
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    volumeCli = cp5.addTextfield(this, "volumeCli")
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    addController( usageSlider, 0, -10 );
    addController( statusToggle, 0, -30 );
    addController( nodeCli, wth/2, -30 );
    addController( device, 0, -50 );
    addController( volumeCli, wth/2, -50 );
  }
  void setDevice( String _device ) {
    device.setValue( _device );
    brick.setDeviceName( _device );
  }
  void setNodeContainer( NodeHarness _nodeHarness ) {
    nodeHarnessContainer = _nodeHarness;
    nodeCli.setText( _nodeHarness.node.getName() );
    statusToggle( true );
    statusToggle.setValue(true);
    println( "Attached by "+nodeHarnessContainer.node.getName() );
  }
  void setVolumeContainer( VolumeHarness _volumeHarness ) {
    volumeHarnessContainer = _volumeHarness;
    volumeCli.setText( _volumeHarness.volume.getName() );
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
    if ( nodeHarnessContainer == null ) {
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
    if ( volumeHarnessContainer == null ) {
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
    }
  }
  void statusToggle(boolean state) {
    if ( brick == null ) return;
    brick.setStatus( state );
  }
}