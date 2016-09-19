//The Disk class, contains the status, capacity, usage, and name of a disk

HashMap disks = new HashMap();

Disk Disk_findOrCreate( String nodeName, String deviceName ) {
  String diskID = nodeName+":"+deviceName;
  Disk d = (Disk)disks.get( diskID );
  if ( d == null ) {
    d = new Disk( nodeName, deviceName );
    disks.put( diskID, d );
  }
  return d;
}

class Disk {
  public int    use;
  public float  used;
  public float  capacity;
  public float  avail;
  public String mountpoint;
  public String deviceName;
  public String nodeName;
  public String ID;
  public Node   node;
  
  public float rkB; // kilobytes per second read
  public float wkB; // kilobytes per second written
  public float reads; // reads per second
  public float writes; // writes per second
  public float rrqm; // read requests merged per second
  public float wrqm; // write requests merged per second
  public float avgqu_sz; // The average queue length of the requests that were issued to the device.
  public float r_await; // average time spent (in milliseconds) spent waiting for a read request
  public float w_await; // average time spent (in milliseconds) spent waiting for a write request
  public float await; // average time spent (in milliseconds) spent waiting for a request
  public float util; // percentage of device utilization (saturation level)

  int updatedMillis;

  Disk( String _nodeName, String _deviceName ) {
    nodeName      = _nodeName;
    deviceName    = _deviceName;
    ID            = _nodeName+":"+_deviceName;
    node          = null;
    updatedMillis = 0;
  }

  void setNodeContainer( Node _node ) {
    node = _node;
  }
}
