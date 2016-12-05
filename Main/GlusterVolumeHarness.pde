//the GlusterVolumeHarness contains the GUI for Volumes

HashMap glusterVolumeHarnesses = new HashMap();
GlusterVolumeHarness GlusterVolumeHarness_findOrCreate( String volumeName ) {
  GlusterVolumeHarness vh = (GlusterVolumeHarness)glusterVolumeHarnesses.get( volumeName );
  if ( vh == null ) {
    vh = new GlusterVolumeHarness( volumeName );
    glusterVolumeHarnesses.put( volumeName, vh );
  }
  return vh;
}

class GlusterVolumeHarness extends Harness {
  GlusterVolume glusterVolume;

  GlusterVolumeHarness( String volumeName ) {
    super();
    glusterVolume = GlusterVolume_findOrCreate( volumeName );
  }

  void attach( GlusterBrickHarness _brickHarness ) {
    glusterVolume.addBrick( _brickHarness.brick );
    _brickHarness.setVolumeContainer( this );
    glusterVolume.getCapacity();
  }

  // @override
  void draw3D() {
    Iterator i = glusterNodeHarnesses.entrySet().iterator();  // Get an iterator

    while ( i.hasNext() ) {
      HashMap.Entry me = (HashMap.Entry)i.next();
      GlusterNodeHarness gn = (GlusterNodeHarness)me.getValue();
      PVector p = gn.pvector.copy();
      p.normalize();
      p.mult(radius);
      pushStyle();
      pushMatrix();
        translate(p.x,p.y,p.z);
        //stroke(0,0,100);
        //strokeWeight(1.5);
        //line( 0, 0, 0, p.x, p.y, p.z );
        fill(0,0,255);
        sphere(5);
      popMatrix();
      popStyle();
    }
  }
}