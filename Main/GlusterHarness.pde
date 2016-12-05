//GlusterHarness class contains GUI for the overall system of nodes, bricks, and volumes

class GlusterHarness {
  public float xPos;
  public float yPos;
  public float zPos;
  public ArrayList<GlusterNodeHarness>   nodeHarnesses;
  public ArrayList<GlusterVolumeHarness> volumeHarnesses;
  public ArrayList<GlusterBrickHarness>  brickHarnesses;

  float boxSize = 10;

  HarnessGroup nodeHarnessGroup;
  HarnessGroup brickHarnessGroup;
  HarnessGroup volumeHarnessGroup;

  Chart cpuUsage;

  GlusterHarness( PApplet app, String source, float _xPos, float _yPos, float _zPos ) {
    xPos = _xPos;
    yPos = _yPos;
    zPos = _zPos;
    volumeHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, 0 );
    volumeHarnessGroup.concentricSphereLayout( 70, 210 );
    volumeHarnessGroup.containerEnabled = false;
    volumeHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.01, 0 );
    volumeHarnessGroup.stopXRotation();
    volumeHarnessGroup.startYRotation();
    volumeHarnessGroup.stopZRotation();

    nodeHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, 0 );
    nodeHarnessGroup.circularLayout( 30 );
    nodeHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.01, 0 );
    nodeHarnessGroup.setContainer( 90, 200, 100, 100, 80 ); // partially transparent blue sphere, radius 80
    nodeHarnessGroup.stopXRotation();
    nodeHarnessGroup.startYRotation();
    nodeHarnessGroup.stopZRotation();
    nodeHarnessGroup.containerEnabled = true;

    brickHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, 0 );
    brickHarnessGroup.fibonacciSphereLayout( 250 );
    //brickHarnessGroup.circularLayout( 250 );
    //brickHarnessGroup.vogelLayout( 100 ); // parameter specifies the size of each "node"; influences the spacing between them
    //brickHarnessGroup.spiralLayout( 200, 0.1, 0.35, 0.90 ); // radius, resolution, spacing, increment
    brickHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.01, 0 );
    brickHarnessGroup.stopXRotation();
    brickHarnessGroup.startYRotation();
    brickHarnessGroup.stopZRotation();

    nodeHarnesses   = new ArrayList<GlusterNodeHarness>();
    volumeHarnesses = new ArrayList<GlusterVolumeHarness>();
    brickHarnesses  = new ArrayList<GlusterBrickHarness>();

    initializeFromConfig( source );

    for ( GlusterNodeHarness nh : nodeHarnesses ) {
      nodeHarnessGroup.addHarness( nh );
    }
    for ( GlusterBrickHarness bh : brickHarnesses ) {
      brickHarnessGroup.addHarness( bh );
    }
    for ( GlusterVolumeHarness vh : volumeHarnesses ) {
      volumeHarnessGroup.addHarness( vh );
    }

    cpuUsage = cp5.addChart("cpu")
               .setPosition(50, 50)
               .setSize(200, 100)
               .setRange(0, 100)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               .setStrokeWeight(1.5)
               .setColorCaptionLabel(color(100))
               ;

    // set up the cpu usage chart
    for ( GlusterNodeHarness nh : nodeHarnesses ) {
      cpuUsage.addDataSet(nh.glusterNode.node.nodeName);
      //cpuUsage.setColor(nh.node.nodeName,color(255,0,0) );
      cpuUsage.setData(nh.glusterNode.node.nodeName, new float[120]);
    }
  }

  void tickerSecond( int lastMillis, int curMillis ) {
    // update the CPU Usage chart
    for ( int i = 0; i < nodeHarnesses.size(); i++ ) {
      GlusterNodeHarness nh = nodeHarnesses.get(i);
      cpuUsage.setColorValue( 100 + (i*25) );
      cpuUsage.push(nh.glusterNode.node.nodeName, 100 - nh.glusterNode.node.idle );
    }
  }

  GlusterBrickHarness findBrickHarness( String brickID ) {
    for ( GlusterBrickHarness bh : brickHarnesses ) {
      if ( brickID.equals( bh.brick.disk.ID ) ) {
        return bh;
      }
    }
    return null;
  }

  GlusterVolumeHarness findVolumeHarness( String volumeName ) {
    for (GlusterVolumeHarness harness : volumeHarnesses) {
      if ( harness.glusterVolume.volumeName.equals(volumeName) ) {
        return harness;
      }
    }
    return null;
  }

  GlusterNodeHarness findNodeHarness( String nodeName ) {
    for (GlusterNodeHarness harness : nodeHarnesses) {
      if ( harness.glusterNode.node.nodeName.equals(nodeName) ) {
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
      GlusterVolumeHarness volumeHarness = GlusterVolumeHarness_findOrCreate( volumeName );
      volumeHarnesses.add( volumeHarness );
    }

    JSONArray nodes = cf.getJSONArray("nodes");

    for (int i = 0; i < nodes.size(); i++) { 
      JSONObject node = nodes.getJSONObject(i); 

      String nodeName = node.getString("name");
      GlusterNodeHarness nodeHarness = GlusterNodeHarness_findOrCreate(nodeName);
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

        int status;
        try {
          status = brickInfo.getInt("status");
        } 
        catch (Exception e) {
          status = 0;
        }

        GlusterBrickHarness brickHarness = new GlusterBrickHarness( nodeName, deviceName );
        brickHarness.attach( new GlusterBrick( nodeName, deviceName ) );
        brickHarnesses.add( brickHarness );
        brickHarness.hideControllers();

        brickHarness.brick.update( status == 1, 0, 0, 0 );

        nodeHarness.attach( brickHarness );

        GlusterVolumeHarness volumeHarness;
        if ( (volumeHarness = findVolumeHarness( volumeName )) != null ) {
          volumeHarness.attach( brickHarness );
        }
      }
    }
  }

  void draw3D() {
    pushMatrix();
      brickHarnessGroup.draw();
      nodeHarnessGroup.draw();
      volumeHarnessGroup.draw();
    popMatrix();
  }
}