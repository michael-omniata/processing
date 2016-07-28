//Main part of the program, contains all global variables and setup() and draw()

import controlP5.*;
ControlP5 cp5;

int BRICK_COLUMNS = 9;
int COLUMN_WIDTH = 100;
int COLUMN_HEIGHT = 75;
int COLUMN_DIVIDER = 5;
int ROW_DIVIDER = 10;
int NODE_SPACER = 30;
int BRICKS_XPOS = 20;
int BRICKS_YPOS = 80;


ArrayList<NodeHarness> nodeHarnesses = new ArrayList<NodeHarness>();
ArrayList<VolumeHarness> volumeHarnesses = new ArrayList<VolumeHarness>();
ArrayList<BrickHarness> brickHarnesses = new ArrayList<BrickHarness>();

BrickFactory brickFactory;

void initializeFromConfig( String filename ) {
  JSONObject cf = loadJSONObject(filename);

  JSONArray volumes = cf.getJSONArray("volumes");
  for ( int i = 0; i < volumes.size(); i++ ) {
    JSONObject volume = volumes.getJSONObject(i);
    String volumeName = volume.getString("name");
    VolumeHarness volumeHarness = new VolumeHarness(volumeName, 20+(120*i), 50, 100, 50 );
    volumeHarnesses.add( volumeHarness );
  }

  JSONArray nodes = cf.getJSONArray("nodes");

  for (int i = 0; i < nodes.size(); i++) { 
    JSONObject node = nodes.getJSONObject(i); 

    String nodeName = node.getString("name");
    NodeHarness nodeHarness = new NodeHarness(nodeName, 500+(120*i), 50, 100, 50 );
    nodeHarnesses.add( nodeHarness );

    JSONArray bricks = node.getJSONArray("bricks");
    for ( int j = 0; j < bricks.size(); j++ ) {
      JSONObject brick = bricks.getJSONObject(j);
      String volumeName = brick.getString("volume");

      String deviceName;
      try {
        deviceName = brick.getString("device");
      } 
      catch (Exception e) {
        deviceName = "????";
      }

      int capacity;
      try {
        capacity = brick.getInt("capacity");
      } 
      catch (Exception e) {
        capacity = 0;
      }

      int use;
      try {
        use = brick.getInt("use");
      } 
      catch (Exception e) {
        use = 0;
      }

      int status;
      try {
        status = brick.getInt("status");
      } 
      catch (Exception e) {
        status = 0;
      }

      println( "node="+nodeName+" dev="+deviceName+" volume="+volumeName );

      BrickHarness brickHarness = new BrickHarness( 250, 250, 100, 25 );
      brickHarness.install( new Brick( capacity, use, status == 1 ) );
      brickHarnesses.add( brickHarness );
      brickHarness.hideControllers();

      nodeHarness.attach( brickHarness, deviceName );
      brickHarness.setDevice( deviceName );

      VolumeHarness volumeHarness;
      if ( (volumeHarness = findVolumeHarness( volumeName )) != null ) {
        volumeHarness.attach( brickHarness );
      }
    }
  }
}


void setup() {
  background(175);
  size(1024, 1024);
  cp5 = new ControlP5(this);

  ellipseMode(CORNER);
  rectMode(CORNER);

  initializeFromConfig( "data/gluster-info.json" );

  frameRate(20);
}

void draw() {
  background(175);
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