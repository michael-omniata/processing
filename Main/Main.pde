//
// This program is used to perform real-time visualization of the Omniata data analytics
// engine. Currently, the major parts of the system that are visualized are:
//
//   The gluster filesystem, which is a distributed filesystem consisting of four
//   processing "nodes" and about 60 "bricks", each of which are 1TB. Gluster volumes
//   are abstract groups of "bricks", and can be created using bricks from multiple
//   nodes.
//
//   The event relays (two active and redundant), which receive events and process
//   them in real-time, keeping track of user state, which is persisted to disk. The
//   relays use KTservers (persistent key/value database) to periodically flush
//   cached state to disk. RelayStream and RelaySubStream processes allow the event
//   stream to be sampled, in whole or in part.
//
//   The redis servers (two, in a master/slave configuration).
//
// The source of data for the visualization comes from a telemetry server, which
// is used to allow publishers to disseminate telemetry to subscribers. The telemetry
// events are in JSON format, and are transmitted over a web socket.
//
//
// This is the class structure:
//
// Disk
// Cpu
// Node
// Process
//   KTServer
//   RTProc
//   Proc
//   RedisProc
//   RelayStream
//   RelaySubStream
// RedisNode
// RelayNode
// GlusterBrick [ GlusterNode, Disk ]
// GlusterVolume [ GlusterBrick[] ]
// GlusterNode [ GlusterBrick[] ]
// WorkerNode [ Node ]
// Harness [ HarnessController[] ]
//   CpuHarness [ NodeHarness, Cpu ]
//   DiskHarness [ NodeHarness, 
//   GlusterBrickHarness [ GlusterNode, GlusterBrick, GlusterVolume]
//   GlusterNodeHarness [ GlusterNode, GlusterBrick[] ] 
//   GlusterVolumeHarness [ GlusterVolume ]
//   HarnessGroup [ Harnesses[] ]
//     ProcHarnessGroup
//     RTProcHarnessGroup
//   NodeHarness [ CpuHarness[], DiskHarness[] ]
//   ProcessHarness [ NodeHarness, HarnessGroup, Process ]
//     ProcHarness [ NodeHarness, Proc ]
//     RTProcHarness [ NodeHarness, RelayHarness, RTProc ]
//     KTServerHarness [ NodeHarness, RelayHarness, KTServer ]
//     RedisProcHarness [ NodeHarness, RelayHarness, RedisProc ]
//     RelayStreamHarness [ NodeHarness, RelayHarness, RelayStream ]
//     RelaySubStreamHarness [ NodeHarness, RelayHarness, RelaySubStream ]
//   RedisNodeHarness [ NodeHarness, RedisNode ]
//   RelayNodeHarness [ NodeHaresss, RelayNode ] 
//   WorkerNodeHarness [ NodeHarness, WorkerNode ]
//   SystemHarness
//     RedisHarness [ RedisProcHarnessGroup, RedisProcHarness[] ]
//     WorkerHarness [ ProcHarnessGroup, ProcHarness[] ]
//
// Authors: Mischa and Michael Thompson
// Copyright (c) 2016, Omniata INC.
//
//

import java.util.Iterator;
import controlP5.*;
ControlP5 cp5;

import websockets.*;
WebsocketClient telemetry_wsc;

WebsocketClient gluster_wsc;
WebsocketClient relay_wsc;
WebsocketClient redis_wsc;
WebsocketClient capi_wsc;
WebsocketClient bank_wsc;

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
String redis_configSource;
String redis_dataSource;
String capi_configSource;
String capi_dataSource;
String bank_configSource;
String bank_dataSource;

PrintWriter configFile;
PrintWriter dataFile;

int telemetry_bytes_last_second = 0;
int telemetry_bytes_this_second = 0;
int telemetry_messages_last_second = 0;
int telemetry_messages_this_second = 0;

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

boolean spheresEnabled = true;
float shinyVal = 1.0;
boolean wireFrame = false;

ArrayList<Harness> globalHarnesses = new ArrayList<Harness>();

