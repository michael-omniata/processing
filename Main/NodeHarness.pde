//The NodeHarness class contains the GUI for the node

class NodeHarness extends HarnessRect {
  Node node;
  int slots;
  Textfield nodeName;
  Toggle filter;
  ArrayList<BrickHarness> brickHarnesses;
  NodeHarness( String name, int x, int y, int w, int h ) {
    super( x, y, w, h );
    node = new Node( name );
    brickHarnesses = new ArrayList<BrickHarness>();
    filter = cp5.addToggle(this, "filter")
      .setSize(100, 20)
      .setCaptionLabel("Filter")
      ;
    nodeName = cp5.addTextfield(this, "" )
      .setSize(100, 20)
      .setValue( name )
      .lock()
      ;
    addController( nodeName, 0, -15 );
    addController( filter, 0, -30 );
  }

  Node getNode() {
    return node;
  }
  void update() {
    super.update();
    super.setColor(color(0, 0, 255));
    super.draw();
  }
  void attach( BrickHarness brickHarness, String deviceName ) {
    if ( node.mount( brickHarness.brick, deviceName ) ) {
      brickHarnesses.add( brickHarness );
      brickHarness.setNodeContainer( this );
    }
  }
}

NodeHarness findNodeHarness( String nodeName ) {
  println( "Looking for "+nodeName );
  for (NodeHarness harness : nodeHarnesses) {
    if ( harness.getNode().getName().equals(nodeName) ) {
      println( "Found "+nodeName );
      return harness;
    }
  }
  return null;
}