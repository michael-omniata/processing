//The node class has an array of bricks and their names and bricks can be "attached" to it

class Node {
  ArrayList<Brick> bricks;
  String nodeName;

  Node( String _nodeName ) {
    nodeName = _nodeName;
    bricks = new ArrayList<Brick>();
  }
  boolean mount( Brick brick, String deviceName ) {
    brick.setDeviceName( deviceName );
    bricks.add( brick );
    println( "mounting "+deviceName );
    return true;
  }
  String getName() {
    println( "I am "+nodeName );
    return nodeName;
  }

  Brick unmount( String deviceName ) {
    Brick brick;
    for (int i = 0; i < bricks.size(); i++ ) {
      if ( bricks.get(i).getDeviceName().equals(deviceName) ) {
        brick = bricks.remove(i);
        brick.setDeviceName( null );
        return brick;
      }
    }
    return null;
  }
}