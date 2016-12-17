//Volume has bricks assigned to it from different nodes
HashMap glusterVolumes = new HashMap();

GlusterVolume GlusterVolume_findOrCreate( String volumeName ) {
  GlusterVolume gv = (GlusterVolume)glusterVolumes.get( volumeName );
  if ( gv == null ) {
    gv = new GlusterVolume( volumeName );
    glusterVolumes.put( volumeName, gv );
  }
  return gv;
}

class GlusterVolume {
  String volumeName;
  boolean status;
  float usage, capacity;
  ArrayList<GlusterBrick> bricks;

  GlusterVolume( String _volumeName ) {
    volumeName = _volumeName;
    bricks = new ArrayList<GlusterBrick>();
    capacity = this.getCapacity();
  }

  void setName(String newName) {
    volumeName = newName;
  }

  String getName() {
    return volumeName;
  }
  void addBrick( GlusterBrick _brick ) {
    bricks.add( _brick );
    capacity = getCapacity();
  }

  float getCapacity() { //This sets every time a change is made to capacity
    capacity = 0;
    println( "checking "+bricks.size()+" bricks" );
    for (int i = 0; i < bricks.size(); i++) {
      GlusterBrick temp = bricks.get(i);
      println( "brick "+i+" capacity is "+temp.disk.capacity );
      capacity += temp.disk.capacity;
    }
    println( "Volume capacity is "+capacity );
    return capacity;
  }

  float getUsage() {
    usage = 0;
    if ( capacity == 0 ) return 0;
    for (int i = 0; i < bricks.size(); i++) {
      GlusterBrick temp = bricks.get(i);
      usage += temp.disk.use;
    }
    usage /= bricks.size();
    return (100*(usage/100*capacity)/capacity);
  }
}
