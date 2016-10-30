class ProcessHarness extends Harness {
  String nodeName;
  String ID;
  public NodeHarness nodeHarnessContainer;
  public HarnessGroup cpuHarnessGroup;
  public Process process;
  float radius;
  int hue;
  int activityIndicatorHue;

  ProcessHarness( String _nodeName, String _ID, float _radius, int _hue, int _activityIndicatorHue ) {
    //super();
    nodeName = _nodeName;
    ID = _ID;
    radius = _radius;
    hue = _hue;
    activityIndicatorHue = _activityIndicatorHue;

    setLabel( _nodeName+":"+_ID );
    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
  }

  void setCpuHarnessGroup( HarnessGroup cpuHarnessGroup ) {
    this.cpuHarnessGroup = cpuHarnessGroup;
  }

  float calculateHue() {
    return( hue + map( log(1.0+this.process.cpuTotal)/log(10), log(1)/log(10), log(100)/log(10), 0, 100 ) );
  }

  float calculateBrightness() {
    if ( (((millis() - this.process.updatedMillis) / 1000) > 340) ) { // no new information after 340 means something may be wrong
      return 0;
    } 
    return 100;
  }

  float calculateActivityIndicatorBrightness() {
    return map( log(1.0+this.process.cpuTotal)/log(10), log(1)/log(10), log(100)/log(10), 0, 100 );
  }

  float calculateSaturation() {
    return 100;
  }

  float calculateRadius() {
    return radius;
  }

  void drawActivity( PVector p0 ) {
    float radius = this.cpuHarnessGroup.containerRadius;
    if ( pvector == null ) {
      return;
    }

    CpuHarness ch = CpuHarness_findOrCreate( nodeName, str(this.process.cpu) );
    if ( ch.pvector == null ) { // may not have been assigned yet
      return;
    }

    PVector p2 = new PVector();
    PVector p1;


    p2 = ch.pvector.copy();
    p2.x += this.cpuHarnessGroup.xOffset;
    p2.y += this.cpuHarnessGroup.yOffset;
    p2.z += this.cpuHarnessGroup.zOffset;
    p2.normalize();
    p2.mult( radius );

    pushStyle();
      float activity_hue = calculateActivityIndicatorHue();
      float activity_brightness = calculateActivityIndicatorBrightness();
      float activity_saturation = 100;
      if ( activity_brightness >= 10.0 ) {
        color c = color(activityIndicatorHue,activity_saturation,activity_brightness);
        noFill();
        strokeWeight(1);
        stroke(c);

        p1 = rayTrace(
          p0.x + this.harnessGroup.xOffset,
          p0.y + this.harnessGroup.yOffset,
          p0.z + this.harnessGroup.zOffset,
          0,
          0,
          0,
          radius
        ); 
        ArrayList<PVector> lines = ds.lineAroundSphere(p2,p1,this.cpuHarnessGroup.containerRadius);
        c = color(activityIndicatorHue,activity_saturation,activity_brightness);
        stroke(c);
        beginShape();
          for (PVector p : lines) {
            vertex(
                p.x,
                p.y,
                p.z
            );
          }
        endShape();
      popStyle();
    }
  }
}
