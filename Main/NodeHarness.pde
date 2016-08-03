//The NodeHarness class contains the GUI for the node

class NodeHarness extends HarnessRect {
  Node node;
  int slots;
  Textfield nodeName;
  public Toggle filter;
  GlusterHarness glusterHarness;
  ArrayList<BrickHarness> brickHarnesses;
  NodeHarness( GlusterHarness _gh, String name, int x, int y, int w, int h ) {
    super( x, y, w, h );
    glusterHarness = _gh;
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

