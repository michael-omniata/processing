//KTServerHarness contains the GUI for KTServer objects

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

class KTServerHarness extends ProcessHarness {
  public static final int DEFAULT_RADIUS = 10;
  public static final int DEFAULT_HUE = 100;
  public static final int DEFAULT_ACTIVITY_INDICATOR_HUE = 50;
  public KTServer ktserver;
  public RelayHarness relayHarness;
  public NodeHarness nodeHarnessContainer;
  Ring mbRdsRing;
  Ring mbWrsRing;

  KTServerHarness( String _nodeName, String _ID ) {
    super( _nodeName, _ID, DEFAULT_RADIUS, DEFAULT_HUE, DEFAULT_ACTIVITY_INDICATOR_HUE );

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    process = ktserver = KTServer_findOrCreate( nodeName, ID );
    mbWrsRing = new Ring(
      radius + 2,           // outer radius
      (radius + 2 - 2),     // inner radius
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
  
  void preTransform() {
    drawActivity( pvector );
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
//    drawHUD();
  }
}