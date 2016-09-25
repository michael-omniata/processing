//The node class has an array of bricks and their names and bricks can be "attached" to it
HashMap glusterNodes = new HashMap();

GlusterNode GlusterNode_findOrCreate( String nodeName ) {
  GlusterNode n = (GlusterNode)glusterNodes.get( nodeName );

  if ( n == null ) {
    n = new GlusterNode( nodeName );
    glusterNodes.put( nodeName, n );
  }
  return n;
}

class GlusterNode {
  ArrayList<GlusterBrick> bricks;
  Node    node;

  GlusterNode( String _nodeName ) {
    bricks = new ArrayList<GlusterBrick>();
    node = Node_findOrCreate( _nodeName );
  }

  boolean attach( GlusterBrick brick ) {
    bricks.add( brick );
    brick.setNodeContainer( this );
    return true;
  }
}
