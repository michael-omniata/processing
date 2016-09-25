//The RelayNodeHarness class contains the GUI for the node
HashMap relayNodeHarnesses = new HashMap();

RelayNodeHarness RelayNodeHarness_findOrCreate( String nodeName ) {
  RelayNodeHarness n = (RelayNodeHarness)relayNodeHarnesses.get( nodeName );
  if ( n == null ) {
    n = new RelayNodeHarness( nodeName );
    relayNodeHarnesses.put( nodeName, n );
  }
  return n;
}

class RelayNodeHarness extends Harness {
  RelayNode relayNode;
  NodeHarness nodeHarness;
  
  RelayNodeHarness( String nodeName ) {
    relayNode = RelayNode_findOrCreate( nodeName );
    nodeHarness = NodeHarness_findOrCreate( nodeName );
  }
}

