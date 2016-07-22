//The node class has an array of bricks and their names and bricks can be "attached" to it

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