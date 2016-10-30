

class RedisHarness extends SystemHarness {
  public RedisNodeHarness            redisNodeHarness;

  public ArrayList<RedisProcHarness> redisProcHarnesses;
  public HarnessGroup                redisProcHarnessGroup;

  RedisHarness( PApplet app, String source, int _xPos, int _yPos, int _zPos, String thisNodeName ) {
    super( app, source, _xPos, _yPos, _zPos, thisNodeName );
    redisHarnessInit( source, thisNodeName );
  }

  void redisHarnessInit( String source, String thisNodeName ) {
    redisProcHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, -75 );
    redisProcHarnessGroup.helixLayout( 5, 30, 32, 70 );
    //redisProcHarnessGroup.fibonacciSphereLayout( 40 );
    redisProcHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.005, 0 );
    redisProcHarnessGroup.startXRotation();
    redisProcHarnessGroup.startYRotation();
    redisProcHarnessGroup.stopZRotation();

    redisProcHarnesses   = new ArrayList<RedisProcHarness>();
    initializeFromConfig( source, thisNodeName );

    for ( RedisProcHarness rh : redisProcHarnesses ) {
      rh.setHarnessGroup( redisProcHarnessGroup );
      rh.setCpuHarnessGroup( this.cpuHarnessGroup );
      redisProcHarnessGroup.addHarness( rh );
    }
  }

  void initializeFromConfig( String source, String thisNodeName ) {
    JSONObject cf = loadJSONObject(source);

    JSONArray nodes = cf.getJSONArray("nodes");

    // Initalize both redis instances
    for (int i = 0; i < nodes.size(); i++) { 
      JSONObject node = nodes.getJSONObject(i); 

      String nodeName = node.getString("name");
      if ( nodeName.equals(thisNodeName) ) {
        RedisNodeHarness _redisNodeHarness = new RedisNodeHarness(nodeName);
        redisNodeHarnesses.put( nodeName, _redisNodeHarness );

        this.redisNodeHarness = _redisNodeHarness;
        
        // Create one redisProc per shard
        for ( int highway = 0; highway < 4; highway++ ) {
          for ( int lane = 0; lane < 8; lane++ ) {
            String ID = highway+"-"+lane;
            RedisProcHarness rh = RedisProcHarness_findOrCreate( nodeName, ID );
            redisProcHarnesses.add( rh );
          }
        }
      }
    }
  }

  void draw3D() {
    super.draw3D();
    redisProcHarnessGroup.draw();
  }
}
