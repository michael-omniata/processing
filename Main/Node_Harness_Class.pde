//The NodeHarness class contains the GUI for the node

int BRICK_COLUMNS = 6;
int COLUMN_WIDTH = 100;
int COLUMN_HEIGHT = 100;
int COLUMN_DIVIDER = 5;
int ROW_DIVIDER = 10;
int NODE_SPACER = 30;

class NodeHarness extends HarnessRect {
  Node node;
  int slots;
  Textfield nodeName;
  ArrayList<BrickHarness> brickHarnesses;
  NodeHarness( String name, int x, int y, int w, int h ) {
    super( x, y, w, h );
    node = new Node( name );
    brickHarnesses = new ArrayList<BrickHarness>();
    nodeName = cp5.addTextfield(this, "" )
      .setSize(100, 20)
      .setValue( name )
      .lock()
      ;
    addController( nodeName, 0, -15 );
  }

  Node getNode() {
    return node;
  }
  void update() {
    super.update();
    super.setColor(color(0, 0, 255));
    super.draw();
    for ( int i = 0; i < brickHarnesses.size(); i++ ) {
      BrickHarness b = brickHarnesses.get(i);
      int row = i / BRICK_COLUMNS;
      int col = i % BRICK_COLUMNS;

      float xPosNew = ( xPos + (COLUMN_WIDTH * col) + (COLUMN_DIVIDER * col) );
      float yPosNew = ( yPos + (COLUMN_HEIGHT-hgt) + hgt + NODE_SPACER + (COLUMN_HEIGHT * row) + (ROW_DIVIDER * row) );
      b.setPosition( xPosNew, yPosNew );
    }
    /*
    strokeWeight(3); //For some reason this is changing the brick harnesses's strokes and strokeWeights as well
     stroke(255);
     beginShape(QUAD_STRIP);
     for (int i = 0; i <= slots; i++ ) {
     vertex(xPos, yPos+i*(hgt/slots));
     vertex((xPos+len), (yPos+i*(hgt/slots)));
     }
     strokeWeight(1);
     endShape();
     */
  }
  void attach( BrickHarness brickHarness ) {
    if ( node.mount( brickHarness.brick ) ) {
      brickHarnesses.add( brickHarness );
      brickHarness.setNodeContainer( node );
    }
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