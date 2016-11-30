
HashMap procHarnesses = new HashMap();
ProcHarness ProcHarness_findOrCreate( String nodeName, String ID ) {
  String procID = nodeName+':'+ID;
  ProcHarness p = (ProcHarness)procHarnesses.get( procID );
  if ( p == null ) {
    p = new ProcHarness( nodeName, ID );
    procHarnesses.put( procID, p );
  }
  return p;
}

class ProcHarnessGroup extends HarnessGroup {
  int total_eps;

  ProcHarnessGroup( PApplet app, float _xPos, float _yPos, float _zPos, float _xOffset, float _yOffset, float _zOffset ) {
    super( app, _xPos, _yPos, _zPos, _xOffset, _yOffset, _zOffset );
  }
}

class ProcHarness extends ProcessHarness {
  public static final int DEFAULT_RADIUS = 10;
  public static final int DEFAULT_HUE = 200;
  public static final int DEFAULT_ACTIVITY_INDICATOR_HUE = 0;
  public NodeHarness nodeHarnessContainer;
  Ring epsRing;
  Proc proc;

  ProcHarness( String _nodeName, String _ID ) {
    super( _nodeName, _ID, DEFAULT_RADIUS, DEFAULT_HUE, DEFAULT_ACTIVITY_INDICATOR_HUE );

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    process = proc = Proc_findOrCreate( nodeName, ID );

    epsRing = new Ring( 
      radius + 2,               // outer radius
      (radius + 2 - 2),         // inner radius
      32,                       // number of segments
      color( 250,100,100 ),     // color
      0.0                       // rate (revolutions per second)
    );
  }

  // @override
  float calculateHue() {
    return 200 + this.process.cpuTotal;
  }

  // @override
  float calculateSaturation() {
    return 100;
  }

  // @override
  float calculateRadius() {
    return radius;
  }

  void draw3D() {
    super.draw3D();
    epsRing.draw( this.proc.eps / 100.0 );
  }
}
