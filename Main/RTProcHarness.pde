
HashMap rtProcHarnesses = new HashMap();
RTProcHarness RTProcHarness_findOrCreate( String nodeName, String ID ) {
  String procID = nodeName+':'+ID;
  RTProcHarness rh = (RTProcHarness)rtProcHarnesses.get( procID );
  if ( rh == null ) {
    rh = new RTProcHarness( nodeName, ID );
    rtProcHarnesses.put( procID, rh );
  }
  return rh;
}

class RTProcHarness extends Harness {
  int DEFAULT_RADIUS = 10;
  public RTProc rtProc;
  public RelayHarness relayHarness;
  public NodeHarness nodeHarnessContainer;
  Ellipsoid rxIndicator;
  PVector rxIndicatorVector;
  float radius;
  String nodeName;
  String ID;
  Ring epsRing;
  Ring userStateQpsRing;
  Ring userVarQpsRing;

  Ellipsoid usTxIndicator;
  PVector usTxIndicatorVector;

  Ellipsoid uvTxIndicator;
  PVector uvTxIndicatorVector;

  RTProcHarness( String _nodeName, String _ID ) {
    super();
    nodeName = _nodeName;
    ID = _ID;
    radius = DEFAULT_RADIUS;

    setLabel( _nodeName+":"+_ID );

    rxIndicatorVector = new PVector();
    rxIndicator = new Ellipsoid( app, 16, 16 );
    rxIndicator.setRadius( 4 );
    rxIndicator.fill( color(255,255,255) );

    usTxIndicatorVector = new PVector();
    usTxIndicator = new Ellipsoid( app, 8, 8 );
    usTxIndicator.setRadius( 3 );
    usTxIndicator.fill( color(255,0,255) );

    uvTxIndicatorVector = new PVector();
    uvTxIndicator = new Ellipsoid( app, 8, 8 );
    uvTxIndicator.setRadius( 2 );
    uvTxIndicator.fill( color(255,255,0) );

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    rtProc = RTProc_findOrCreate( nodeName, ID );

    epsRing = new Ring( 
      radius + 2,       // outer radius
      (radius + 2 - 2), // inner radius
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
    //float hue = 100;
    //hue -= rtProc.cpuTotal;
    float hue = 200;
    hue += rtProc.cpuTotal;

    return hue;
  }

  // @override
  float calculateBrightness() {
    if ( (((millis() - this.rtProc.updatedMillis) / 1000) > 340) ) { // no new information after 340 means something may be wrong
      return 0;
    } 
    return 100;
  }

  float calculateActivityIndicatorBrightness() {
    return map( log(1.0+rtProc.cpuTotal)/log(10), log(1)/log(10), log(100)/log(10), 0, 100 );
  }

  // @override
  float calculateSaturation() {
    if ( rtProc.sync_inProgress ) {
      return 0;
    }
    return 100;
  }

  // @override
  float calculateRadius() {
    float factor = 1;
    if ( rtProc.bgSave_user_state_inProgress ) {
      factor += 0.5;
    }
    if ( rtProc.bgSave_user_vars_inProgress ) {
      factor += 0.5;
    }
    return radius * factor;
  }

  void startRxIndicator() {
    rxIndicator.moveTo(0,0,-200);
    rxIndicator.moveTo(0,0,0,1000.0/rtProc.eps,0);
  }
  
  void startUsTxIndicator() {
    usTxIndicator.moveTo(0,0,0);
    usTxIndicator.moveTo(0,0,200,100.0/rtProc.user_state_qps,0);
  }

  void startUvTxIndicator() {
    uvTxIndicator.moveTo(0,0,0);
    uvTxIndicator.moveTo(0,0,200,100.0/rtProc.user_var_qps,0);
  }

  void preTransform() {
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
        KTServerHarness kh = KTServerHarness_findOrCreate( nodeName, ID );
        int lineHue = -1;
        int lineWeight = 4;
        if ( rtProc.bgSave_user_state_inProgress ) {
          lineHue = 60; // yellow
          if ( rtProc.bgSave_user_vars_inProgress ) {
            lineHue = 30; // orange
            lineWeight = 6;
          }
        } else if ( rtProc.bgSave_user_vars_inProgress ) {
          lineHue = 0; // red
        }
        if ( lineHue >= 0 ) {
          strokeWeight( lineWeight );
          stroke( lineHue, 100, 100 );
          line(
            pvector.x    + relayHarness.rtProcHarnessGroup.xOffset,
            pvector.y    + relayHarness.rtProcHarnessGroup.yOffset,
            pvector.z    + relayHarness.rtProcHarnessGroup.zOffset,
            kh.pvector.x + relayHarness.ktserverHarnessGroup.xOffset,
            kh.pvector.y + relayHarness.ktserverHarnessGroup.yOffset,
            kh.pvector.z + relayHarness.ktserverHarnessGroup.zOffset
          );
        }
      popStyle();
    }
  }

  void drawActivity( PVector p0 ) {
    float radius = relayHarness.cpuHarnessGroup.containerRadius;
    if ( pvector == null ) {
      return;
    }

    CpuHarness ch = CpuHarness_findOrCreate( nodeName, str(rtProc.cpu) );
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
      float activity_saturation = 100;
      if ( activity_brightness >= 25.0 ) {
        color c = color(0,activity_saturation,activity_brightness);
        noFill();
        strokeWeight(1);
        stroke(c);

        p1 = rayTrace(
          p0.x + relayHarness.rtProcHarnessGroup.xOffset,
          p0.y + relayHarness.rtProcHarnessGroup.yOffset,
          p0.z + relayHarness.rtProcHarnessGroup.zOffset,
          0,
          0,
          0,
          radius
        ); 
        ArrayList<PVector> lines = ds.lineAroundSphere(p2,p1,relayHarness.cpuHarnessGroup.containerRadius);
        c = color(0,activity_saturation,activity_brightness);
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

  void draw3D() {
    if ( (((millis() - this.rtProc.updatedMillis) / 1000) > 340) ) { // no new information after 340 means something may be wrong
      return;
    }

    float current_radius = 10;

    super.draw3D();
    epsRing.draw( rtProc.eps / 100.0 );
    userStateQpsRing.draw( rtProc.user_state_qps / 100.0 );
    userVarQpsRing.draw( rtProc.user_var_qps / 100.0 );
    
/*
    pushStyle();
      stroke(0,0,100);
      line(0,0,0,0,0,-200);
      rxIndicator.getPosVec(rxIndicatorVector);
      usTxIndicator.getPosVec(usTxIndicatorVector);
      uvTxIndicator.getPosVec(uvTxIndicatorVector);
      if ( rxIndicatorVector.z == 0 ) {
        startRxIndicator();
      }
      if ( usTxIndicatorVector.z == 200 ) {
        startUsTxIndicator();
      }
      if ( uvTxIndicatorVector.z == 200 ) {
        startUvTxIndicator();
      }
      rxIndicator.draw();
      usTxIndicator.draw();
      uvTxIndicator.draw();

      if ( rtProc.clients > 0 ) {
        line(0,0,0,0,0,200);
        pushMatrix();
          translate(0,0,200);
          fill(255,255,255);
          sphere(sqrt(rtProc.clients/(4*3.14159)));
        popMatrix();
      }
    popStyle();
*/
  }
}
