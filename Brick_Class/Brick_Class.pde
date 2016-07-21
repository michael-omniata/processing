import controlP5.*;
ControlP5 cp5;

ArrayList<NodeHarness> nodeHarnesses = new ArrayList<NodeHarness>();

//Testing a brick class
BrickFactory brickFactory;
NodeHarness node001;

void setup() {
  background(175);
  rectMode(RADIUS); 
  size(800, 800);

  node001 = new NodeHarness( this, "node001", 300, 450, 100 );
  nodeHarnesses.add( node001 );
  brickFactory = new BrickFactory( this, 300, 400 );
}

void draw() {
  background(175);
  brickFactory.update();
  node001.update();
}

NodeHarness findNodeHarness( String nodeName ) {
  println( "Looking for "+nodeName );
  for (NodeHarness harness : nodeHarnesses) {
    if ( harness.getNode().getNodeName().equals(nodeName) ) {
      println( "Found "+nodeName );
      return harness;
    }
  }
  return null;
}

class Node {
  ArrayList<Brick> bricks;
  ArrayList<String> deviceNames;
  String nodeName;

  Node( String _nodeName ) {
    nodeName = _nodeName;
    deviceNames = new ArrayList<String>();
    deviceNames.add("/dev/xvaa");
    deviceNames.add("/dev/xvab");
    deviceNames.add("/dev/xvab");
    deviceNames.add("/dev/xvad");
    deviceNames.add("/dev/xvae");
    deviceNames.add("/dev/xvaf");
    deviceNames.add("/dev/xvag");
    bricks = new ArrayList<Brick>();
  }
  void mount( Brick brick ) {
    String deviceName = deviceNames.remove(deviceNames.size()-1);
    if ( deviceName == null ) {
      println( "Can't add brick; no devices available" );
      return;
    }
    brick.setDeviceName( deviceName );
    bricks.add( brick );
    println( "mounting "+deviceName );
  }
  String getNodeName() {
    println( "I am "+nodeName );
    return nodeName;
  }

  Brick unmount( String deviceName ) {
    Brick brick;
    for (int i = 0; i < bricks.size(); i++ ) {
      if ( bricks.get(i).getDeviceName().equals(deviceName) ) {
        brick = bricks.remove(i);
        brick.setDeviceName( null );
        deviceNames.add( deviceName );
        return brick;
      }
    }
    return null;
  }
}

class NodeHarness {
  int xPos, yPos;
  int boxSize;
  Node node;
  ArrayList<BrickHarness> brickHarnesses;
  ControlP5 cp5;
  NodeHarness( processing.core.PApplet theParent, String name, int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
    cp5 = new ControlP5(theParent);
    node = new Node( name );
    brickHarnesses = new ArrayList<BrickHarness>();
  }
  Node getNode() {
    return node;
  }
  void update() {
    fill(0, 0, 255);
    rect(xPos, yPos, boxSize/2, boxSize/2);
  }
  void attach( BrickHarness brickHarness ) {
    brickHarnesses.add( brickHarness );
    brickHarness.setContainer( node );
  }
}

class BrickFactory {
  int xPos, yPos;
  int boxSize;
  Bang button;
  processing.core.PApplet canvas;
  ArrayList<BrickHarness> brickHarnesses = new ArrayList<BrickHarness>();

  BrickFactory( processing.core.PApplet theParent, int x, int y ) {
    xPos = x;
    yPos = y;
    cp5 = new ControlP5(theParent);
    canvas = theParent;
    button = cp5.addBang(this, "createHarness")
      .setPosition(40, 300)
      .setSize(280, 40)
      .setTriggerEvent(Bang.RELEASE)
      .setLabel("Create Harness with brick")
      ;
  }
  void createHarness() {
    BrickHarness brickHarness = new BrickHarness( canvas, 250, 250, 100 );
    brickHarness.install( new Brick( 200, 49, false ) );
    brickHarnesses.add( brickHarness );
  }
  void update() {
    for (BrickHarness harness : brickHarnesses) {
      harness.update();
    }
  }
}


