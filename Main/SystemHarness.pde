class SystemHarness {
  public ArrayList<CpuHarness>       cpuHarnesses;
  public ArrayList<DiskHarness>      diskHarnesses;
  float xPos;
  float yPos;
  float zPos;

  public HarnessGroup cpuHarnessGroup;
  public HarnessGroup diskHarnessGroup;

  SystemHarness( PApplet app, String source, int _xPos, int _yPos, int _zPos, String thisNodeName ) {
    xPos = _xPos;
    yPos = _yPos;
    zPos = _zPos;

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
    cpuHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 180, 0.01, 0.005, 0 );
    cpuHarnessGroup.setContainer( 100, 200, 100, 100, 80 ); // partially transparent blue sphere, radius 100
    cpuHarnessGroup.startXRotation();
    cpuHarnessGroup.startYRotation();
    cpuHarnessGroup.stopZRotation();
    cpuHarnessGroup.containerEnabled = true;

    cpuHarnesses      = new ArrayList<CpuHarness>();
    diskHarnesses     = new ArrayList<DiskHarness>();

    systemInitFromConfig( source, thisNodeName );

    for ( CpuHarness ch : cpuHarnesses ) {
      ch.setHarnessGroup( cpuHarnessGroup );
      cpuHarnessGroup.addHarness( ch );
    }
    for ( DiskHarness dh : diskHarnesses ) {
      dh.setHarnessGroup( diskHarnessGroup );
      dh.setCpuHarnessGroup( cpuHarnessGroup );
      diskHarnessGroup.addHarness( dh );
    }
  }

  void systemInitFromConfig( String source, String thisNodeName ) {
    JSONObject cf = loadJSONObject(source);

    JSONArray nodes = cf.getJSONArray("nodes");

    for (int i = 0; i < nodes.size(); i++) { 
      JSONObject node = nodes.getJSONObject(i); 

      // TODO: get number of processors and processor ID from config
      for ( int j = 0; j < 8; j++ ) {
        String ID = str(j);
        CpuHarness ch = CpuHarness_findOrCreate( thisNodeName, ID );
        cpuHarnesses.add( ch );
      }
      String nodeName = node.getString("name");
      if ( nodeName.equals(thisNodeName) ) {
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
        }
      }
    }
  }

  void draw3D() {
    diskHarnessGroup.draw();
    cpuHarnessGroup.draw();
  }
}
