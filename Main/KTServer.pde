//Kyoto Tycoon server class (KTServer) is a key value database

HashMap ktservers = new HashMap();
KTServer KTServer_findOrCreate( String nodeName, String ID ) {
  String ktServerID = nodeName+':'+ID;
  KTServer p = (KTServer)ktservers.get( ktServerID );
  if ( p == null ) {
    p = new KTServer( nodeName, ktServerID );
    ktservers.put( ktServerID, p );
  }
  return p;
}


class KTServer extends Process {
  String ID;
  boolean present;

  // updated with evKTServer-report:
  public float cnt_get;
  public float cnt_get_misses;
  public float cnt_set;
  public float cnt_set_misses;
  public float db_total_count;
  public float db_total_size;
  public int   serv_conn_count;
  public float db_0_count;
  public float db_0_size;
  public float db_1_count;
  public float db_1_size;

  public float cnt_get_rate;
  public float cnt_get_misses_rate;
  public float cnt_set_rate;
  public float cnt_set_misses_rate;
  RelayNode relayNode;

  public int kt_updatedMillis;

  KTServer( String _nodeName, String _ID ) {
    relayNode = RelayNode_findOrCreate( _nodeName );
    ID = _ID;
    kt_updatedMillis = 0;
  }

  void update(
    float _cnt_get,
    float _cnt_get_misses,
    float _cnt_set,
    float _cnt_set_misses,
    float _db_total_count,
    float _db_total_size,
    int   _serv_conn_count,
    float _db_0_count,
    float _db_0_size,
    float _db_1_count,
    float _db_1_size ) {

    int nowMillis = millis();

    if ( kt_updatedMillis > 0 ) {
      float cnt_get_delta  = _cnt_get - cnt_get;
      float cnt_set_delta  = _cnt_set - cnt_set;
      float cnt_get_misses_delta = _cnt_get_misses - cnt_get_misses;
      float cnt_set_misses_delta = _cnt_set_misses - cnt_set_misses;
      float delta_secs = (nowMillis - kt_updatedMillis) / 1000.0;

      cnt_get_rate = cnt_get_delta / delta_secs;
      cnt_set_rate = cnt_set_delta / delta_secs;
      cnt_get_misses_rate = cnt_get_misses_delta / delta_secs;
      cnt_set_misses_rate = cnt_set_misses_delta / delta_secs;
    }
    kt_updatedMillis = nowMillis;

    cnt_get         = _cnt_get;
    cnt_get_misses  = _cnt_get_misses;
    cnt_set         = _cnt_set;
    cnt_set_misses  = _cnt_set_misses;
    db_total_count  = _db_total_count;
    db_total_size   = _db_total_size;
    serv_conn_count = _serv_conn_count;
    db_0_count      = _db_0_count;
    db_0_size       = _db_0_size;
    db_1_count      = _db_1_count;
    db_1_size       = _db_1_size;
  }
}