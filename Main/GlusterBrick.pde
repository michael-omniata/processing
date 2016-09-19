//The GlusterBrick class, contains the status, capacity, usage, and name of a brick
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

HashMap glusterBricks = new HashMap();
GlusterBrick GlusterBrick_findOrCreate( String nodeName, String deviceName ) {
  String brickID = nodeName+":"+deviceName;
  GlusterBrick gb = (GlusterBrick)glusterBricks.get( brickID );
  if ( gb == null ) {
    gb = new GlusterBrick( nodeName, deviceName );
    glusterBricks.put( brickID, gb );
  }
  return gb;
}

class GlusterBrick {
  public boolean status;
  public float   bytes_written;
  public float   bytes_read;
  public int     clients;
  public float   delta_read;
  public float   delta_write;
  int            updatedMillis;
  String         ID;
  String         diskID;
  GlusterNode    glusterNode;
  Disk           disk;
  
  GlusterBrick( String nodeName, String deviceName ) {
    ID            = nodeName+":"+deviceName;
    bytes_written = 0;
    bytes_read    = 0;
    clients       = 0;
    delta_read    = 0;
    delta_write   = 0;
    updatedMillis = 0;
    diskID        = ID;
    disk          = Disk_findOrCreate( nodeName, deviceName );
  }

  void setNodeContainer( GlusterNode node ) {
    glusterNode = node;
  }

  void statusToggle(boolean state) {
    if ( disk == null ) return;
    status = state;
  }

  void update( boolean _status, int _clients, float _bytes_read, float _bytes_written ) {
    status        = _status;
    clients       = _clients;
    if ( bytes_read > 0 ) { // Only make deltas when there's data
      delta_read  = _bytes_read  - bytes_read;
    }
    if ( bytes_written > 0 ) { // Only make deltas when there's data
      delta_write = _bytes_written - bytes_written;
    }
    bytes_read    = _bytes_read;
    bytes_written = _bytes_written;
  }
}
