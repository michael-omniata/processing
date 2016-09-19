  //Main part of the program, contains all global variables and setup() and draw()

  import java.util.Iterator;
  import controlP5.*;
  ControlP5 cp5;

  import websockets.*;
  WebsocketClient gluster_wsc;
  WebsocketClient relay_wsc;

  import dawesometoolkit.*;
  import org.multiply.processing.TimedEventGenerator;

  import shapes3d.utils.*;
  import shapes3d.animation.*;
  import shapes3d.*;

  import queasycam.*;

  import java.util.*;
  import java.text.*;
  boolean recording = false;

  String configSource;
  String gluster_configSource;
  String gluster_dataSource;
  String relay_configSource;
  String relay_dataSource;

  PrintWriter configFile;
  PrintWriter dataFile;

  void startRecording() {
    DateFormat formatter = new SimpleDateFormat("yyyy-MM-dd:HH_mm_ss");
    Date d = new Date();
    String dateString = formatter.format(d);
    String configFilename = dateString+"-config.json";
    String dataFilename   = dateString+"-data.json";


    configFile = createWriter(configFilename); 
    String[] configText = loadStrings( configSource );
    saveStrings( configFilename, configText );

    dataFile   = createWriter(dataFilename); 
    recording = true;
  }

  void stopRecording() {

    if ( recording ) {
    dataFile.flush();
    dataFile.close();
    recording = false;
  }
}

CrazyCam cam;

int mode = 3; // 2=2D, 3=3D
boolean clicked = false;

ArrayList<Harness> globalHarnesses = new ArrayList<Harness>();

GlusterHarness  glusterHarness;
RelayHarness    relayHarness_node001;
RelayHarness    relayHarness_node004;
KTServerHarness ktserverHarness;
TimedEventGenerator tickerSecondTimedEventGenerator;
PApplet app = this;
Shape3D selectedShape;

boolean freezeEverything = false;
boolean isClickable = false;
boolean replay = false;
String replayConfigFile = "replay-config.json";
String replayDataFile   = "replay-data.json";
String[] replayData;
int    replayIndex = 0;
int    replayTimestamp = 0;

void setup() {
  //  if ( mode == 2 ) {
  //    size(1024, 1024);
  //  } else {
  size(1400, 1024, OPENGL);
  smooth();
  //  }
  cam = new CrazyCam(this);
  //float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  //perspective(PI/3.0, width/height, cameraZ/10.0, cameraZ*50.0);
  perspective(1.047198F, (float)width / (float)height, 0.01F, 1000F*5);

  cp5 = new ControlP5(this);
  colorMode(HSB, 300, 100, 100, 255);

  if ( replay ) {
    configSource = replayConfigFile;
    glusterHarness = new GlusterHarness( this, configSource, width/2, height/2, 0 );
    replayData = loadStrings(replayDataFile);
    println( "Replaying "+replayData.length+" events" );
  } else {
    //configSource = "gluster.json";
    gluster_configSource = "http://ec2-54-158-33-191.compute-1.amazonaws.com:3001/gluster";
    gluster_dataSource = "ws://ec2-54-158-33-191.compute-1.amazonaws.com:3001/telemetry";
    glusterHarness = new GlusterHarness( this, gluster_configSource, width/2, height/2, 0 );
    gluster_wsc = new WebsocketClient(this, gluster_dataSource );
    gluster_wsc.sendMessage("{\"action\":\"subscribe\",\"channel\":\"gluster\"}");
    //===================================

    //configSource = "relay.json";
    relay_configSource = "http://ec2-54-158-33-191.compute-1.amazonaws.com:3001/relay";
    relay_dataSource = "ws://ec2-54-158-33-191.compute-1.amazonaws.com:3001/telemetry";
    relayHarness_node001 = new RelayHarness( this, relay_configSource, 400, 0, 0, "ev-relay-A-node001" );
    relayHarness_node004 = new RelayHarness( this, relay_configSource, width - 400, 0, 0, "ev-relay-A-node004" );
    relay_wsc = new WebsocketClient(this, relay_dataSource );
    relay_wsc.sendMessage("{\"action\":\"subscribe\",\"channel\":\"relay\"}");
    
    //relayHarness = new RelayHarness( this, configSource, width/2, height/2, 0 );
    //relayHarness = new RelayHarness( this, configSource, width/2 + 150, height/2, 0 );
    //relayHarness_1 = new RelayHarness( this, configSource, width/2 - 150, height/2, 0 );
    //glusterHarness = new GlusterHarness( this, configSource );
  }

  if ( mode == 2 ) {
    background(0);
    ellipseMode(CORNER);
    rectMode(CORNER);
    frameRate(20);
  } else if ( mode == 3 ) {
    frameRate(30);
    setup3D();
  }

  tickerSecondTimedEventGenerator = new TimedEventGenerator(this);
  tickerSecondTimedEventGenerator.setIntervalMs(1000);

}

