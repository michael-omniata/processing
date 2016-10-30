

class RelayHarness {
  public RelayNodeHarness relayNodeHarness;
  public ArrayList<CpuHarness>      cpuHarnesses;
  public ArrayList<RTProcHarness>   rtProcHarnesses;
  public ArrayList<DiskHarness>     diskHarnesses;
  public ArrayList<KTServerHarness> ktserverHarnesses;
  public ArrayList<RelayStreamHarness> relayStreamHarnesses;
  public ArrayList<RelaySubStreamHarness> relaySubStreamHarnesses;
  float xPos;
  float yPos;
  float zPos;
  String nodeName;
  int total_eps;

  public RTProcHarnessGroup rtProcHarnessGroup;
  public HarnessGroup cpuHarnessGroup;
  public HarnessGroup diskHarnessGroup;
  public HarnessGroup ktserverHarnessGroup;
  public HarnessGroup relayStreamHarnessGroup;
  public HarnessGroup relaySubStreamHarnessGroup;

  Chart cpuUsage;

  RelayHarness( PApplet app, String source, int _xPos, int _yPos, int _zPos, String thisNodeName ) {
    xPos = _xPos;
    yPos = _yPos;
    zPos = _zPos;
    nodeName = thisNodeName;

    diskHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, 0 );
    diskHarnessGroup.circularLayout( 40 );
    diskHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.01, 0 );
    diskHarnessGroup.setContainer( 70, 200, 100, 100, 80 ); // partially transparent blue sphere, radius 70
    diskHarnessGroup.stopXRotation();
    diskHarnessGroup.stopYRotation();
    diskHarnessGroup.stopZRotation();
    diskHarnessGroup.containerEnabled = true;

    cpuHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, 100 );
    cpuHarnessGroup.circularLayout( 30 );
    //cpuHarnessGroup.fibonacciSphereLayout( 20 );
    cpuHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 180, 0.01, 0.005, 0 );
    cpuHarnessGroup.setContainer( 100, 200, 100, 100, 80 ); // partially transparent blue sphere, radius 100
    cpuHarnessGroup.startXRotation();
    cpuHarnessGroup.startYRotation();
    cpuHarnessGroup.stopZRotation();
    cpuHarnessGroup.containerEnabled = true;

    ktserverHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, 0 );
    ktserverHarnessGroup.circularLayout( 175 );
    ktserverHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.005, 0 );
    ktserverHarnessGroup.startXRotation();
    ktserverHarnessGroup.startYRotation();
    ktserverHarnessGroup.stopZRotation();

    rtProcHarnessGroup = new RTProcHarnessGroup( app, xPos, yPos, zPos, 0, 0, -75 );
    rtProcHarnessGroup.circularLayout( 200 );
    rtProcHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.005, 0 );
    rtProcHarnessGroup.startXRotation();
    rtProcHarnessGroup.startYRotation();
    rtProcHarnessGroup.stopZRotation();

    relayStreamHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, -150 );
    relayStreamHarnessGroup.circularLayout( 150 );
    relayStreamHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.005, 0 );
    relayStreamHarnessGroup.startXRotation();
    relayStreamHarnessGroup.startYRotation();
    relayStreamHarnessGroup.stopZRotation();

    relaySubStreamHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, -200 );
    relaySubStreamHarnessGroup.circularLayout( 75 );
    relaySubStreamHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.005, 0 );
    relaySubStreamHarnessGroup.startXRotation();
    relaySubStreamHarnessGroup.startYRotation();
    relaySubStreamHarnessGroup.stopZRotation();


    rtProcHarnesses   = new ArrayList<RTProcHarness>();
    cpuHarnesses      = new ArrayList<CpuHarness>();
    diskHarnesses     = new ArrayList<DiskHarness>();
    ktserverHarnesses = new ArrayList<KTServerHarness>();
    relayStreamHarnesses = new ArrayList<RelayStreamHarness>();
    relaySubStreamHarnesses = new ArrayList<RelaySubStreamHarness>();

    initializeFromConfig( source, thisNodeName );

    for ( CpuHarness ch : cpuHarnesses ) {
      ch.setHarnessGroup( cpuHarnessGroup );
      cpuHarnessGroup.addHarness( ch );
    }
    for ( DiskHarness dh : diskHarnesses ) {
      dh.setHarnessGroup( diskHarnessGroup );
      dh.setCpuHarnessGroup( cpuHarnessGroup );
      diskHarnessGroup.addHarness( dh );
    }
    for ( RTProcHarness rh : rtProcHarnesses ) {
      rh.setHarnessGroup( rtProcHarnessGroup );
      rh.setCpuHarnessGroup( cpuHarnessGroup );
      rtProcHarnessGroup.addHarness( rh );
    }
    for ( KTServerHarness sh : ktserverHarnesses ) {
      sh.setCpuHarnessGroup( cpuHarnessGroup );
      sh.setHarnessGroup( ktserverHarnessGroup );
      ktserverHarnessGroup.addHarness( sh );
    }
    for ( RelayStreamHarness rs : relayStreamHarnesses ) {
      rs.setCpuHarnessGroup( cpuHarnessGroup );
      rs.setHarnessGroup( relayStreamHarnessGroup );
      relayStreamHarnessGroup.addHarness( rs );
    }
    for ( RelaySubStreamHarness rs : relaySubStreamHarnesses ) {
      rs.setCpuHarnessGroup( cpuHarnessGroup );
      rs.setHarnessGroup( relaySubStreamHarnessGroup );
      relaySubStreamHarnessGroup.addHarness( rs );
    }

    cpuUsage = cp5.addChart(thisNodeName+" cpu")
               .setPosition(50, 50)
               .setSize(200, 100)
               .setRange(0, 100)
               .setView(Chart.LINE) // use Chart.LINE, Chart.PIE, Chart.AREA, Chart.BAR_CENTERED
               .setStrokeWeight(1.5)
               .setColorCaptionLabel(color(100))
               ;

    // set up the cpu usage chart
    for ( CpuHarness ch : cpuHarnesses ) {
      cpuUsage.addDataSet(ch.cpu.ID);
      cpuUsage.setData(ch.cpu.ID, new float[120]);
    }
  }

  void tickerSecond( int lastMillis, int curMillis ) {
    // update the CPU Usage chart
    for ( int i = 0; i < cpuHarnesses.size(); i++ ) {
      CpuHarness ch = cpuHarnesses.get(i);
      //cpuUsage.setColorValue( 100 + (i*25) );
      //cpuUsage.push(nh.node.nodeName, 100 - nh.node.idle );
    }
    total_eps = 0;
    for ( int i = 0; i < rtProcHarnesses.size(); i++ ) {
      total_eps += rtProcHarnesses.get(i).rtProc.real_eps;
    }
    println( "Total eps for relay "+nodeName+" is "+total_eps );
  }

  void initializeFromConfig( String source, String thisNodeName ) {
    JSONObject cf = loadJSONObject(source);

    JSONArray nodes = cf.getJSONArray("nodes");

    for (int i = 0; i < 2; i++) { 
      JSONObject node = nodes.getJSONObject(i); 

      String nodeName = node.getString("name");
      if ( nodeName.equals(thisNodeName) ) {
        RelayNodeHarness _relayNodeHarness = new RelayNodeHarness(nodeName);
        relayNodeHarnesses.put( nodeName, _relayNodeHarness );

  relayNodeHarness = _relayNodeHarness;
        // TODO: get number of processors and processor ID from config
        for ( int j = 0; j < 16; j++ ) {
          String ID = str(j);
          CpuHarness ch = CpuHarness_findOrCreate( nodeName, ID );
          cpuHarnesses.add( ch );
        }

        // Create one RTProc per shard
        // Create one ktserver per shard
        // Create one relayStream per shard
        // Create one relaySubStream per shard
        for ( int highway = 0; highway < 4; highway++ ) {
          for ( int lane = 0; lane < 8; lane++ ) {
            String ID = highway+"-"+lane;
            RTProcHarness rh = RTProcHarness_findOrCreate( nodeName, ID );
            rtProcHarnesses.add( rh );

            RelayStreamHarness rs = RelayStreamHarness_findOrCreate( nodeName, ID );
            relayStreamHarnesses.add( rs );

            RelaySubStreamHarness rss = RelaySubStreamHarness_findOrCreate( nodeName, ID );
            relaySubStreamHarnesses.add( rss );

            KTServerHarness sh = KTServerHarness_findOrCreate( nodeName, ID );
            ktserverHarnesses.add( sh );
          }
        }

        JSONArray diskInfos = node.getJSONArray("disks");
        for ( int j = 0; j < diskInfos.size(); j++ ) {
            JSONObject diskInfo = diskInfos.getJSONObject(j);
            String deviceName;
          try {
            deviceName = diskInfo.getString("device");
          } 
          catch (Exception e) {
            deviceName = "????";
          }

          DiskHarness diskHarness = new DiskHarness( nodeName, deviceName );
          diskHarness.attach( new Disk( nodeName, deviceName ) );
          diskHarnesses.add( diskHarness );
          diskHarness.hideControllers();

          relayNodeHarness.nodeHarness.attach( diskHarness );
        }
      }
    }
  }

  void draw3D() {
    diskHarnessGroup.draw();
    cpuHarnessGroup.draw();
    rtProcHarnessGroup.draw();
    ktserverHarnessGroup.draw();
    relayStreamHarnessGroup.draw();
    relaySubStreamHarnessGroup.draw();
  }
}
