//The RedisNodeHarness class contains the GUI for the node
HashMap redisNodeHarnesses = new HashMap();

RedisNodeHarness RedisNodeHarness_findOrCreate( String nodeName ) {
  RedisNodeHarness n = (RedisNodeHarness)redisNodeHarnesses.get( nodeName );
  if ( n == null ) {
    n = new RedisNodeHarness( nodeName );
    redisNodeHarnesses.put( nodeName, n );
  }
  return n;
}

class RedisNodeHarness extends Harness {
  RedisNode redisNode;
  NodeHarness nodeHarness;
  
  RedisNodeHarness( String nodeName ) {
    redisNode = RedisNode_findOrCreate( nodeName );
    nodeHarness = NodeHarness_findOrCreate( nodeName );
  }
}

