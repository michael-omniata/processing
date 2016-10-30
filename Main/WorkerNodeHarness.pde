//The WorkerNodeHarness class contains the GUI for the node
HashMap workerNodeHarnesses = new HashMap();

WorkerNodeHarness WorkerNodeHarness_findOrCreate( String nodeName ) {
  WorkerNodeHarness n = (WorkerNodeHarness)workerNodeHarnesses.get( nodeName );
  if ( n == null ) {
    n = new WorkerNodeHarness( nodeName );
    workerNodeHarnesses.put( nodeName, n );
  }
  return n;
}

class WorkerNodeHarness extends Harness {
  WorkerNode workerNode;
  NodeHarness nodeHarness;
  
  WorkerNodeHarness( String nodeName ) {
    workerNode = WorkerNode_findOrCreate( nodeName );
    nodeHarness = NodeHarness_findOrCreate( nodeName );
  }
}

