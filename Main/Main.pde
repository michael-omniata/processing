//Main part of the program, contains all global variables and setup() and draw()

import controlP5.*;
ControlP5 cp5;


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
    VolumeHarness volumeHarness = new VolumeHarness(volumeName, 20+(120*i), 150, 100, 50 );
    volumeHarnesses.add( volumeHarness );
  }

  JSONArray nodes = cf.getJSONArray("nodes");

//for (int i = 0; i < nodes.size(); i++) { 
  for (int i = 0; i < 1; i++) { 
    JSONObject node = nodes.getJSONObject(i); 

    String nodeName = node.getString("name");
    NodeHarness nodeHarness = new NodeHarness(nodeName, 20+(120*i), 250, 100, 50 );
    nodeHarnesses.add( nodeHarness );

    JSONArray bricks = node.getJSONArray("bricks");
    for ( int j = 0; j < bricks.size(); j++ ) {
      JSONObject brick = bricks.getJSONObject(i);
      String volumeName = brick.getString("volume");
      String deviceName = brick.getString("device");
      int capacity = brick.getInt("capacity");
      int use = brick.getInt("use");
      int status = brick.getInt("status");

      BrickHarness brickHarness = new BrickHarness( 250, 250, 100, 50 );
      brickHarness.install( new Brick( capacity, use, status == 1 ) );
      brickHarnesses.add( brickHarness );

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

  brickFactory = new BrickFactory( 0, 0, 50, 50 );
  brickFactory.setColor( color( 0, 0, 255 ) );
}

void draw() {
  background(175);
  brickFactory.update();
  for ( NodeHarness nodeHarness : nodeHarnesses ) {
    nodeHarness.update();
  }
  for ( VolumeHarness volumeHarness : volumeHarnesses ) {
    volumeHarness.update();
  }
  for ( BrickHarness brickHarness : brickHarnesses ) {
    brickHarness.update();
  }
}