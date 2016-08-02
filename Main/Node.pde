//The node class has an array of bricks and their names and bricks can be "attached" to it

class Node {
  ArrayList<Brick> bricks;
  String nodeName;
  public float steal;
  public float system;
  public float idle;
  public float nice;
  public float iowait;
  public float user;

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