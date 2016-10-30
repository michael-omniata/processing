HashMap relayStream = new HashMap();
RelayStream RelayStream_findOrCreate( String nodeName, String ID ) {
  String relayStreamID = nodeName+':'+ID;
  RelayStream r = (RelayStream)relayStream.get( relayStreamID );
  if ( r == null ) {
    r = new RelayStream( nodeName, relayStreamID );
    relayStream.put( relayStreamID, r );
  }
  return r;
}


class RelayStream extends Process {
  String ID;
  boolean present;

  // updated with ev-RelayStream-stat:
  public int clients;
  public int eps;

  RelayNode relayNode;

  public int updatedMillis;

  RelayStream( String _nodeName, String _ID ) {
    relayNode = RelayNode_findOrCreate( _nodeName );
    ID = _ID;
    eps = 0;
    clients = 0;
    updatedMillis = 0;
  }
}

