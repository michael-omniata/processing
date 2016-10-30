HashMap procs = new HashMap();
Proc Proc_findOrCreate( String nodeName, String ID ) {
  String evProcID = nodeName+':'+ID;
  Proc r = (Proc)procs.get( evProcID );
  if ( r == null ) {
    r = new Proc( nodeName, evProcID );
    procs.put( evProcID, r );
  }
  return r;
}


class Proc extends Process {
  String ID;
  boolean present;
  public float cpuUsage;
  public float ramUsage;
  public String state;

  // updated with evProc-stat:
  public int clients;
  public int events;
  public int delta_events;
  public int invalid_keys;
  public int eps;
  public int real_eps;
  public int user_state_qps;
  public int user_var_qps;
  public int beta_reads;
  public int gamma_reads;
  public int gamma_misses;
  public int gamma_collisions;
  public float jitter;

  // updated with evProc-checkpoint:
  public String checkpoint_timestamp;
  public int checkpoint_event_index;

  // updated with evProc-flush:
  public int flushed_records_user_state;
  public int flushed_records_user_attributes;
  RelayNode relayNode;

  public int updatedMillis;
  public int event_counts_updated_at;

  Proc( String _nodeName, String _ID ) {
    relayNode = RelayNode_findOrCreate( _nodeName );
    ID = _ID;
  }
}

