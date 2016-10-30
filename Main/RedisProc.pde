HashMap redisProcs = new HashMap();
RedisProc RedisProc_findOrCreate( String nodeName, String ID ) {
  String redisProcID = nodeName+':'+ID;
  RedisProc r = (RedisProc)redisProcs.get( redisProcID );
  if ( r == null ) {
    r = new RedisProc( nodeName, redisProcID );
    redisProcs.put( redisProcID, r );
  }
  return r;
}


class RedisProc extends Process {
  String ID;
  boolean present;

  // updated with RedisProc-config:
  public int max_clients;

  // updated with RedisProc-stat:
  public int clients;
  public int cps; // commands per second

  RedisNode redisNode;

  public int updatedMillis;

  RedisProc( String _nodeName, String _ID ) {
    redisNode = RedisNode_findOrCreate( _nodeName );
    ID = _ID;
    updatedMillis = 0;
  }
}

