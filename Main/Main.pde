//Main part of the program, contains all global variables and setup() and draw()

import controlP5.*;
ControlP5 cp5;

import websockets.*;
WebsocketClient wsc;

import dawesometoolkit.*;
import org.multiply.processing.TimedEventGenerator;


int mode = 3; // 2=2D, 3=3D

GlusterHarness glusterHarness;

void setup() {
  //  if ( mode == 2 ) {
  //    size(1024, 1024);
  //  } else {
  size(1024, 1024, P3D);
  //  }
  cp5 = new ControlP5(this);
  glusterHarness = new GlusterHarness( this, "http://ec2-54-158-33-191.compute-1.amazonaws.com:3001/gluster" );
  //glusterHarness = new GlusterHarness( this, "gluster.json" );
  wsc = new WebsocketClient(this, "ws://ec2-54-158-33-191.compute-1.amazonaws.com:3001/gluster/stats");

  if ( mode == 2 ) {
    background(0);
    ellipseMode(CORNER);
    rectMode(CORNER);
    frameRate(20);
  } else if ( mode == 3 ) {
    setup3D();
  }
}

void draw() {
  if ( mode == 2 ) {
    draw2D();
  } else if ( mode == 3 ) {
    draw3D();
  }
}

void setup3D() {
  smooth();
  cp5.setAutoDraw(false);
  colorMode(HSB, 300, 100, 100, 255);
}

void draw3D() {
  pointLight(0, 0, 100, 0, 0, 0 );
  ambientLight(0, 0, 60);

  glusterHarness.draw3D();
  gui();
}

void draw2D() {
  glusterHarness.draw2D();
}

void gui() {
  hint(DISABLE_DEPTH_TEST);
  lights(); // otherwise cp5 controllers are dark
  cp5.draw();
  hint(ENABLE_DEPTH_TEST);
}

void webSocketEvent(String msg) {
  JSONObject json = parseJSONObject(msg);

  glusterHarness.updateFromJSON( json );
}

int lastMillis = 0;
void onTimerEvent() {
  int curMillis = millis();
  int millisDiff = curMillis - lastMillis;
  lastMillis = millisDiff + lastMillis;
//  println("Got a timer event at " + millis() + "ms (" + millisDiff + ")!");
  glusterHarness.tickerSecond( lastMillis, curMillis );
//  println("Required "+(millis()-lastMillis)+" milliseconds" );
}