void replayEvents() {
  JSONObject json;

  if ( replayIndex > replayData.length ) {
    return;
  }

  json = parseJSONObject(replayData[replayIndex]);
  if ( replayTimestamp == 0 ) {
    replayIndex = 0;
    json = parseJSONObject(replayData[replayIndex]);
    replayTimestamp = json.getInt("time");
  }
  int thisTimestamp;
  json = parseJSONObject(replayData[replayIndex]);
  while( (thisTimestamp = json.getInt("time")) == replayTimestamp ) {
    updateFromJSON( json );
    replayIndex++;
    json = parseJSONObject(replayData[replayIndex]);
  }
  replayTimestamp = thisTimestamp;
}

void draw() {
  if ( mode == 2 ) {
    draw2D();
  } else if ( mode == 3 ) {
    draw3D();
  }
}

void mouseClicked() {
  clicked = true;
  println("eye [center]: "+cam.center.x+","+cam.center.y+","+cam.center.z );
}

public void keyPressed() {
  if ( key == ' ' ) {
    freezeEverything = !freezeEverything;
/*
    if ( isClickable ) {
      isClickable = false;
      freezeEverything = false;
    } else {
      isClickable = true;
      freezeEverything = true;
    }
  } else if ( key == 'r' ) {
    if ( recording ) {
      stopRecording();
    } else {
      startRecording();
    }
*/
  }
}

Harness selectedHarness;
float selectedHarnessDistance = 1000000;

void setup3D() {
  smooth();
  cp5.setAutoDraw(false);
}

Harness focalObject = null;

void draw3D() {
  pointLight(0, 0, 100, 0, 0, 0 );
  ambientLight(0, 0, 60);

  if ( recording ) {
    background(255);
  } else {
    background(0);
  }

  if ( glusterHarness != null ) {
    glusterHarness.draw3D();
  }
  if ( relayHarness_node001 != null ) {
    relayHarness_node001.draw3D();
  }
  if ( relayHarness_node004 != null ) {
    relayHarness_node004.draw3D();
  }

  if ( cam.center != null ) {
    PVector closest = new PVector();
    float distance = 10000000.0;
    float screenX = 0, screenY = 0;
    PVector np = new PVector();
    ArrayList<Harness>harnesses = new ArrayList<Harness>();

    for (Harness h : globalHarnesses ) {
      h.isInside = false;
      h.isLookedAt = false;
      if ( (h.screenX >= (0+width/4) && h.screenX <= (width - width/4)) && (h.screenY >= (0+height/4) && h.screenY <= (height - height/4)) ) {
        PVector p = h.pvector;
        if ( p != null ) {
          np.set( h.modelX, h.modelY, h.modelZ );
          float thisdistance = np.dist( cam.center );
          if ( thisdistance < distance ) {
            distance = thisdistance;
            focalObject = h;
            closest = np.copy();
            screenX = h.screenX;
            screenY = h.screenY;
          }
        }
      }
    }
    if ( distance < 500 ) {
      float radius = focalObject.calculateRadius();
      focalObject.isLookedAt = true;
      if ( distance < radius ) {
        focalObject.isInside = true;
      }
      pushStyle();
        stroke(100,100,100);
        line(cam.center.x,cam.center.y,cam.center.z,closest.x,closest.y,closest.z);
//        println("eye ["+distance+" "+inside+"] ("+radius+") ("+screenX+","+screenY+"): "+cam.center.x+","+cam.center.y+","+cam.center.z+" to "+closest.x+","+closest.y+","+closest.z );
//        println( PVector.angleBetween(cam.center, closest) );
      popStyle();
      cam.beginHUD();
      focalObject.drawLabel();
      if ( focalObject.isInside ) {
        focalObject.drawHUD();
      }
      cam.endHUD();
    }
  }

  gui();
}



void draw2D() {
  //glusterHarness.draw2D();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  lights(); // otherwise cp5 controllers are dark
  cam.beginHUD();
  cp5.draw();
  cam.endHUD();
  hint(ENABLE_DEPTH_TEST);
}

void webSocketEvent(String msg) {
  JSONObject json = parseJSONObject(msg);

  updateFromJSON( json );
  if ( recording ) {
    dataFile.println( msg );
  }
}

