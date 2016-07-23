//The NodeHarness class contains the GUI for the node

class NodeHarness extends Harness {
  Node node;
  ArrayList<BrickHarness> brickHarnesses;
  NodeHarness( String name, int x, int y, int l, int h ) {
    super( x, y, l, h );
    node = new Node( name );
    brickHarnesses = new ArrayList<BrickHarness>();
  }

  Node getNode() {
    return node;
  }
  void update() {
    super.update();
    super.setColor(color(0, 0, 255));
    strokeWeight(3); //For some reason this is changing the brick harnesses's strokes and strokeWeights as well
    stroke(255);
    beginShape(QUAD_STRIP);
    vertex(xPos, yPos);
    vertex((xPos+len), yPos);
    vertex(xPos, (yPos+hgt));
    vertex((xPos+len), (yPos+hgt));
    vertex(xPos, (yPos+2*hgt));
    vertex((xPos+len), (yPos+2*hgt));
    vertex(xPos, (yPos+3*hgt));
    vertex((xPos+len), (yPos+3*hgt));
    vertex(xPos, (yPos+4*hgt));
    vertex((xPos+len), (yPos+4*hgt));
    vertex(xPos, (yPos+5*hgt));
    vertex((xPos+len), yPos+5*hgt);
    vertex(xPos, (yPos+6*hgt));
    vertex((xPos+len), (yPos+6*hgt));
    vertex(xPos, (yPos+7*hgt));
    vertex((xPos+len), (yPos+7*hgt));
    vertex(xPos, (yPos+8*hgt));
    vertex((xPos+len), (yPos+8*hgt));
    endShape();
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