class BrickHarness {
  int xPos, yPos;
  int boxSize;
  int sliderUsageValue;
  Brick brick;
  Slider usageSlider;
  Toggle statusToggle;
  Textfield cli;
  Node container;

  BrickHarness( processing.core.PApplet theParent, int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
    container = null;
    cp5 = new ControlP5(theParent);
    usageSlider = cp5.addSlider(this, "sliderUsageValue")
      .setPosition(x-(boxSize/2), y-65)
      .setRange(0, 100)
      .setValue(0)
      ;
    statusToggle = cp5.addToggle(this, "statusToggle")
      .setPosition(x-(boxSize/2), y-105)
      .setSize(50, 20)
      .setCaptionLabel("State")
      ;
    cli = cp5.addTextfield("cli")
      .setPosition(x, y-105)
      .setAutoClear(false)
      .setSize(50, 20)
      ;
  }
  void cliCallback() {
  }
  void setContainer( Node _node ) {
    container = _node;
    statusToggle( true );
    statusToggle.setValue(true);
    println( "Attached by "+container.getNodeName() );
  }
  Node getContainer() {
    return container;
  }
  boolean install( Brick newBrick ) {
    if ( brick != null ) return false; // Harness already has a brick
    brick = newBrick;
    usageSlider.setValue( brick.getUsage() );
    statusToggle.setValue( brick.getStatus() );
    return true;
  }
  Brick remove() { // remove brick from harness and return it.
    if ( brick == null ) return null; // Harness is empty, can't remove brick
    Brick removedBrick = brick;
    brick = null;
    usageSlider.setValue( 0 );
    statusToggle.setValue( false );
    return removedBrick;
  }
  Brick getBrick() {
    return brick;
  }
  void update() {
    if ( mousePressed && mouseHovering() ) {
      setX( mouseX );
      setY( mouseY );
      usageSlider.setPosition(xPos-(boxSize/2), yPos-65);
      statusToggle.setPosition(xPos-(boxSize/2), yPos-105);
      cli.setPosition(xPos, yPos-105);
    }
    if ( container == null ) {
      String input = cli.getText();
      if ( !input.equals("") ) {
        println( "input is "+input );
        NodeHarness nodeHarness;
        if ( (nodeHarness = findNodeHarness( input )) != null) {
          nodeHarness.attach( this );
        }
      }
    } 
    if ( brick != null ) {
      brick.update();
      if (brick.getStatus() == true) {
        brick.setUsage( sliderUsageValue );
        float usage = (float)brick.getUsage() / 100;
        if (usage < .5) {
          fill(usage*255*2, 255, 0);
        } else if (usage >= .5) {
          fill(255, (1-usage)*255*2, 0);
        }
      } else {
        fill(0);
      }
      rect(xPos, yPos, boxSize/2, boxSize/2);
    }
  }
  void statusToggle(boolean state) {
    if ( brick == null ) return;
    brick.setStatus( state );
  }
  boolean mouseHovering() {
    return (
      (mouseX > xPos-(boxSize/2)) && (mouseX < (xPos+(boxSize/2))) &&
      (mouseY > yPos-(boxSize/2)) && (mouseY < (yPos+(boxSize/2)))
      );
  }
  int getX() { 
    return xPos;
  }
  int getY() { 
    return yPos;
  }
  void setX(int newX) { 
    xPos = newX;
  }
  void setY(int newY) { 
    yPos = newY;
  }
}


class Brick {
  boolean status;
  float capacity;
  int usage;
  String deviceName;

  Brick (float cap, int use, boolean state) {
    capacity = cap;
    usage = use;
    status = state;
  }
  void update() {
    // this might be used to periodically get the *actual* status of the brick
  }
  void setDeviceName( String _deviceName ) {
    deviceName = _deviceName;
  }
  String getDeviceName() {
    return deviceName;
  }
  void setStatus(boolean update) { 
    status = update;
  }
  boolean getStatus() { 
    return status;
  }
  void setCapacity(float newCap) {
    capacity = newCap;
  }
  float getCapacity() {
    return capacity;
  }
  void setUsage(int newUsage) { 
    usage = newUsage;
  }
  int getUsage() {
    return usage;
  }
}