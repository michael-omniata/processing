
class WorkerHarness extends SystemHarness {
  public WorkerNodeHarness      workerNodeHarness;

  public ArrayList<ProcHarness> procHarnesses;
  public HarnessGroup           procHarnessGroup;

  WorkerHarness( PApplet app, String source, int _xPos, int _yPos, int _zPos, String _nodeName ) {
    super( app, source, _xPos, _yPos, _zPos, _nodeName );
    workerHarnessInit( source, _nodeName );
  }

  void workerHarnessInit( String source, String _nodeName ) {
    procHarnessGroup = new HarnessGroup( app, xPos, yPos, zPos, 0, 0, -75 );
    procHarnessGroup.helixLayout( 5, 30, 32, 70 );
    procHarnessGroup.setRotationAnglesAndSpeeds( 180, 180, 0, 0.01, 0.005, 0 );
    procHarnessGroup.startXRotation();
    procHarnessGroup.startYRotation();
    procHarnessGroup.stopZRotation();

    procHarnesses   = new ArrayList<ProcHarness>();
    initializeFromConfig( source, _nodeName );

    for ( ProcHarness ph : procHarnesses ) {
      ph.setHarnessGroup( procHarnessGroup );
      ph.setCpuHarnessGroup( this.cpuHarnessGroup );
      procHarnessGroup.addHarness( ph );
    }
  }

  void initializeFromConfig( String source, String _nodeName ) {
    JSONObject cf = loadJSONObject(source);

    WorkerNodeHarness _workerNodeHarness = new WorkerNodeHarness(_nodeName);
    workerNodeHarnesses.put( _nodeName, _workerNodeHarness );

    this.workerNodeHarness = _workerNodeHarness;
        
    // Create one proc per shard
    for ( int highway = 0; highway < 4; highway++ ) {
      for ( int lane = 0; lane < 8; lane++ ) {
        String ID = highway+"-"+lane;
        ProcHarness ph = ProcHarness_findOrCreate( _nodeName, ID );
        procHarnesses.add( ph );
      }
    }
  }

  void draw3D() {
    super.draw3D();
    procHarnessGroup.draw();
  }
}
