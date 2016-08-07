

class GlusterHarness {
  int BRICK_COLUMNS = 9;
  int COLUMN_WIDTH = 100;
  int COLUMN_HEIGHT = 75;
  int COLUMN_DIVIDER = 5;
  int ROW_DIVIDER = 10;
  int NODE_SPACER = 30;
  int BRICKS_XPOS = 20;
  int BRICKS_YPOS = 80;

  public ArrayList<NodeHarness>   nodeHarnesses;
  public ArrayList<VolumeHarness> volumeHarnesses;
  public ArrayList<BrickHarness>  brickHarnesses;
  private TimedEventGenerator updateBrickTimedEventGenerator;

  float boxSize = 10;

  HarnessGroup nodeHarnessGroup;
  HarnessGroup brickHarnessGroup;

  Chart cpuUsage;

  GlusterHarness( PApplet app, String source ) {

    nodeHarnessGroup = new HarnessGroup( app, width/2, height/2, 0 );
    nodeHarnessGroup.circularLayout( 30 );
    nodeHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0.01, 0.03 );
    nodeHarnessGroup.setContainer( 90, 200, 100, 100, 80 ); // partially transparent blue sphere, radius 90
    nodeHarnessGroup.startXRotation();
    nodeHarnessGroup.startYRotation();
    nodeHarnessGroup.containerEnabled = true;

