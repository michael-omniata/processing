//The NodeHarness class contains the GUI for the node

class NodeHarness extends Harness {
  Node node;
  ArrayList<BrickHarness> brickHarnesses;
  NodeHarness( String name, int x, int y, int size ) {
    super( x, y, size );
    node = new Node( name );
    brickHarnesses = new ArrayList<BrickHarness>();
  }

  Node getNode() {
    return node;
  }
  void update() {
    super.update();
    super.setColor(color(0, 0, 255));
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