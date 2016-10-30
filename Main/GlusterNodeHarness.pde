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
    fill(calculateHue(), calculateSaturation(), calculateBrightness());
    sphere(radius);
  }
}

