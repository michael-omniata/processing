class VolumeHarness extends HarnessEllipse {
  int xPos, yPos;
  Slider usageIndicator;
  Toggle started;
  Volume volume;

  VolumeHarness(int x, int y, int wide, int high) {
    super(x, y, wide, high);

    usageIndicator = cp5.addSlider(this, "usage")
      .setRange(0.0, 100.0)
      .setValue(0)
      .setCaptionLabel("")
      ;
    started = cp5.addToggle(this, "started")
      .setSize(50, 20)
      .setCaptionLabel("State")
      ;
    addController(usageIndicator, 0, -20);
    addController(started, 0, -50);
  }

  boolean installVolume(Volume newVolume) {
    if ( volume != null) return false;
    volume = newVolume;
    usageIndicator.setValue(volume.getUsage());
    return true;
  }

  Volume removeVolume() {
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
}