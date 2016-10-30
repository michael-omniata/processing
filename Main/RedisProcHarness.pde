
HashMap redisProcHarnesses = new HashMap();
RedisProcHarness RedisProcHarness_findOrCreate( String nodeName, String ID ) {
  String serverID = nodeName+':'+ID;
  RedisProcHarness h = (RedisProcHarness)redisProcHarnesses.get( serverID );
  if ( h == null ) {
    h = new RedisProcHarness( nodeName, ID );
    redisProcHarnesses.put( serverID, h );
  }
  return h;
}

class RedisProcHarness extends ProcessHarness {
  public static final int DEFAULT_RADIUS = 5;
  public static final int DEFAULT_HUE = 100;
  public static final int DEFAULT_ACTIVITY_INDICATOR_HUE = 50;
  public RedisProc redisProc;
  public RelayHarness relayHarness;
  public NodeHarness nodeHarnessContainer;
  Ring cpsRing;

  RedisProcHarness( String _nodeName, String _ID ) {
    super( _nodeName, _ID, DEFAULT_RADIUS, DEFAULT_HUE, DEFAULT_ACTIVITY_INDICATOR_HUE );

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    process = redisProc = RedisProc_findOrCreate( nodeName, ID );
    cpsRing = new Ring(
      radius + 2,           // outer radius
      (radius + 2 - 2),     // inner radius
      32,                   // number of segments
      color( 175,100,100 ), // color
      0.0                   // rate (revolutions per second)
    );
  }

  // @override
  float calculateHue() {
    float hue = 100;

    hue -= redisProc.cpuTotal;
    return hue;
  }
  
  void preTransform() {
    drawActivity( this.pvector );
  }

  void drawHUD() {
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    translate( 200, 240 );
    pushStyle();
    fill( 200, 100, 100 );
    text( "cps: "+redisProc.cps+"\n", 0, 10, 400, 400 );
    popStyle();
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }

  void draw3D() {
    super.draw3D();

    cpsRing.draw( redisProc.cps / 100.0 );
//    drawHUD();
  }
}
