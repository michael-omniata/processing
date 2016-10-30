HashMap redisNodes = new HashMap();

RedisNode RedisNode_findOrCreate( String nodeName ) {
  RedisNode n = (RedisNode)redisNodes.get( nodeName );
  if ( n == null ) {
    n = new RedisNode( nodeName );
    redisNodes.put( nodeName, n );
  }
  return n;
}

class RedisNode {
  public String nodeName;
  public HashMap redisProcs;
  public Node    node;

  RedisNode( String _nodeName ) {
    node = Node_findOrCreate( _nodeName );
    nodeName = _nodeName;
    redisProcs = new HashMap();
  }
}
