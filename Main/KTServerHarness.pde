
HashMap ktserverHarnesses = new HashMap();
KTServerHarness KTServerHarness_findOrCreate( String nodeName, String ID ) {
  String serverID = nodeName+':'+ID;
  KTServerHarness h = (KTServerHarness)ktserverHarnesses.get( serverID );
  if ( h == null ) {
    h = new KTServerHarness( nodeName, ID );
    ktserverHarnesses.put( serverID, h );
  }
  return h;
}

class KTServerHarness extends Harness {
  int DEFAULT_RADIUS = 10;
  public KTServer ktserver;
  public RelayHarness relayHarness;
  public NodeHarness nodeHarnessContainer;
  Ellipsoid rxIndicator;
  PVector rxIndicatorVector;
  float radius;
  String nodeName;
  String ID;
  Ring mbRdsRing;
  Ring mbWrsRing;

  KTServerHarness( String _nodeName, String _ID ) {
    super();
    nodeName = _nodeName;
    ID = _ID;
    radius = DEFAULT_RADIUS;

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    ktserver = KTServer_findOrCreate( nodeName, ID );
    mbWrsRing = new Ring(
      radius + 2,          // outer radius
      (radius + 2 - 2),    // inner radius
      32,                   // number of segments
      color( 175,100,100 ), // color
      0.0                   // rate (revolutions per second)
    );
    mbRdsRing = new Ring(
      radius + 5,           // outer radius
      (radius + 5 - 2),     // inner radius
      32,                   // number of segments
      color( 125,100,100 ), // color
      0.0                   // rate (revolutions per second)
    );
  }

  // @override
  float calculateHue() {
    float hue = 100;

    hue -= ktserver.cpuTotal;
    return hue;
  }
  
  // @override
  float calculateActivityIndicatorBrightness() {
    return map( log(1.0+ktserver.cpuTotal)/log(10), log(1)/log(10), log(100)/log(10), 0, 100 );
  }

  void preTransform() {
    /* Draws lines to the current CPU */
    // TODO: do this better:
    if ( relayHarness == null ) {
      if ( nodeName.equals("ev-relay-A-node001") ) {
        relayHarness = relayHarness_node001;
      } else if ( nodeName.equals("ev-relay-A-node004") ) {
        relayHarness = relayHarness_node004;
      } else {
        return;
      }
    }
    drawActivity( pvector );

    if ( pvector != null ) {
      pushStyle();
      /*
        stroke(0,0,100);
        CpuHarness ch = CpuHarness_findOrCreate( nodeName, str(ktserver.cpu) );
        line(
          pvector.x    + relayHarness.ktserverHarnessGroup.xOffset,
          pvector.y    + relayHarness.ktserverHarnessGroup.yOffset,
          pvector.z    + relayHarness.ktserverHarnessGroup.zOffset,
          ch.pvector.x + relayHarness.cpuHarnessGroup.xOffset,
          ch.pvector.y + relayHarness.cpuHarnessGroup.yOffset,
          ch.pvector.z + relayHarness.cpuHarnessGroup.zOffset
        );
        */
      popStyle();
    }
  }

  void drawActivity( PVector p0 ) {
    float radius = relayHarness.cpuHarnessGroup.containerRadius;
    if ( pvector == null ) {
      return;
    }

    CpuHarness ch = CpuHarness_findOrCreate( nodeName, str(ktserver.cpu) );
    if ( ch.pvector == null ) { // may not have been assigned yet
      return;
    }

    PVector p2 = new PVector();
    PVector p1;


    p2 = ch.pvector.copy();
    p2.x += relayHarness.cpuHarnessGroup.xOffset;
    p2.y += relayHarness.cpuHarnessGroup.yOffset;
    p2.z += relayHarness.cpuHarnessGroup.zOffset;
    p2.normalize();
    p2.mult( radius );

    pushStyle();
      float activity_hue = calculateActivityIndicatorHue();
      float activity_brightness = calculateActivityIndicatorBrightness();
      if ( activity_brightness > 25.0 ) {
        float activity_saturation = 100;
        color c = color(50,activity_saturation,activity_brightness);
        noFill();
        strokeWeight(1);
        stroke(c);

        p1 = rayTrace(
          p0.x + relayHarness.ktserverHarnessGroup.xOffset,
          p0.y + relayHarness.ktserverHarnessGroup.yOffset,
          p0.z + relayHarness.ktserverHarnessGroup.zOffset,
          0,
          0,
          0,
          radius
        ); 
        ArrayList<PVector> lines = ds.lineAroundSphere(p2,p1,relayHarness.cpuHarnessGroup.containerRadius);
        c = color(50,activity_saturation,activity_brightness);
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

  void drawHUD() {
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    translate( 200, 240 );
    pushStyle();
    fill( 200, 100, 100 );
    text( "kb_wrs: "+ktserver.kb_wrs+"("+mbWrsRing.frequency+")\n"+"kb_rds: "+ktserver.kb_rds+"("+mbRdsRing.frequency+")\n", 0, 10, 400, 400 );
    popStyle();
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }

  void draw3D() {
    super.draw3D();

    mbWrsRing.draw( ktserver.kb_wrs / 1000.0 );
    mbRdsRing.draw( ktserver.kb_rds / 1000.0 );
    drawHUD();
  }
}
