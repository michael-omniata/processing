
HashMap relaySubStreamHarnesses = new HashMap();
RelaySubStreamHarness RelaySubStreamHarness_findOrCreate( String nodeName, String ID ) {
  String procID = nodeName+':'+ID;
  RelaySubStreamHarness rh = (RelaySubStreamHarness)relaySubStreamHarnesses.get( procID );
  if ( rh == null ) {
    rh = new RelaySubStreamHarness( nodeName, ID );
    relaySubStreamHarnesses.put( procID, rh );
  }
  return rh;
}

class RelaySubStreamHarness extends ProcessHarness {
  public static final int DEFAULT_RADIUS = 5;
  public static final int DEFAULT_HUE = 260;
  public static final int DEFAULT_ACTIVITY_INDICATOR_HUE = 0;
  public RelaySubStream relaySubStream;
  public RelayHarness relayHarness;
  public NodeHarness nodeHarnessContainer;
  public float radius = DEFAULT_RADIUS;
  Ring wrsRing;

  RelaySubStreamHarness( String _nodeName, String _ID ) {
    super( _nodeName, _ID, DEFAULT_RADIUS, DEFAULT_HUE, DEFAULT_ACTIVITY_INDICATOR_HUE );

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    process = relaySubStream = RelaySubStream_findOrCreate( nodeName, ID );

    wrsRing = new Ring( 
      radius + 2,               // outer radius
      (radius + 2 - 2),         // inner radius
      32,                       // number of segments
      color( 150,100,100 ),     // color
      0.0                       // rate (revolutions per second)
    );
  }

  void preTransform() {
    drawActivity( pvector );
  }

  void draw3D() {
    super.draw3D();
    wrsRing.draw( this.process.kb_wrs / 1000.0 );
  }
}
