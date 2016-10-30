
HashMap relayStreamHarnesses = new HashMap();
RelayStreamHarness RelayStreamHarness_findOrCreate( String nodeName, String ID ) {
  String procID = nodeName+':'+ID;
  RelayStreamHarness rh = (RelayStreamHarness)relayStreamHarnesses.get( procID );
  if ( rh == null ) {
    rh = new RelayStreamHarness( nodeName, ID );
    relayStreamHarnesses.put( procID, rh );
  }
  return rh;
}

class RelayStreamHarness extends ProcessHarness {
  public static final int DEFAULT_RADIUS = 7;
  public static final int DEFAULT_HUE = 70;
  public static final int DEFAULT_ACTIVITY_INDICATOR_HUE = 170;
  public RelayHarness relayHarness;
  public NodeHarness nodeHarnessContainer;
  public RelayStream relayStream;
  Ring wrsRing;

  RelayStreamHarness( String _nodeName, String _ID ) {
    super( _nodeName, _ID, DEFAULT_RADIUS, DEFAULT_HUE, DEFAULT_ACTIVITY_INDICATOR_HUE );

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    process = relayStream = RelayStream_findOrCreate( nodeName, ID );

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
