class VolumeHarness extends HarnessEllipse {
  int xPos, yPos;
  Slider usageIndicator;
  Textfield volumeName;
  Toggle started;
  Volume volume;

  VolumeHarness( String _name, int x, int y, int wide, int high) {
    super(x, y, wide, high);
    volume = new Volume( _name );

    volumeName = cp5.addTextfield(this, "" )
      .setSize(100, 20)
      .setValue( _name )
      .lock()
      ;
    usageIndicator = cp5.addSlider(this, "usage")
      .setRange(0.0, 100.0)
      .setValue(0)
      .setCaptionLabel("")
      ;
    started = cp5.addToggle(this, "started")
      .setSize(50, 20)
      .setCaptionLabel("State")
      ;

    addController(volumeName, 50, -50);
    addController(usageIndicator, 0, -20);
    addController(started, 0, -50);
  }

  boolean install(Volume newVolume) {
    if ( volume != null) return false;
    volume = newVolume;
    usageIndicator.setValue(volume.getUsage());
    return true;
  }

  Volume remove() {
    if (volume == null) return null;
    Volume removedVolume = volume;
    volume = null;
    return removedVolume;
  }

  Volume getVolume() {
    return volume;
  }

  void update() {
    super.update();
    usageIndicator.setValue(volume.getUsage() );
    if ( volume != null) {
      float usage = (float)volume.getUsage() / 100;
      if (usage < .5) {
        super.setColor(color(usage*255*2, 255, 0));
      } else if (usage >= .5) {
        super.setColor(color(255, (1-usage)*255*2, 0));
      }
    }
    super.draw();
  }
  void attach( BrickHarness _brickHarness ) {
    volume.addBrick( _brickHarness.brick );
    _brickHarness.setVolumeContainer( volume );
    volume.getCapacity();
  }
}

VolumeHarness findVolumeHarness( String volumeName ) {
  println( "Looking for "+volumeName );
  for (VolumeHarness harness : volumeHarnesses) {
    if ( harness.getVolume().getName().equals(volumeName) ) {
      println( "Found "+volumeName );
      return harness;
    }
  }
  return null;
}