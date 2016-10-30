HashMap relaySubStream = new HashMap();
RelaySubStream RelaySubStream_findOrCreate( String nodeName, String ID ) {
  String relaySubStreamID = nodeName+':'+ID;
  RelaySubStream r = (RelaySubStream)relaySubStream.get( relaySubStreamID );
  if ( r == null ) {
    r = new RelaySubStream( nodeName, relaySubStreamID );
    relaySubStream.put( relaySubStreamID, r );
  }
  return r;
}


class RelaySubStream extends Process {
  String ID;
  boolean present;

  // updated with ev-RelaySubStream-stat:
  public int clients;
  public int eps;

  RelayNode relayNode;

  public int updatedMillis;

  RelaySubStream( String _nodeName, String _ID ) {
    relayNode = RelayNode_findOrCreate( _nodeName );
    ID = _ID;
    eps = 0;
    clients = 0;
    updatedMillis = 0;
  }
}

