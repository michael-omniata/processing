//The Brick class, contains the status, capacity, usage, and name of a brick
//
//written: 181382761133,
//volume: "gv2",
//status: 1,
//capacity: "1073217536",
//device: "/dev/xvdg",
//node: "gluster02-node002",
//avail: "107332380",
//use: "90",
//clients: 25,
//read: 139798448580,
//used: "965885156"

class Brick {
  public boolean status;
  public float   capacity;
  public float   usage;
  public float   bytes_written;
  public float   bytes_read;
  public int     clients;
  public String  nodeName;
  public String  deviceName;
  public int     use;
  public float   delta_read;
  public float   delta_write;

  Brick ( float cap ) {
    capacity = cap;
    status = false;
  }
  void update( boolean _status, float _capacity, float _usage, int _clients, float _bytes_read, float _bytes_written ) {
    status        = _status;
    capacity      = _capacity;
    usage         = _usage;
    clients       = _clients;
    if ( bytes_read > 0 ) { // Only make deltas when there's data
      delta_read  = _bytes_read  - bytes_read;
    }
    if ( bytes_written > 0 ) { // Only make deltas when there's data
      delta_write = _bytes_written - bytes_written;
    }
    bytes_read    = _bytes_read;
    bytes_written = _bytes_written;
    use = (int)((usage/capacity) * 100);
    println( millis()+" Use is "+use+" capacity="+capacity+" usage="+usage+" clients="+clients+" read="+bytes_read+" written="+bytes_written+" D-read="+delta_read+" D-write="+delta_write );
  }
  String getID() {
    return nodeName+":"+deviceName;
  }
  void setNodeName( String _nodeName ) {
    println( "Brick setting node name to "+_nodeName );
    nodeName = _nodeName;
  }
  void setDeviceName( String _deviceName ) {
    println( "Brick setting device name to "+_deviceName );
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
  float getUse() {
    return use;
  }
}
