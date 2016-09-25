HashMap cpus = new HashMap();
Cpu Cpu_findOrCreate( String nodeName, String ID ) {
  String cpuID = nodeName+':'+ID;
  Cpu c = (Cpu)cpus.get( cpuID );
  if ( c == null ) {
    c = new Cpu( nodeName, cpuID );
    cpus.put( cpuID, c );
  }
  return c;
}


class Cpu {
  String ID;
  public float steal;
  public float system;
  public float idle;
  public float nice;
  public float iowait;
  public float user;
  Node node;

  Cpu( String _nodeName, String _ID ) {
    node = Node_findOrCreate( _nodeName );
    ID = _ID;
  }
}

