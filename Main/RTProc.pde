HashMap rtprocs = new HashMap();
RTProc RTProc_findOrCreate( String nodeName, String ID ) {
  String rtProcID = nodeName+':'+ID;
  RTProc r = (RTProc)rtprocs.get( rtProcID );
  if ( r == null ) {
    r = new RTProc( nodeName, rtProcID );
    rtprocs.put( rtProcID, r );
  }
  return r;
}


class RTProc extends Process {
  String ID;
  boolean present;
  public float cpuUsage;
  public float ramUsage;
  public String state;

  // updated with evRTProc-sync-start and evRTProc-sync-complete:
  public boolean sync_inProgress;

  // updated with evRTProc-bgsave-start and evRTProc-bgsave-complete:
  public boolean bgSave_user_state_inProgress;
  public int bgSave_user_state_records;
  public int bgSave_user_state_referenced;
  public int bgSave_user_state_poolsize;
  public float bgSave_user_state_duration;
  public int bgSave_user_state_status;
  public boolean bgSave_user_vars_inProgress;
  public int bgSave_user_vars_records;
  public int bgSave_user_vars_referenced;
  public int bgSave_user_vars_poolsize;
  public float bgSave_user_vars_duration;
  public int bgSave_user_vars_status;

  // updated with evRTProc-stat:
  public int clients;
  public int events;
  public int invalid_keys;
  public int eps;
  public int user_state_qps;
  public int user_var_qps;
  public int beta_reads;
  public int gamma_reads;
  public int gamma_misses;
  public int gamma_collisions;
  public float jitter;

  // updated with evRTProc-checkpoint:
  public String checkpoint_timestamp;
  public int checkpoint_event_index;

  // updated with evRTProc-flush:
  public int flushed_records_user_state;
  public int flushed_records_user_attributes;
  RelayNode relayNode;

  public int updatedMillis;

  RTProc( String _nodeName, String _ID ) {
    relayNode = RelayNode_findOrCreate( _nodeName );
    ID = _ID;
    events = 0;
    cpuUsage = 0;
    ramUsage = 0;
    state = "unknown";
    updatedMillis = 0;
  }
}

