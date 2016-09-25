//The NodeHarness class contains the GUI for the node

HashMap glusterNodeHarnesses = new HashMap();
GlusterNodeHarness GlusterNodeHarness_findOrCreate( String volumeName ) {
  GlusterNodeHarness gh = (GlusterNodeHarness)glusterNodeHarnesses.get( volumeName );
  if ( gh == null ) {
    gh = new GlusterNodeHarness( volumeName );
    glusterNodeHarnesses.put( volumeName, gh );
  }
  return gh;
}

class GlusterNodeHarness extends Harness {
  GlusterNode glusterNode;
  ArrayList<GlusterBrickHarness> brickHarnesses;
  public int activeBricks = 0;
  float radius = 20;
  
  GlusterNodeHarness( String nodeName ) {
    super();
    glusterNode = new GlusterNode( nodeName );
    brickHarnesses = new ArrayList<GlusterBrickHarness>();
  }

  void attach( GlusterBrickHarness brickHarness ) {
    if ( glusterNode.attach( brickHarness.brick ) ) {
      brickHarnesses.add( brickHarness );
      brickHarness.setNodeContainer( this );
    }
  }

  float calculateHue() {
    return (100.0-(100.0-glusterNode.node.idle));
  }
  float calculateBrightness() {
    return(100.0 - glusterNode.node.iowait);
  }
  float calculateSaturation() {
    return 100;
  }
  boolean hasActivity() {
    return false;
  }


  void draw3D() {
    fill(calculateHue(), calculateBrightness(), calculateSaturation());
    sphere(radius);

/*
    if ( activeBricks > 0 ) {
      PVector p = pvector;
      pushStyle();
      pushMatrix();
        stroke(0,0,100);
        strokeWeight(1.5);
        float len = radius*8;

        PVector p2 = p.copy();
        p2.normalize();
        p2.mult(len);
        line( 0, 0, 0, p2.x, p2.y, p2.z );

        for ( int i = 0; i < 3; i++ ) {
          p2.normalize();
          p2.mult(70*(i+1));
          pushMatrix();
            translate(p2.x, p2.y, p2.z);
            sphere(5);
          popMatrix();
        }
      popMatrix();
      popStyle();

      activeBricks = 0;
    }
*/
  }
}

