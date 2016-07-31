//Main part of the program, contains all global variables and setup() and draw()

import controlP5.*;
ControlP5 cp5;

import websockets.*;
WebsocketClient wsc;

int mode = 2; // 2=2D, 3=3D

int BRICK_COLUMNS = 9;
int COLUMN_WIDTH = 100;
int COLUMN_HEIGHT = 75;
int COLUMN_DIVIDER = 5;
int ROW_DIVIDER = 10;
int NODE_SPACER = 30;
int BRICKS_XPOS = 20;
int BRICKS_YPOS = 80;

import org.multiply.processing.TimedEventGenerator;
private TimedEventGenerator updateBrickTimedEventGenerator;
private int lastMillis = 0;


ArrayList<NodeHarness> nodeHarnesses = new ArrayList<NodeHarness>();
ArrayList<VolumeHarness> volumeHarnesses = new ArrayList<VolumeHarness>();
ArrayList<BrickHarness> brickHarnesses = new ArrayList<BrickHarness>();

BrickFactory brickFactory;

void initializeFromConfig( String source ) {
  JSONObject cf = loadJSONObject(source);

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

      println( "node="+nodeName+" dev="+deviceName+" volume="+volumeName );

      BrickHarness brickHarness = new BrickHarness( 250, 250, 100, 25 );
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


void setup() {
  //  if ( mode == 2 ) {
  //    size(1024, 1024);
  //  } else {
  size(1024, 1024, P3D);
  //  }
  cp5 = new ControlP5(this);

  initializeFromConfig( "http://ec2-54-158-33-191.compute-1.amazonaws.com:3001/gluster" );
  // initializeFromConfig( "data/gluster-info.json" );

  wsc = new WebsocketClient(this, "ws://ec2-54-158-33-191.compute-1.amazonaws.com:3001/gluster/stats");

 // updateBrickTimedEventGenerator = new TimedEventGenerator(this);
 // updateBrickTimedEventGenerator.setIntervalMs(30000);

  if ( mode == 2 ) {
    background(0);
    ellipseMode(CORNER);
    rectMode(CORNER);
    frameRate(20);
  } else if ( mode == 3 ) {
    setup3D();
  }
}

void updateBrickStates() {
  println( "Updating bricks" );
  JSONObject cf = loadJSONObject("http://ec2-54-158-33-191.compute-1.amazonaws.com:3001/gluster/bricks");
  println( "Got states" );

  JSONArray brickInfos = cf.getJSONArray("bricks");
  for ( int i = 0; i < brickInfos.size(); i++ ) {
    JSONObject brickInfo = brickInfos.getJSONObject(i);
    BrickHarness brickHarness = findBrickHarness( brickInfo.getString("node")+":"+brickInfo.getString("device") );
    if ( brickHarness != null) {
      Brick brick = brickHarness.brick;
      brick.update(
        brickInfo.getInt("status") == 1, 
        brickInfo.getFloat("capacity"), 
        brickInfo.getFloat("used"), 
        brickInfo.getInt("clients"), 
        brickInfo.getFloat("read"), 
        brickInfo.getFloat("written")
        );
    }
  }
  println("Bricks updates");
}


void onTimerEvent() {
  int millisDiff = millis() - lastMillis;
  lastMillis = millisDiff + lastMillis;  
  println("Got a timer event at " + millis() + "ms (" + millisDiff + ")!");
  updateBrickStates();
  println("Required "+(millis()-lastMillis)+" milliseconds" );
}


void draw() {
  if ( mode == 2 ) {
    draw2D();
  } else if ( mode == 3 ) {
    draw3D();
  }
}

import dawesometoolkit.*;
DawesomeToolkit ds;
ArrayList<PVector> vectors;
float boxSize = 10;

void drawLights() {
  float spotX = width;
  float spotY = height/2;
  float spotZ = 0;
  spotLight(234, 60, 138, spotX, spotY, spotZ, -1, 0, 1, PI/2, 2);

  spotX = width;
  spotY = 0;
  spotZ = 0;
  spotLight(125, 185, 222, spotX, spotY, spotZ, -1, 0, 0, PI/2, 2);
}

color calculateBrickHue( BrickHarness bh ) {
  if (bh.brick.getStatus() == true) {
    float use = (float)bh.brick.getUse() / 100;
    if (use < .5) {
      return color(use*255*2, 255, 0);
    } else if (use >= .5) {
      return color(255, (1-use)*255*2, 0);
    }
  }
  return( color(0) );
}

color calculateBrickBrightness( BrickHarness bh ) {
  int boffset = 20;
  if (bh.brick.getStatus() == true) {
    if ( bh.brick.reads > 0 ) {
      boffset += 20;
    }
    if ( bh.brick.writes > 0 ) {
      boffset += 50;
    }
  } 
  return( boffset );
}

boolean calculateBrickVisibility( BrickHarness bh ) {
  return bh.nodeHarnessContainer.filter.getState() &&
    bh.volumeHarnessContainer.filter.getState();
}

void setup3D() {
  smooth();
  cp5.setAutoDraw(false);

  //colorMode(HSB, color(255,255,255), 100, 100, 100 );
  colorMode(HSB, 255, 100, 100, 100);

  ds = new DawesomeToolkit(this);
  vectors = ds.fibonacciSphereLayout(brickHarnesses.size(), 300);
}

void draw3D() {

  pushMatrix();
  background(0);
  //    drawLights();
  lights();
  fill(255);
  noStroke();
  translate(width/2, height/2);
  float xRot = radians(180 -  millis()*.00);
  float yRot = radians(180 -  millis()*.01);
  rotateX( xRot ); 
  rotateY( yRot );

  int counter = 0;
  for (PVector p : vectors) {
    pushMatrix();
    //float scaler = sin(frameCount/100.0)*1.5;
    //p = PVector.mult(p,scaler);
    translate(p.x, p.y, p.z);
    PVector polar = ds.cartesianToPolar(p);
    rotateY(polar.y);
    rotateZ(polar.z);
    BrickHarness bh = brickHarnesses.get(counter);
    if ( calculateBrickVisibility( bh ) ) {
      fill(
        calculateBrickHue( bh ), 
        100, 
        calculateBrickBrightness( bh )
        );
      //box(boxSize,boxSize,boxSize);
      sphere(boxSize);
    }
    popMatrix();
    counter++;
  }
  popMatrix();
  gui();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  cp5.draw();
  hint(ENABLE_DEPTH_TEST);
}

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

void webSocketEvent(String msg) {
  JSONObject json = parseJSONObject(msg);
  if (json == null) {
    println("JSONObject could not be parsed");
  } else {
    String type = json.getString("type");
    if ( type.equals("cpustat") ) {
      JSONObject cpustat = json.getJSONObject( "payload" );
      NodeHarness nh = findNodeHarness( json.getString( "host" ) );
      if ( nh != null ) {
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