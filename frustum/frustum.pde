import dawesometoolkit.*;

float fovy;
float aspect;
float zNear;
float zFar;

CrazyCam cam;

int OUTER_SPHERE_RADIUS = 500;
int INNER_SPHERE_RADIUS = 10;
int numSpheres = 300;
DawesomeToolkit ds = new DawesomeToolkit( this );
int xPos, yPos, zPos;

ArrayList<PVector> vectors = ds.fibonacciSphereLayout( numSpheres, OUTER_SPHERE_RADIUS );

void setup() {
  size( 1400, 1024, P3D );

  xPos = width/2;
  yPos = height/2;
  zPos = 0;

  cam = new CrazyCam(this);

  fovy = 1.047198F;
  aspect = (float)width / (float)height;
  zNear = 0.01;
  zFar = 5000.0;

  perspective(fovy, aspect, zNear, zFar);
  colorMode(HSB,360,100,100,255);
}



void draw() {
  background(0);

  pointLight(0, 0, 100, 0, 0, 0 );
  ambientLight(0, 0, 40);
  translate(xPos, yPos, zPos);
  pushMatrix();
    noStroke();

    float xRot = radians(180 - millis()*0.005); // rotate around X access
    float yRot = radians(180 - millis()*0.005); // rotate around Y access
    rotateX( xRot ); 
    rotateY( yRot ); 

    fill( 200, 100, 100, 100 );
    for (int i = 0; i < vectors.size(); i++) {
      PVector p = vectors.get(i);
      if ( isViewable( fovy, aspect, zNear, zFar, cam.eye, cam.center, cam.up, cam.right, p, INNER_SPHERE_RADIUS ) ) {
        pushMatrix();
          translate(p.x,p.y,p.z);
          sphere(INNER_SPHERE_RADIUS);
        popMatrix();
      }
    }

  popMatrix();
  drawMainHUD();
}

boolean isViewable(
  float fovy,
  float aspect,
  float zNear,
  float zFar,
  PVector eye,
  PVector center,
  PVector up,
  PVector right,
  PVector point,
  float radius ) {

  return true;
}

void drawMainHUD() {
  cam.beginHUD();
  hint(DISABLE_DEPTH_TEST);
  pushStyle();
  lights();
  fill( 150, 100, 100 );
  String m = "Framerate ["+frameRate+"]\n";
  if ( cam.center != null ) {
    m += "Eye       ["+cam.eye.x+","+cam.eye.y+","+cam.eye.z+"]\n";
    m += "Center    ["+cam.center.x+","+cam.center.y+","+cam.center.z+"]\n";
    m += "Up        ["+cam.up.x+","+cam.up.y+","+cam.up.z+"]\n";
    m += "Right     ["+cam.forward.x+","+cam.forward.y+","+cam.forward.z+"]\n";
    m += "Velocity  ["+cam.velocity.x+","+cam.velocity.y+","+cam.velocity.z+"]\n";
  }
  text( m, width-400, 10, 400, 100 );
  noLights();
  popStyle();
  hint(ENABLE_DEPTH_TEST);
  cam.endHUD();
}
