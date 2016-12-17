import java.util.Iterator;

import dawesometoolkit.*;

import java.util.*;
import java.text.*;

String configSource;
String gluster_configSource;
String gluster_dataSource;

import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

import controlP5.*;
ControlP5 cp5;
Shape3D selectedShape;

boolean wireFrame = false;
boolean clicked = false;
boolean freezeEverything = false;
boolean spheresEnabled = true;
float shinyVal = 1.0;

CrazyCam cam;

ArrayList<Harness> globalHarnesses = new ArrayList<Harness>();

GlusterHarness  glusterHarness;
PApplet app = this;
boolean isClickable = false;

void setup() {
  size(1400, 1024, OPENGL);
  background(0);
  smooth();
  sphereDetail( 60 );
  cam = new CrazyCam(this);
  //float cameraZ = ((height/2.0) / tan(PI*60.0/360.0));
  //perspective(PI/3.0, width/height, cameraZ/10.0, cameraZ*50.0);
  perspective(1.047198F, (float)width / (float)height, 0.01F, 1000F*5);

  colorMode(HSB, 300, 100, 100, 255);

  gluster_configSource = "gluster.json";
  glusterHarness = new GlusterHarness( this, gluster_configSource, width/2, height/2, 0 );

  smooth();
}

int nextVisibilityCalc = 0;
void draw() {
  background(0);
  pointLight(0, 0, 100, 0, 0, 0 );
  ambientLight(0, 0, 40);

  if ( millis() > nextVisibilityCalc ) {
    nextVisibilityCalc = (millis() + 1000);
    println( "Recalculating visibility" );
    for ( Harness h : globalHarnesses ) {
      if ( random(1) < 0.5 ) {
        h.isViewable = false;
      } else {
        h.isViewable = true;
      }
    }
  }

  if ( glusterHarness != null ) {
    glusterHarness.draw3D();
  }
  drawMainHUD(); // shows the current frame rate
}

void drawMainHUD() {
  cam.beginHUD();
  hint(DISABLE_DEPTH_TEST);
  pushStyle();
  lights();
  fill( 150, 100, 100 );
  String m = "Framerate ["+frameRate+"]\n";

  if ( cam.center != null ) {
    m += "Eye ["+cam.center.x+","+cam.center.y+","+cam.center.z+"]\n";
  }
  text( m, width-300, 10, 300, 100 );
  noLights();
  popStyle();
  hint(ENABLE_DEPTH_TEST);
  cam.endHUD();
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
