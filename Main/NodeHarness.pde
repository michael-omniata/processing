//The NodeHarness class contains the GUI for the node
HashMap nodeHarnesses = new HashMap();

NodeHarness NodeHarness_findOrCreate( String nodeName ) {
  NodeHarness n = (NodeHarness)nodeHarnesses.get( nodeName );
  if ( n == null ) {
    n = new NodeHarness( nodeName );
    nodeHarnesses.put( nodeName, n );
  }
  return n;
}

class NodeHarness extends Harness {
  Node node;
  ArrayList<CpuHarness>  cpuHarnesses;
  ArrayList<DiskHarness> diskHarnesses;
  float radius = 20;
  
  NodeHarness( String nodeName ) {
    node = Node_findOrCreate( nodeName );
    diskHarnesses = new ArrayList<DiskHarness>();
    cpuHarnesses  = new ArrayList<CpuHarness>();
  }

  void attach( DiskHarness diskHarness ) {
    diskHarnesses.add( diskHarness );
    diskHarness.setNodeContainer( this );
  }

  void attach( CpuHarness cpuHarness ) {
    cpuHarnesses.add( cpuHarness );
  }

  float calculateHue() {
    return (100.0-(100.0-node.idle));
  }
  float calculateBrightness() {
    return(100.0 - node.iowait);
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
  }
}