void updateFromJSON( JSONObject json ) {
  if (json == null) {
    println("JSONObject could not be parsed");
  } else {
    String type = json.getString("type");
    if ( type.equals("mpstat") ) {
      // {"time":1471950021,"payload":{"system":"9.68","cpu":"4","user":"6.45","idle":"67.74","iowait":"15.05","nice":"0.00"},"type":"mpstat","host":"ev-relay-A-node001"}
      JSONObject mpstat = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String cpu = mpstat.getString( "cpu" );
      CpuHarness ch = CpuHarness_findOrCreate( nodeName, cpu );
      ch.cpu.system = mpstat.getFloat("system");
      ch.cpu.user   = mpstat.getFloat("user");
      ch.cpu.idle   = mpstat.getFloat("idle");
      ch.cpu.iowait = mpstat.getFloat("iowait");
      ch.cpu.nice   = mpstat.getFloat("nice");
    } else if ( type.equals("cpustat") ) {
      JSONObject cpustat = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );

      NodeHarness n = NodeHarness_findOrCreate( nodeName );
      n.node.updatedMillis = millis();
      n.node.idle = cpustat.getFloat( "idle" );
      n.node.system = cpustat.getFloat( "system" );
      n.node.user = cpustat.getFloat( "user" );
      n.node.nice = cpustat.getFloat( "nice" );
      n.node.iowait = cpustat.getFloat( "iowait" );
      n.node.steal = cpustat.getFloat( "steal" );
    } else if ( type.equals("iostat") ) {
      JSONObject iostat = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String deviceName = iostat.getString( "device" );

      DiskHarness d = DiskHarness_findOrCreate( nodeName, deviceName );
      d.disk.updatedMillis = millis();
      d.disk.rkB = iostat.getFloat( "rkB" );
      d.disk.wkB = iostat.getFloat( "wkB" );
      d.disk.reads = iostat.getFloat( "reads" );
      d.disk.writes = iostat.getFloat( "writes" );
      d.disk.await = iostat.getFloat( "await" );
      d.disk.r_await = iostat.getFloat( "r_await" );
      d.disk.w_await = iostat.getFloat( "w_await" );
      d.disk.avgqu_sz = iostat.getFloat( "avgqu_sz" );
      d.disk.util = iostat.getFloat( "util" );
    } else if ( type.equals("df") ) {
      JSONObject df = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String deviceName = df.getString( "device" );

      DiskHarness d = DiskHarness_findOrCreate( nodeName, deviceName );
      d.disk.use = df.getInt("use");
      d.disk.used = df.getFloat("used");
      d.disk.capacity = df.getFloat("capacity" );
      d.disk.avail = df.getFloat("avail");
      d.disk.mountpoint = df.getString("mountpoint");
    } else if ( type.equals("evRTProc-stat") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      RTProcHarness r = RTProcHarness_findOrCreate( nodeName, shard );
      r.rtProc.updatedMillis = millis();

      r.rtProc.clients          = payload.getInt( "clients" );
      r.rtProc.events           = payload.getInt( "events" );
      r.rtProc.invalid_keys     = payload.getInt( "invalid_keys" );
      r.rtProc.eps              = payload.getInt( "eps" );
      r.rtProc.user_state_qps   = payload.getInt( "user_state_qps" );
      r.rtProc.user_var_qps     = payload.getInt( "user_var_qps" );
      r.rtProc.beta_reads       = payload.getInt( "beta_reads" );
      r.rtProc.gamma_reads      = payload.getInt( "gamma_reads" );
      r.rtProc.gamma_misses     = payload.getInt( "gamma_misses" );
      r.rtProc.gamma_collisions = payload.getInt( "gamma_collisions" );
      r.rtProc.jitter           = payload.getFloat( "jitter" );

      r.startRxIndicator();
      r.startUsTxIndicator();
      r.startUvTxIndicator();

    } else if ( type.equals("evRTProc-bgsave-start") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      String db = payload.getString( "db" );
      RTProcHarness r = RTProcHarness_findOrCreate( nodeName, shard );

      if ( db.equals( "user-states" ) ) {
        r.rtProc.bgSave_user_state_inProgress = true;
        r.rtProc.bgSave_user_state_records    = payload.getInt( "records" );
        r.rtProc.bgSave_user_state_referenced = payload.getInt( "referenced" );
        r.rtProc.bgSave_user_state_poolsize   = payload.getInt( "poolsize" );
      } else if ( db.equals( "user-attributes" ) ) {
        r.rtProc.bgSave_user_vars_inProgress = true;
        r.rtProc.bgSave_user_vars_records    = payload.getInt( "records" );
        r.rtProc.bgSave_user_vars_referenced = payload.getInt( "referenced" );
        r.rtProc.bgSave_user_vars_poolsize   = payload.getInt( "poolsize" );
      }
    } else if ( type.equals("evRTProc-bgsave-complete") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      String db = payload.getString( "db" );
      RTProcHarness r = RTProcHarness_findOrCreate( nodeName, shard );

      if ( db.equals( "user-states" ) ) {
        r.rtProc.bgSave_user_state_inProgress = false;
        r.rtProc.bgSave_user_state_duration = payload.getFloat( "duration" );
        r.rtProc.bgSave_user_state_status   = payload.getInt( "status" );
      } else if ( db.equals( "user-attributes" ) ) {
        r.rtProc.bgSave_user_vars_inProgress = false;
        r.rtProc.bgSave_user_vars_duration = payload.getFloat( "duration" );
        r.rtProc.bgSave_user_vars_status   = payload.getInt( "status" );
      }
    } else if ( type.equals("evRTProc-checkpoint") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      RTProcHarness r = RTProcHarness_findOrCreate( nodeName, shard );

      r.rtProc.checkpoint_timestamp = payload.getString( "timestamp" );
      r.rtProc.checkpoint_event_index = payload.getInt( "event_index" );
    } else if ( type.equals("evRTProc-sync-start") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      RTProcHarness r = RTProcHarness_findOrCreate( nodeName, shard );

      r.rtProc.sync_inProgress = true;
    } else if ( type.equals("evRTProc-sync-complete") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      RTProcHarness r = RTProcHarness_findOrCreate( nodeName, shard );

      r.rtProc.sync_inProgress = false;
    } else if ( type.equals("evRTProc-flush") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      String db = payload.getString( "db" );
      RTProcHarness r = RTProcHarness_findOrCreate( nodeName, shard );

      if ( db.equals( "user-state" ) ) {
        r.rtProc.flushed_records_user_state = payload.getInt( "records" );
      } else if ( db.equals( "user-attributes" ) ) {
        r.rtProc.flushed_records_user_attributes = payload.getInt( "records" );
      }
    } else if ( type.equals("evRelay-pidstat-cpu") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      String task = payload.getString( "task" );
      Process p = null;
      if ( task.equals("evRTProc") ) {
        RTProcHarness h = RTProcHarness_findOrCreate( nodeName, shard );
        p = (Process)h.rtProc;
      } else if ( task.equals("ktserver") ) {
        KTServerHarness h = KTServerHarness_findOrCreate( nodeName, shard );
        p = (Process)h.ktserver;
      }
      if ( p != null ) {
        p.num_fds = payload.getInt("num_fds");
        p.cpuTotal = payload.getFloat("cpuTotal");
        p.cpu      = payload.getInt("cpu");
        p.usr      = payload.getFloat("usr");
        p.system   = payload.getFloat("system");
        p.pid      = payload.getInt("pid");
      }
    } else if ( type.equals("evRelay-pidstat-io") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      String task = payload.getString( "task" );
      Process p = null;
      if ( task.equals("evRTProc") ) {
        RTProcHarness h = RTProcHarness_findOrCreate( nodeName, shard );
        p = (Process)h.rtProc;
      } else if ( task.equals("ktserver") ) {
        KTServerHarness h = KTServerHarness_findOrCreate( nodeName, shard );
        p = (Process)h.ktserver;
      }
      if ( p != null ) {
        p.kb_rds = payload.getFloat("kb_rds");
        p.kb_wrs = payload.getFloat("kb_wrs");
        p.kb_ccwr = payload.getFloat("kb_ccwr");
      }
    } else if ( type.equals( "evRelay-ktreport" ) ) {
      // In this case, one message updates all 32 shards
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );

      // Each value is an array of 32 values
      JSONArray cnt_get_array         = payload.getJSONArray("cnt_get");
      JSONArray cnt_set_array         = payload.getJSONArray("cnt_set");
      JSONArray cnt_get_misses_array  = payload.getJSONArray("cnt_get_misses");
      JSONArray cnt_set_misses_array  = payload.getJSONArray("cnt_set_misses");
      JSONArray db_total_count_array  = payload.getJSONArray("db_total_count");
      JSONArray db_total_size_array   = payload.getJSONArray("db_total_size");
      JSONArray serv_conn_count_array = payload.getJSONArray("serv_conn_count");
      JSONArray db_0_count_array      = payload.getJSONArray("db_0_count");
      JSONArray db_0_size_array       = payload.getJSONArray("db_0_size");
      JSONArray db_1_count_array      = payload.getJSONArray("db_1_count");
      JSONArray db_1_size_array       = payload.getJSONArray("db_1_size");

      for ( int highway = 0; highway < 4; highway++ ) {
        for ( int lane = 0; lane < 8; lane++ ) {
          int ordinal = (highway << 3) + lane;
          String shard = highway+"-"+lane;
          KTServerHarness h = KTServerHarness_findOrCreate( nodeName, shard );
          h.ktserver.update(
            cnt_get_array.getFloat(ordinal),
            cnt_set_array.getFloat(ordinal),
            cnt_get_misses_array.getFloat(ordinal),
            cnt_set_misses_array.getFloat(ordinal),
            db_total_count_array.getFloat(ordinal),
            db_total_size_array.getFloat(ordinal),
            serv_conn_count_array.getInt(ordinal),
            db_0_count_array.getFloat(ordinal),
            db_0_size_array.getFloat(ordinal),
            db_1_count_array.getFloat(ordinal),
            db_1_size_array.getFloat(ordinal)
          );
        }
      }
    } else {
      println( "I don't know about "+type );
    }
  }
}

