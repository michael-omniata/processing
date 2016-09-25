HashMap relayNodes = new HashMap();

RelayNode RelayNode_findOrCreate( String nodeName ) {
  RelayNode n = (RelayNode)relayNodes.get( nodeName );
  if ( n == null ) {
    n = new RelayNode( nodeName );
    relayNodes.put( nodeName, n );
  }
  return n;
}

class RelayNode {
  public String nodeName;
  public HashMap rtProcs;
  public Node    node;

  RelayNode( String _nodeName ) {
    node = Node_findOrCreate( _nodeName );
    nodeName = _nodeName;
    rtProcs = new HashMap();
  }
}