    brickHarnessGroup = new HarnessGroup( app, width/2, height/2, 0 );
    brickHarnessGroup.fibonacciSphereLayout( 250 );
    brickHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0.01, 0.01 );
    brickHarnessGroup.stopXRotation();
    brickHarnessGroup.startYRotation();

    nodeHarnesses   = new ArrayList<NodeHarness>();
    volumeHarnesses = new ArrayList<VolumeHarness>();
    brickHarnesses  = new ArrayList<BrickHarness>();

    initializeFromConfig( source );

    for ( NodeHarness nh : nodeHarnesses ) {
      nodeHarnessGroup.addHarness( nh );
    }
    for ( BrickHarness bh : brickHarnesses ) {
      brickHarnessGroup.addHarness( bh );
    }

    updateBrickTimedEventGenerator = new TimedEventGenerator(app);
    updateBrickTimedEventGenerator.setIntervalMs(1000);

    cpuUsage = cp5.addChart("cpu")
               .setPosition(50, 50)
               .setSize(200, 100)
               .setRange(0, 100)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               .setStrokeWeight(1.5)
               .setColorCaptionLabel(color(100))
               ;

    for ( NodeHarness nh : nodeHarnesses ) {
      cpuUsage.addDataSet(nh.node.nodeName);
      //cpuUsage.setColor(nh.node.nodeName,color(255,0,0) );
      cpuUsage.setData(nh.node.nodeName, new float[120]);
    }
  }

  void tickerSecond( int lastMillis, int curMillis ) {
    resetIdleBrickStats( lastMillis, curMillis );

    for ( int i = 0; i < nodeHarnesses.size(); i++ ) {
      NodeHarness nh = nodeHarnesses.get(i);
      cpuUsage.setColorValue( 100 + (i*25) );
      cpuUsage.push(nh.node.nodeName, 100 - nh.node.idle );
    }
  }

  void resetIdleBrickStats( int lastMillis, int curMillis ) {
    for ( BrickHarness bh : brickHarnesses ) {
      // if we haven't gotten any data about the brick in a while (2 seconds),
      // reset the stats.
      int deltaUpdate = curMillis - bh.updatedMillis;
      if ( deltaUpdate > 2000 ) {
        bh.brick.reads = 0;
        bh.brick.writes = 0;
        bh.brick.util = 0;
        bh.updatedMillis = curMillis;
      }
    }
  }

  BrickHarness findBrickHarness( String brickID ) {
    for ( BrickHarness bh : brickHarnesses ) {
      if ( brickID.equals( bh.brick.getID() ) ) {
        return bh;
      }
    }
    return null;
  }

  VolumeHarness findVolumeHarness( String volumeName ) {
    for (VolumeHarness harness : volumeHarnesses) {
      if ( harness.getVolume().getName().equals(volumeName) ) {
        return harness;
      }
    }
    return null;
  }

  NodeHarness findNodeHarness( String nodeName ) {
    for (NodeHarness harness : nodeHarnesses) {
      if ( harness.getNode().getName().equals(nodeName) ) {
        return harness;
      }
    }
    return null;
  }

  void initializeFromConfig( String source ) {
    JSONObject cf = loadJSONObject(source);

    JSONArray volumes = cf.getJSONArray("volumes");
    for ( int i = 0; i < volumes.size(); i++ ) {
      JSONObject volume = volumes.getJSONObject(i);
      String volumeName = volume.getString("name");
      VolumeHarness volumeHarness = new VolumeHarness(this, volumeName, 20+(120*i), 50, 100, 50 );
      volumeHarnesses.add( volumeHarness );
    }

    JSONArray nodes = cf.getJSONArray("nodes");

    for (int i = 0; i < nodes.size(); i++) { 
      JSONObject node = nodes.getJSONObject(i); 

      String nodeName = node.getString("name");
      NodeHarness nodeHarness = new NodeHarness(this, nodeName, 500+(120*i), 50, 100, 50 );
      nodeHarnesses.add( nodeHarness );

      JSONArray brickInfos = node.getJSONArray("bricks");
      for ( int j = 0; j < brickInfos.size(); j++ ) {
        JSONObject brickInfo = brickInfos.getJSONObject(j);
        String volumeName = brickInfo.getString("volume");
        String deviceName;
        try {
          deviceName = brickInfo.getString("device");
        } 
        catch (Exception e) {
          deviceName = "????";
        }

        float capacity;
        try {
          capacity = brickInfo.getFloat("capacity");
        } 
        catch (Exception e) {
          capacity = 0;
        }

        float usage;
        try {
          usage = brickInfo.getFloat("used");
        } 
        catch (Exception e) {
          usage = 0;
        }

        int use;
        try {
          use = brickInfo.getInt("use");
        } 
        catch (Exception e) {
          use = 0;
        }

        int status;
        try {
          status = brickInfo.getInt("status");
        } 
        catch (Exception e) {
          status = 0;
        }

        BrickHarness brickHarness = new BrickHarness( this, 250, 250, 100, 25 );
        brickHarness.install( new Brick( capacity ) );
        brickHarnesses.add( brickHarness );
        brickHarness.hideControllers();

        brickHarness.brick.update(
          status == 1, 
          capacity, 
          usage, 
          0, 
          0, 
          0
          );

        nodeHarness.attach( brickHarness, deviceName );
        brickHarness.setDevice( deviceName );

        VolumeHarness volumeHarness;
        if ( (volumeHarness = findVolumeHarness( volumeName )) != null ) {
          volumeHarness.attach( brickHarness );
        }
      }
    }
  }

  void updateFromJSON( JSONObject json ) {
    if (json == null) {
      println("JSONObject could not be parsed");
    } else {
      String type = json.getString("type");
      if ( type.equals("cpustat") ) {
        JSONObject cpustat = json.getJSONObject( "payload" );
        NodeHarness nh = findNodeHarness( json.getString( "host" ) );
        if ( nh != null ) {
          nh.updatedMillis = millis();
          nh.node.idle = cpustat.getFloat( "idle" );
          nh.node.system = cpustat.getFloat( "system" );
          nh.node.user = cpustat.getFloat( "user" );
          nh.node.nice = cpustat.getFloat( "nice" );
          nh.node.iowait = cpustat.getFloat( "iowait" );
          nh.node.steal = cpustat.getFloat( "steal" );
        }
      } else if ( type.equals("iostat") ) {
        JSONObject iostat = json.getJSONObject( "payload" );
        String nodeName = json.getString( "host" );
        String deviceName = iostat.getString( "device" );
        String brickID = nodeName+":"+deviceName;
        BrickHarness bh = findBrickHarness( brickID );
        if ( bh != null ) {
          bh.updatedMillis = millis();
          bh.brick.rkB = iostat.getFloat( "rkB" );
          bh.brick.wkB = iostat.getFloat( "wkB" );
          bh.brick.reads = iostat.getFloat( "reads" );
          bh.brick.writes = iostat.getFloat( "writes" );
          bh.brick.await = iostat.getFloat( "await" );
          bh.brick.r_await = iostat.getFloat( "r_await" );
          bh.brick.w_await = iostat.getFloat( "w_await" );
          bh.brick.avgqu_sz = iostat.getFloat( "avgqu_sz" );
          bh.brick.util = iostat.getFloat( "util" );
        }
      } else {
        println( "I don't know about "+type );
      }
    }
  }

  void draw3D() {
    pushMatrix();
      background(0);
      brickHarnessGroup.draw();
      nodeHarnessGroup.draw();
    popMatrix();
  }

  /*
  void draw3D_ORIG() {
    pushMatrix();
      background(0);

      //lights();
      fill(255);
      noStroke();
      translate(width/2, height/2);

      float xRot = radians(180 -  millis()*.00);
      float yRot = radians(180 -  millis()*.01);
      rotateX( xRot ); 
      rotateY( yRot );

      int counter = 0;
      for (PVector p : brick_vectors) {
        BrickHarness bh = brickHarnesses.get(counter);
        if ( calculateBrickVisibility( bh ) ) {
          pushMatrix();
            //float scaler = sin(frameCount/100.0)*1.5;
            //p = PVector.mult(p,scaler);
            translate(p.x, p.y, p.z);
            PVector polar = ds.cartesianToPolar(p);
            rotateY(polar.y);
            rotateZ(polar.z);
            fill(
              calculateBrickHue( bh ), 
              100, 
              calculateBrickBrightness( bh )
              );
            sphere(boxSize * (1+(bh.brick.util/100.0)));
          popMatrix();

          if ( (bh.brick.util) > 0 ) {
            pushStyle();
            // set the color of the line to be based on a ratio of reads to writes
            stroke(200 + (100 * bh.brick.rkB / (bh.brick.rkB+bh.brick.wkB)),100,100);
            if ( (bh.brick.rkB > 0) && (bh.brick.wkB > 0) ) { // if both reads and writes, make the line thicker
              strokeWeight(2);
            }
            line(0, 0, 0, p.x, p.y, p.z);
            popStyle();
          }
        }
        counter++;
      }
      
      pushMatrix();
      xRot = radians(180 -  millis()*.03);
      yRot = radians(180 -  millis()*.03);
      rotateX( xRot ); 
      rotateY( yRot );

      counter = 0;
      for (PVector p : node_vectors) {
        pushMatrix();
          //float scaler = sin(frameCount/100.0)*1.5;
          //p = PVector.mult(p,scaler);
          translate(p.x, p.y, p.z);
          PVector polar = ds.cartesianToPolar(p);
          rotateY(polar.y);
          rotateZ(polar.z);
          NodeHarness nh = nodeHarnesses.get(counter);
          float _hue = (100.0-(100.0-nh.node.idle));
          float _brightness = 100.0 - nh.node.iowait;
          fill( _hue, 100, _brightness );
          if ( _brightness < 80 || _hue < 80 ) {
            println( "Node "+nh.node.getName()+ " hue "+_hue+" ("+nh.node.idle+") brightness "+_brightness+" ("+nh.node.iowait+")" );
          }
          text( nh.node.nodeName, 0, 20 );
          sphere(20);
        popMatrix();
        counter++;
      }

      pushStyle();
        shininess(0);
        fill(200,100,100,80);
        sphere(70);
      popStyle();

      popMatrix();
    popMatrix();
  }
*/

  void draw2D() {
    background(0);
    for ( NodeHarness nodeHarness : nodeHarnesses ) {
      nodeHarness.update();
    }
    for ( VolumeHarness volumeHarness : volumeHarnesses ) {
      volumeHarness.update();
    }
    int brickCount = 0;
    for ( BrickHarness brickHarness : brickHarnesses ) {
      if ( brickHarness.volumeHarnessContainer.filter.getBooleanValue() &&
        brickHarness.nodeHarnessContainer.filter.getBooleanValue() ) {
        int row = brickCount / BRICK_COLUMNS;
        int col = brickCount % BRICK_COLUMNS;

        float xPosNew = ( BRICKS_XPOS + (COLUMN_WIDTH * col) + (COLUMN_DIVIDER * col) );
        float yPosNew = ( BRICKS_YPOS + COLUMN_HEIGHT + NODE_SPACER + (COLUMN_HEIGHT * row) + (ROW_DIVIDER * row) );
        brickHarness.setPosition( xPosNew, yPosNew );
        brickHarness.showControllers();
        brickHarness.update();
        brickHarness.draw();

        brickCount++;
      } else {
        brickHarness.hideControllers();
      }
    }
  }
}