int lastMillis = 0;
void onTimerEvent() {
  int curMillis = millis();
  int millisDiff = curMillis - lastMillis;
  lastMillis = millisDiff + lastMillis;

  tickerSecond( lastMillis, curMillis );
}

void tickerSecond( int lastMillis, int curMillis ) {

  if ( replay ) {
    replayEvents();
  }

  resetIdleDiskStats( lastMillis, curMillis );
  //resetIdleRelayStats( lastMillis, curMillis );
  if ( glusterHarness != null ) {
    glusterHarness.tickerSecond( lastMillis, curMillis );
  }
  if ( relayHarness_node001 != null ) {
    relayHarness_node001.tickerSecond( lastMillis, curMillis );
  }
  if ( relayHarness_node004 != null ) {
    relayHarness_node004.tickerSecond( lastMillis, curMillis );
  }
}

void resetIdleDiskStats( int lastMillis, int curMillis ) {
  Iterator i = disks.entrySet().iterator();  // Get an iterator

  while ( i.hasNext() ) {
    HashMap.Entry me = (HashMap.Entry)i.next();
    Disk d = (Disk)me.getValue();
    int deltaUpdate = curMillis - d.updatedMillis;
    // If we have no data from the disk for a while, reset the stats, since it
    // seems to be idle now.
    if ( deltaUpdate > 2000 ) {
      d.reads  = 0;
      d.writes = 0;
      d.util   = 0;
      d.updatedMillis = curMillis;
    }
  }
}

