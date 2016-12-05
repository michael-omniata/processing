//The DiskHarness class is the GUI for a Disk, attributes can be adjusted through ControlP5 for testing

HashMap diskHarnesses = new HashMap();
DiskHarness DiskHarness_findOrCreate( String nodeName, String deviceName ) {
  String diskID = nodeName+':'+deviceName;
  DiskHarness dh = (DiskHarness)diskHarnesses.get( diskID );
  if ( dh == null ) {
    dh = new DiskHarness( nodeName, deviceName );
    diskHarnesses.put( diskID, dh );
  }
  return dh;
}


class DiskHarness extends Harness {
  int DEFAULT_RADIUS = 10;

  public Disk disk;
  public NodeHarness nodeHarnessContainer;
  public HarnessGroup cpuHarnessGroup;
  float radius;

  DiskHarness( String nodeName, String deviceName ) {
    super();
    radius = DEFAULT_RADIUS;

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    disk = Disk_findOrCreate( nodeName, deviceName );
  }

  void setNodeContainer( NodeHarness _nodeHarness ) {
    nodeHarnessContainer = _nodeHarness;
  }

  void setCpuHarnessGroup( HarnessGroup cpuHarnessGroup ) {
    this.cpuHarnessGroup = cpuHarnessGroup;
  }

  boolean attach( Disk _disk ) {
    if ( disk != null ) return false; // Harness already has a disk
    disk = _disk;
    return true;
  }

  float calculateHue() {
    return (100.0-disk.use);
  }

  float calculateBrightness() {
    float boffset = 60;
    if ( disk.reads > 0 ) {
      boffset += 20;
    }
    if ( disk.writes > 0 ) {
      boffset += 20;
    }
    return( boffset );
  }

  float calculateSaturation() {
    return 100;
  }

  float calculateRadius() {
    return (radius * (1+(disk.util/100.0)));
  }

  boolean hasActivity() {
    return (disk.util > 0);
  }

  float calculateActivityIndicatorHue() {
    return (200 + (100 * disk.rkB / (disk.rkB+disk.wkB)));
  }
  float calculateActivityIndicatorBrightness() {
    return 100;
  }
  float calculateActivityIndicatorSaturation() {
    return 100;
  }

  float calculateActivityIndicatorWeight() {
    if ( disk.rkB > 0 && disk.wkB > 0 ) {
      return 2;
    }
    return 1;
  }

  boolean calculateVisibility() {
    //return nodeHarnessContainer.filter.getState();
    return true;
  }

  void drawActivity( PVector p ) {
    pushStyle();
    stroke( calculateActivityIndicatorHue(), calculateActivityIndicatorBrightness(), calculateActivityIndicatorSaturation() );
    line( 0, 0, 0, p.x, p.y, p.z );
    popStyle();
  }
}