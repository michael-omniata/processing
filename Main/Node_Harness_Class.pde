class NodeHarness {
  int xPos, yPos;
  int boxSize;
  Node node;
  ArrayList<BrickHarness> brickHarnesses;
  ControlP5 cp5;
  NodeHarness( processing.core.PApplet theParent, String name, int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
    cp5 = new ControlP5(theParent);
    node = new Node( name );
    brickHarnesses = new ArrayList<BrickHarness>();
  }
  Node getNode() {
    return node;
  }
  void update() {
    fill(0, 0, 255);
    rect(xPos, yPos, boxSize/2, boxSize/2);
  }
  void attach( BrickHarness brickHarness ) {
    brickHarnesses.add( brickHarness );
    brickHarness.setContainer( node );
  }
}

NodeHarness findNodeHarness( String nodeName ) {
  println( "Looking for "+nodeName );
  for (NodeHarness harness : nodeHarnesses) {
    if ( harness.getNode().getNodeName().equals(nodeName) ) {
      println( "Found "+nodeName );
      return harness;
    }
  }
  return null;
}