//CapiHarness     capiHarness;
//BankHarness     bankHarness;
GlusterHarness  glusterHarness;
RelayHarness    relayHarness_node001;
RelayHarness    relayHarness_node004;
RedisHarness    redisHarness_node01;
RedisHarness    redisHarness_node02;
KTServerHarness ktserverHarness;
TimedEventGenerator tickerSecondTimedEventGenerator;
PApplet app = this;
Shape3D selectedShape;

boolean glusterEnabled = true;
boolean relayEnabled   = true;
boolean redisEnabled   = true;
boolean bankEnabled    = false;
boolean capiEnabled    = false;

boolean freezeEverything = false;
boolean isClickable = false;
boolean replay = false;
String replayConfigFile = "replay-config.json";
String replayDataFile   = "replay-data.json";
String[] replayData;
int    replayIndex = 0;
int    replayTimestamp = 0;
PMatrix3D originalMatrix;

void setup() {
  //  if ( mode == 2 ) {
  //    size(1024, 1024);
  //  } else {

  JSONObject json = loadJSONObject("config.json");
  // Get the FQDN and port number of the telemetry endpoint
  String telemetryEndpoint = json.getString("telemetryEndpoint");

  size(1400, 1024, OPENGL);
  background(0);
  smooth();
  //  }
  cam = new CrazyCam(this);
  //float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  //perspective(PI/3.0, width/height, cameraZ/10.0, cameraZ*50.0);
  perspective(1.047198F, (float)width / (float)height, 0.01F, 1000F*5);

  cp5 = new ControlP5(this);
  colorMode(HSB, 300, 100, 100, 255);

  originalMatrix = app.getMatrix((PMatrix3D)null);
  if ( replay ) {
    configSource = replayConfigFile;
    glusterHarness = new GlusterHarness( this, configSource, width/2, height/2, 0 );
    replayData = loadStrings(replayDataFile);
    println( "Replaying "+replayData.length+" events" );
  } else {
    telemetry_wsc = new WebsocketClient(this, "ws://"+telemetryEndpoint+"/telemetry" );

    //configSource = "gluster.json";
    if ( glusterEnabled ) {
      gluster_configSource = "http://"+telemetryEndpoint+"/gluster";
      glusterHarness = new GlusterHarness( this, gluster_configSource, width/2, height/2, 0 );
      gluster_wsc = telemetry_wsc;
      gluster_wsc.sendMessage("{\"action\":\"subscribe\",\"channel\":\"gluster\"}");
    }
    //===================================

    if ( relayEnabled ) {
      //relay_configSource = "relay.json";
      relay_configSource = "http://"+telemetryEndpoint+"/relay";
      relayHarness_node001 = new RelayHarness( this, relay_configSource, 400, 0, 0, "ev-relay-A-node001" );
      relayHarness_node004 = new RelayHarness( this, relay_configSource, width - 400, 0, 0, "ev-relay-A-node004" );
      relay_wsc = telemetry_wsc;
      relay_wsc.sendMessage("{\"action\":\"subscribe\",\"channel\":\"relay\"}");
    }

    if ( redisEnabled ) {
      //configSource = "redis.json";
      redis_configSource = "http://"+telemetryEndpoint+"/redis";
      redisHarness_node01 = new RedisHarness( this, redis_configSource, 400, -400, 400, "ev-relay-A-redis-01" );
      redisHarness_node02 = new RedisHarness( this, redis_configSource, width - 400, -400, 400, "ev-relay-A-redis-02" );
      redis_wsc = telemetry_wsc;
      redis_wsc.sendMessage("{\"action\":\"subscribe\",\"channel\":\"redis\"}");
    }

/*
    if ( bankEnabled ) {
      bank_configSource = "http://"+telemetryEndpoint+"/capi/banks";
      bankHarness = new BankHarness( this, bank_configSource, width/2, height/2, 300 );
      bank_wsc = telemetry_wsc;
      bank_wsc.sendMessage("{\"action\":\"subscribe\",\"channel\":\"capi\"}");
    }
    if ( capiEnabled ) {
      capi_configSource = "http://"+telemetryEndpoint+"/capi/servers";
      capiHarness = new CapiHarness( this, capi_configSource, width/2, height/2, 0 );
      capi_wsc = telemetry_wsc;
      capi_wsc.sendMessage("{\"action\":\"subscribe\",\"channel\":\"capi\"}");
    }
*/
  }

  if ( mode == 2 ) {
    background(0);
    ellipseMode(CORNER);
    rectMode(CORNER);
    frameRate(20);
  } else if ( mode == 3 ) {
    //frameRate(60);
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
  if ( cam.center != null ) {
    println("eye [center]: "+cam.center.x+","+cam.center.y+","+cam.center.z );
  }
}

public void keyPressed() {
  if ( key == '1' ) {
    spheresEnabled ^= true;
  } else if ( key == '2' ) {
    wireFrame ^= true;
    if ( wireFrame ) {
      sphereDetail(10);
    } else {
      sphereDetail(30);
    }
  } else if ( key == '3' ) {
    shinyVal += 0.05;
    if ( shinyVal > 1.0 ) {
      shinyVal = 1.0;
    }
  } else if ( key == '4' ) {
    shinyVal -= 0.05;
    if ( shinyVal < 0.0 ) {
      shinyVal = 0.0;
    }
  } else if ( key == ' ' ) {
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
float distance;

void setup3D() {
  smooth();
  cp5.setAutoDraw(false);
}

Harness focalObject = null;

void draw3D() {
  pointLight(0, 0, 100, 0, 0, 0 );
  ambientLight(0, 0, 40);

  if ( recording ) {
    background(255);
  } else {
    background(0);
  }

  if ( focalObject == null || !focalObject.isInside ) {
    if ( glusterHarness != null ) {
      glusterHarness.draw3D();
    }
    if ( relayHarness_node001 != null ) {
      relayHarness_node001.draw3D();
    }
    if ( relayHarness_node004 != null ) {
      relayHarness_node004.draw3D();
    }

    if ( redisHarness_node01 != null ) {
      redisHarness_node01.draw3D();
    }
    if ( redisHarness_node02 != null ) {
      redisHarness_node02.draw3D();
    }
  }

  if ( cam.center != null ) {
    PVector closest = new PVector();
    float screenX = 0, screenY = 0;
    PVector np = new PVector();
    ArrayList<Harness>harnesses = new ArrayList<Harness>();
    distance = 10000000.0;

    // Don't recalc focal object while inside target
    if ( focalObject != null && focalObject.isInside ) {
      // Do recalculate distance to determine if
      // we're still inside the target.
      np.set( focalObject.modelX, focalObject.modelY, focalObject.modelZ );
      distance = np.dist( cam.center );
    } else {
      for (Harness h : globalHarnesses ) {
        h.isInside = false;
        h.isLookedAt = false;
        if ((h.screenX >= (0+width/4) && h.screenX <= (width - width/4)) && (h.screenY >= (0+height/4) && h.screenY <= (height - height/4)) ) {
          PVector p = h.pvector;
          if ( p != null ) {
            np.set( h.modelX, h.modelY, h.modelZ );
            h.distance = np.dist( cam.center );
            if ( h.distance < distance ) {
              distance = h.distance;
              focalObject = h;
              closest = np.copy();
              screenX = h.screenX;
              screenY = h.screenY;
            }
          }
        }
      }
    }
    if ( distance < 500 ) {
      float radius = focalObject.calculateRadius();
      focalObject.isLookedAt = true;
      if ( distance <= radius ) {
        focalObject.isInside = true;
        noLights();
        pointLight(0, 0, 100, cam.center.x, cam.center.y, cam.center.z );
        spotLight(
          100, 100, 100, // color
          cam.center.x, cam.center.y, cam.center.z, // position
          0, 0, 0,
          PI/2, 2 ); // angle, concentration
        ambientLight(0, 0, 60);
        cam.friction = 0.1F;
      }
      if ( distance > radius ) {
        focalObject.isInside = false;
        cam.friction = 0.75F;
      }
      if ( distance > (radius + 20) ) { // don't draw if inside (or near) target
        pushStyle();
          // draw line from screen center to target
          stroke(300,100,100);
          PVector p2 = rayTrace(cam.center.x, cam.center.y, cam.center.z, closest.x, closest.y, closest.z, radius);

          // draw small sphere on the surface of the target
          pushMatrix();
            translate(p2.x,p2.y,p2.z);
            fill(0,100,100);
            sphere(1);
          popMatrix();
          // draw small sphere in the center of the HUD.
          pushMatrix();
            resetMatrix();
            applyMatrix( originalMatrix );
            translate(width/2,height/2);
            fill(150,100,100);
            sphere(1);
          popMatrix();

        popStyle();
      }
      cam.beginHUD();
      focalObject.drawLabel();
      if ( focalObject.isInside ) {
        focalObject.drawHUD();
      }
      cam.endHUD();
    }
  }

  drawMainHUD();
  //gui();
}

void drawMainHUD() {
  cam.beginHUD();
  hint(DISABLE_DEPTH_TEST);
  pushStyle();
  lights();
  fill( 150, 100, 100 );
  String m = "Telemetry bytes/sec: "+telemetry_bytes_last_second+"\nTelemetry packets/sec: "+telemetry_messages_last_second+"\n";
  if ( relayEnabled ) {
    m += "Relay 001 events/sec: "+relayHarness_node001.total_eps+"\n";
    m += "Relay 004 events/sec: "+relayHarness_node004.total_eps+"\n";
  }
  if ( cam.center != null ) {
    m += "Eye ["+cam.center.x+","+cam.center.y+","+cam.center.z+"]\n";
    m += "Distance ["+distance+"]\n";
  }
  m += "Framerate ["+frameRate+"]\n";
  text( m, width-300, 10, 300, 100 );
  noLights();
  popStyle();
  hint(ENABLE_DEPTH_TEST);
  cam.endHUD();
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
  noLights();
  hint(ENABLE_DEPTH_TEST);
}

void webSocketEvent(String msg) {
  JSONObject json = parseJSONObject(msg);

  telemetry_bytes_this_second += msg.length();
  telemetry_messages_this_second++;

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
      int millis = millis();

      println( "r.rtProc.events["+nodeName+":"+shard+"] is "+r.rtProc.events );
      println( "r.rtProc.delta_events["+nodeName+":"+shard+"] is "+r.rtProc.delta_events );
      println( "r.rtProc.updatedMillis["+nodeName+":"+shard+"] is "+r.rtProc.updatedMillis );
      println( "r.rtProc.event_counts_updated_at["+nodeName+":"+shard+"] is "+r.rtProc.event_counts_updated_at );

      int current_eps    = payload.getInt( "eps" );
      int current_events = payload.getInt( "events" );
      r.rtProc.delta_events = current_events - r.rtProc.events;

      println( "Delta events for "+nodeName+":"+shard+" is "+r.rtProc.delta_events+"; current events is "+current_events+", prev events is "+r.rtProc.events );
      if ( r.rtProc.event_counts_updated_at == 0 ) {
        r.rtProc.real_eps = current_eps; // use instantaneous value while calibrating
      } else {
        int delta_millis = millis - r.rtProc.event_counts_updated_at;
        r.rtProc.real_eps = (int)(r.rtProc.delta_events / (delta_millis /1000.0));
      }
      r.rtProc.updatedMillis = millis;
      r.rtProc.event_counts_updated_at = millis;

      r.rtProc.clients          = payload.getInt( "clients" );
      r.rtProc.eps              = current_eps;
      r.rtProc.events           = current_events;
      println( "setting r.rtProc.events["+nodeName+":"+shard+"] to "+r.rtProc.events );
      r.rtProc.invalid_keys     = payload.getInt( "invalid_keys" );
      r.rtProc.user_state_qps   = payload.getInt( "user_state_qps" );
      r.rtProc.user_var_qps     = payload.getInt( "user_var_qps" );
      r.rtProc.beta_reads       = payload.getInt( "beta_reads" );
      r.rtProc.gamma_reads      = payload.getInt( "gamma_reads" );
      r.rtProc.gamma_misses     = payload.getInt( "gamma_misses" );
      r.rtProc.gamma_collisions = payload.getInt( "gamma_collisions" );
      r.rtProc.jitter           = payload.getFloat( "jitter" );
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
    } else if ( type.equals("evRelay-pidstat-cpu") || type.equals("redis-pidstat-cpu") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      String task = payload.getString( "task" );
      Process p = null;
      if ( task.equals("evRTProc") ) {
        RTProcHarness h = RTProcHarness_findOrCreate( nodeName, shard );
        p = h.process;
        h.process.updatedMillis = millis();
      } else if ( task.equals("ktserver") ) {
        KTServerHarness h = KTServerHarness_findOrCreate( nodeName, shard );
        p = h.process;
        h.process.updatedMillis = millis();
      } else if ( task.equals("evRelayStream") ) {
        RelayStreamHarness h = RelayStreamHarness_findOrCreate( nodeName, shard );
        p = h.process;
        h.process.updatedMillis = millis();
      } else if ( task.equals("evRelaySubStream") ) {
        RelaySubStreamHarness h = RelaySubStreamHarness_findOrCreate( nodeName, shard );
        p = h.process;
        h.process.updatedMillis = millis();
      } else if ( task.equals("redis") ) {
        RedisProcHarness h = RedisProcHarness_findOrCreate( nodeName, shard );
        p = h.process;
        h.process.updatedMillis = millis();
      }
      if ( p != null ) {
        p.num_fds = payload.getInt("num_fds");
        p.cpuTotal = payload.getFloat("cpuTotal");
        p.cpu      = payload.getInt("cpu");
        p.usr      = payload.getFloat("usr");
        p.system   = payload.getFloat("system");
        p.pid      = payload.getInt("pid");
      }
    } else if ( type.equals("evRelay-pidstat-io") || type.equals("redis-pidstat-io") ) {
      JSONObject payload = json.getJSONObject( "payload" );
      String nodeName = json.getString( "host" );
      String shard = payload.getString( "shard" );
      String task = payload.getString( "task" );
      Process p = null;
      if ( task.equals("evRTProc") ) {
        RTProcHarness h = RTProcHarness_findOrCreate( nodeName, shard );
        p = h.process;
      } else if ( task.equals("ktserver") ) {
        KTServerHarness h = KTServerHarness_findOrCreate( nodeName, shard );
        p = h.process;
      } else if ( task.equals("evRelayStream") ) {
        RelayStreamHarness h = RelayStreamHarness_findOrCreate( nodeName, shard );
        p = h.process;
      } else if ( task.equals("evRelaySubStream") ) {
        RelaySubStreamHarness h = RelaySubStreamHarness_findOrCreate( nodeName, shard );
        p = h.process;
      } else if ( task.equals("redis") ) {
        RedisProcHarness h = RedisProcHarness_findOrCreate( nodeName, shard );
        p = h.process;
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

int heartbeat_counter = 0;

int lastMillis = 0;
void onTimerEvent() {
  int curMillis = millis();
  int millisDiff = curMillis - lastMillis;
  lastMillis = millisDiff + lastMillis;

  tickerSecond( lastMillis, curMillis );
}

void tickerSecond( int lastMillis, int curMillis ) {

  telemetry_bytes_last_second = telemetry_bytes_this_second;
  telemetry_bytes_this_second = 0;
  telemetry_messages_last_second = telemetry_messages_this_second;
  telemetry_messages_this_second = 0;

  if ( replay ) {
    replayEvents();
  }

  if ( telemetry_wsc != null ) {
    // Keep the channel alive
    heartbeat_counter++;
    if ( heartbeat_counter > 5 ) {
      heartbeat_counter = 0;
      telemetry_wsc.sendMessage("{\"action\":\"heartbeat\"}");
    }
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


public ArrayList<PVector> helix(float zIncrement, float increment, int numItems, float radius) {
  float x = 0, y = 0, z = 0, inc = 0;
  ArrayList<PVector> locations = new ArrayList<PVector>();

  for(int i = 0; i < numItems; i++) {
    x = radius * cos(radians(inc));
    y = radius * sin(radians(inc));
    inc += increment;
    z += zIncrement;
    PVector p = new PVector(x, y, z);
    locations.add(p);
  }
  return locations;
}
