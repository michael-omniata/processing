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

  int total_clients;
  int total_events;
  int total_events_delta;
  int total_eps;
  int total_user_var_qps;
  int total_user_state_qps;
  int total_beta_reads;
  int total_gamma_reads;
  int total_gamma_misses;
  int total_gamma_collisions;

  RelayNode( String _nodeName ) {
    node = Node_findOrCreate( _nodeName );
    nodeName = _nodeName;
    rtProcs = new HashMap();
  }
}