void resetIdleRelayStats( int lastMillis, int curMillis ) {
  Iterator i = rtprocs.entrySet().iterator();  // Get an iterator

  while ( i.hasNext() ) {
    HashMap.Entry me = (HashMap.Entry)i.next();
    RTProc p = (RTProc)me.getValue();
    int deltaUpdate = curMillis - p.updatedMillis;
    // If we have no data for a while, reset the stats
    if ( (deltaUpdate/1000.0) > 340 ) {
      p.clients = 0;
      p.events = 0;
      p.invalid_keys = 0;
      p.eps = 0;
      p.user_state_qps = 0;
      p.user_var_qps = 0;
      p.beta_reads = 0;
      p.gamma_reads = 0;
      p.gamma_misses = 0;
      p.gamma_collisions = 0;
      p.jitter = 0;
    }
  }
}

PVector rayTrace(float x0, float y0, float z0, float x1, float y1, float z1, float radius) {
 PVector p = new PVector();
 float discriminant, t, lineX, lineY, lineZ;
 float dx = x1 - x0, dy = y1 - y0, dz = z1 - z0;
 float a = dx*dx + dy*dy + dz*dz;
 float b = 2*dx*(x0-x1) + 2*dy*(y0-y1) + 2*dz*(z0-z1);
 float c = x1*x1 + y1*y1 + z1*z1 + x0*x0 + y0*y0 + z0*z0 - 2*(x1*x0 + y1*y0 + z1*z0) - radius*radius;
 discriminant = b*b - 4*a*c;
 t = ( -b - sqrt(discriminant) ) / (2*a);
 lineX = x0 + t*dx;
 lineY = y0 + t*dy;
 lineZ = z0 + t*dz;
 line(x0, y0, z0, lineX, lineY, lineZ);
 p.x = lineX;
 p.y = lineY;
 p.z = lineZ;
 return p;

}
