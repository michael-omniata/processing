//The BrickHarness class is the GUI for a Brick, attributes can be adjusted through ControlP5 for testing

class BrickHarness extends HarnessRect {
  int sliderUsageValue;
  Slider usageSlider;
  Toggle statusToggle;
  Textfield nodeField;
  Textfield deviceField;
  Textfield volumeField;
  public Brick brick;
  public NodeHarness nodeHarnessContainer;
  public VolumeHarness volumeHarnessContainer;

  BrickHarness( int x, int y, int w, int h ) {
    super( x, y, w, h );
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
    nodeField = cp5.addTextfield(this, "nodeField")
      .setAutoClear(false)
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    deviceField = cp5.addTextfield(this, "deviceField")
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    volumeField = cp5.addTextfield(this, "volumeField")
      .setSize(50, 20)
      .setCaptionLabel("")
      ;
    addController( usageSlider, 0, -10 );
    addController( statusToggle, 0, -30 );
    addController( nodeField, w/2, -30 );
    addController( deviceField, 0, -50 );
    addController( volumeField, w/2, -50 );
  }
  void setDevice( String _device ) {
    deviceField.setValue( _device );
    brick.setDeviceName( _device );
  }
  void setNodeContainer( NodeHarness _nodeHarness ) {
    nodeHarnessContainer = _nodeHarness;
    nodeField.setText( _nodeHarness.node.getName() );
    brick.setNodeName( _nodeHarness.node.getName() );
    statusToggle( true );
    statusToggle.setValue(true);
    println( "Attached by "+nodeHarnessContainer.node.getName() );
  }
  void setVolumeContainer( VolumeHarness _volumeHarness ) {
    volumeHarnessContainer = _volumeHarness;
    volumeField.setText( _volumeHarness.volume.getName() );
  }
  boolean install( Brick newBrick ) {
    if ( brick != null ) return false; // Harness already has a brick
    brick = newBrick;
    usageSlider.setValue( brick.getUse() );
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
      String input = nodeField.getText();
      if ( !input.equals("") ) {
        println( "input is "+input );
        NodeHarness nodeHarness;
        if ( (nodeHarness = findNodeHarness( input )) != null) {
          nodeHarness.attach( this, "/dev/????" );
          deviceField.setValue( brick.getDeviceName() );
        }
      }
    } 
    if ( volumeHarnessContainer == null ) {
      String input = volumeField.getText();
      if ( !input.equals("") ) {
        println( "input is "+input );
        VolumeHarness volumeHarness;
        if ( (volumeHarness = findVolumeHarness( input )) != null) {
          volumeHarness.attach( this );
        }
      }
    }
    if ( brick != null ) {
      if (brick.getStatus() == true) {
        float use = (float)brick.getUse() / 100;
        if (use < .5) {
          super.setColor(color(use*255*2, 255, 0));
        } else if (use >= .5) {
          super.setColor(color(255, (1-use)*255*2, 0));
        }
        usageSlider.setValue( brick.getUse() );
      } else {
        super.setColor(color(0));
      }
      int stroke_weight = 0;
      if ( brick.reads > 0 ) {
        stroke_weight += 2;
      }
      if ( brick.writes > 0 ) {
        stroke_weight += 3;
      }
      if ( stroke_weight > 0 ) {
        super.setStroke( 255 );
        super.setStrokeWeight( stroke_weight );
      }
    }
  }
  void statusToggle(boolean state) {
    if ( brick == null ) return;
    brick.setStatus( state );
  }
}

BrickHarness findBrickHarness( String brickID ) {
  for ( BrickHarness bh : brickHarnesses ) {
    if ( brickID.equals( bh.brick.getID() ) ) {
      return bh;
    }
  }
  return null;
}