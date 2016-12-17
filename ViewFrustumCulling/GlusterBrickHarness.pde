//The BrickHarness class is the GUI for a Brick, attributes can be adjusted through ControlP5 for testing

HashMap glusterBrickHarnesses = new HashMap();
GlusterBrickHarness GlusterBrickHarness_findOrCreate( String nodeName, String deviceName ) {
  String brickID = nodeName+":"+deviceName;
  GlusterBrickHarness gh = (GlusterBrickHarness)glusterBrickHarnesses.get( brickID );
  if ( gh == null ) {
    gh = new GlusterBrickHarness( nodeName, deviceName );
    glusterBrickHarnesses.put( brickID, gh );
  }
  return gh;
}

class GlusterBrickHarness extends Harness {
  int DEFAULT_RADIUS = 10;

  String nodeName;
  String deviceName;
  public GlusterBrick brick;
  public GlusterNodeHarness nodeHarnessContainer;
  public GlusterVolumeHarness volumeHarnessContainer;
  float radius;

  GlusterBrickHarness( String _nodeName, String _deviceName ) {
    super();
    radius = DEFAULT_RADIUS;

    nodeHarnessContainer = null;
    volumeHarnessContainer = null;
    nodeName = _nodeName;
    deviceName = _deviceName;
  }

  void setNodeContainer( GlusterNodeHarness _nodeHarness ) {
    nodeHarnessContainer = _nodeHarness;
  }
  void setVolumeContainer( GlusterVolumeHarness _volumeHarness ) {
    volumeHarnessContainer = _volumeHarness;
  }

  boolean attach( GlusterBrick newBrick ) {
    if ( brick != null ) return false; // Harness already has a brick
    brick = newBrick;
    return true;
  }

  float calculateHue() {
    return (100.0-brick.disk.use);
  }

  float calculateBrightness() {
    float boffset = 60;
    if (brick.status ) {
      if ( brick.disk.reads > 0 ) {
        boffset += 20;
      }
      if ( brick.disk.writes > 0 ) {
        boffset += 20;
      }
    }
    return( boffset );
  }

  float calculateSaturation() {
    return 100;
  }

  boolean hasActivity() {
    return (brick.disk.util > 0);
  }

  float calculateActivityIndicatorHue() {
    return (200 + (100 * brick.disk.rkB / (brick.disk.rkB+brick.disk.wkB)));
  }
  float calculateActivityIndicatorBrightness() {
    return map( log(1.0+brick.disk.util)/log(10), log(1)/log(10), log(100)/log(10), 0, 100 );
  }
  float calculateActivityIndicatorSaturation() {
    return 100;
  }

  float calculateActivityIndicatorWeight() {
    if ( brick.disk.rkB > 0 && brick.disk.wkB > 0 ) {
      return 2;
    }
    return 1;
  }

  boolean calculateVisibility() {
    return true;
    //return nodeHarnessContainer.filter.getState() && volumeHarnessContainer.filter.getState();
  }

  float calculateRadius() {
    return (radius * (1+(brick.disk.util/100.0)));
  }

  float calculateContainerRadius() {
    return volumeHarnessContainer.radius;
  }

  void drawActivity( PVector p0 ) {
    float radius = calculateContainerRadius();
    PVector p2 = new PVector();
    PVector p1;

    if ( nodeHarnessContainer.pvector == null ) { // may not have been assigned yet
      return;
    }

    nodeHarnessContainer.activeBricks++;

    p2 = nodeHarnessContainer.pvector.copy();
    p2.normalize();
    p2.mult( radius );

    pushStyle();
      float activity_hue = calculateActivityIndicatorHue();
      float activity_brightness = calculateActivityIndicatorBrightness();
      float activity_saturation = calculateActivityIndicatorSaturation();

      stroke( activity_hue, activity_saturation, activity_brightness );
      p1 = rayTrace( p0.x, p0.y, p0.z, 0, 0, 0, radius );

      ArrayList<PVector> lines = ds.lineAroundSphere(p1,p2,radius);
      noFill();
      color c = color(activity_hue,activity_saturation,activity_brightness);
      stroke(c);
      strokeWeight(1);
      beginShape();
        for (PVector p : lines) {
          vertex(p.x, p.y, p.z);
        }
      endShape();
    popStyle();
  }
  
  void draw3D() {
    if ( isViewable ) {
      float radius = calculateRadius();

      fill( calculateHue(), calculateSaturation(), calculateBrightness());
      sphere( radius );
    }
  }
}

