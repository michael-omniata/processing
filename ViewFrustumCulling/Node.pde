//The node class has an array of bricks and their names and bricks can be "attached" to it
HashMap nodes = new HashMap();

Node Node_findOrCreate( String nodeName ) {
  Node n = (Node)nodes.get( nodeName );
  if ( n == null ) {
    n = new Node( nodeName );
    nodes.put( nodeName, n );
  }
  return n;
}

class Node {
  public String nodeName;
  public float steal;
  public float system;
  public float idle;
  public float nice;
  public float iowait;
  public float user;
  public int   updatedMillis;
  public HashMap cpus;
  public HashMap disks;

  Node( String _nodeName ) {
    nodeName = _nodeName;
    steal    = 0;
    system   = 0;
    idle     = 0;
    nice     = 0;
    iowait   = 0;
    user     = 0;
    updatedMillis = 0;
    disks    = new HashMap();
    cpus     = new HashMap();
  }

  void attach( Cpu cpu ) {
    cpus.put( cpu.ID, cpu );
  }

  void attach( Disk disk ) {
    disks.put( disk.ID, disk );
    disk.setNodeContainer( this );
  }

  void remove( Disk disk ) {
    disks.remove( disk.ID );
    disk.setNodeContainer( null );
  }

}
