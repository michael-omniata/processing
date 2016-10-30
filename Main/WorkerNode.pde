HashMap workerNodes = new HashMap();

WorkerNode WorkerNode_findOrCreate( String nodeName ) {
  WorkerNode n = (WorkerNode)workerNodes.get( nodeName );
  if ( n == null ) {
    n = new WorkerNode( nodeName );
    workerNodes.put( nodeName, n );
  }
  return n;
}

class WorkerNode {
  public String nodeName;
  public HashMap evProcs;
  public Node    node;

  WorkerNode( String _nodeName ) {
    node = Node_findOrCreate( _nodeName );
    nodeName = _nodeName;
    evProcs = new HashMap();
  }
}
