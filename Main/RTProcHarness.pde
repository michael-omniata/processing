
HashMap rtProcHarnesses = new HashMap();
RTProcHarness RTProcHarness_findOrCreate( String nodeName, String ID ) {
  String procID = nodeName+':'+ID;
  RTProcHarness rh = (RTProcHarness)rtProcHarnesses.get( procID );
  if ( rh == null ) {
    rh = new RTProcHarness( nodeName, ID );
println( "created RTProcHarness for "+procID );
    rtProcHarnesses.put( procID, rh );
  }
  return rh;
}

class RTProcHarnessGroup extends HarnessGroup {
  int total_eps;

  RTProcHarnessGroup( PApplet app, float _xPos, float _yPos, float _zPos, float _xOffset, float _yOffset, float _zOffset ) {
    super( app, _xPos, _yPos, _zPos, _xOffset, _yOffset, _zOffset );
  }
}

class RTProcHarness extends ProcessHarness {
  public static final int DEFAULT_RADIUS = 10;
  public static final int DEFAULT_HUE = 200;
  public static final int DEFAULT_ACTIVITY_INDICATOR_HUE = 0;
  public RelayHarness relayHarness;
  public NodeHarness nodeHarnessContainer;
  Ring epsRing;
  Ring userStateQpsRing;
  Ring userVarQpsRing;
  RTProc rtProc;

  RTProcHarness( String _nodeName, String _ID ) {
    super( _nodeName, _ID, DEFAULT_RADIUS, DEFAULT_HUE, DEFAULT_ACTIVITY_INDICATOR_HUE );

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    process = rtProc = RTProc_findOrCreate( nodeName, ID );

    epsRing = new Ring( 
      radius + 2,               // outer radius
      (radius + 2 - 2),         // inner radius
      32,                       // number of segments
      color( 250,100,100 ),     // color
      0.0                       // rate (revolutions per second)
    );
    userStateQpsRing = new Ring(
      radius + 5,
      (radius + 5 - 2),
      32,
      color( 300,100,100 ),
      0.0
    );
    userVarQpsRing = new Ring(
      radius + 8,
      (radius + 8 - 2),
      32,
      color( 100,100,100 ),
      0.0
    );
  }

  // @override
  float calculateHue() {
    return 200 + this.process.cpuTotal;
  }

  // @override
  float calculateSaturation() {
    if ( this.rtProc.sync_inProgress ) {
      return 0;
    }
    return 100;
  }

  // @override
  float calculateRadius() {
    float factor = 1;
    if ( this.rtProc.bgSave_user_state_inProgress ) {
      factor += 0.5;
    }
    if ( this.rtProc.bgSave_user_vars_inProgress ) {
      factor += 0.5;
    }
    return radius * factor;
  }

  void preTransform() {
    drawActivity( pvector );

    if ( pvector != null ) {
      /* Draw a line from RTProc to KTserver when evRTProc is background
       * saving data.
       */
      pushStyle();
        KTServerHarness kh = KTServerHarness_findOrCreate( nodeName, ID );
        int lineHue = -1;
        int lineWeight = 4;
        if ( this.rtProc.bgSave_user_state_inProgress ) {
          lineHue = 60; // yellow
          if ( this.rtProc.bgSave_user_vars_inProgress ) {
            lineHue = 30; // orange
            lineWeight = 6;
          }
        } else if ( this.rtProc.bgSave_user_vars_inProgress ) {
          lineHue = 0; // red
        }
        if ( lineHue >= 0 ) {
          strokeWeight( lineWeight );
          stroke( lineHue, 100, 100 );
          line(
            pvector.x    + this.harnessGroup.xOffset,
            pvector.y    + this.harnessGroup.yOffset,
            pvector.z    + this.harnessGroup.zOffset,
            kh.pvector.x + kh.harnessGroup.xOffset,
            kh.pvector.y + kh.harnessGroup.yOffset,
            kh.pvector.z + kh.harnessGroup.zOffset
          );
        }
      popStyle();
    }
  }

  void draw3D() {
    super.draw3D();
    epsRing.draw( this.rtProc.eps / 100.0 );
    userStateQpsRing.draw( this.rtProc.user_state_qps / 100.0 );
    userVarQpsRing.draw( this.rtProc.user_var_qps / 100.0 );
  }
}
