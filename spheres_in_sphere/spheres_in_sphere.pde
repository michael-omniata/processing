import dawesometoolkit.*;

int OUTER_SPHERE_RADIUS = 150;
int INNER_SPHERE_RADIUS = 50;
int numSpheres = 4;
DawesomeToolkit ds = new DawesomeToolkit( this );
int xPos;
int yPos;
int zPos;

//(INNER_SPHERE_RADIUS*2) * sqrt(2) );
ArrayList<PVector> vectors = ds.circularLayout( numSpheres, INNER_SPHERE_RADIUS * sqrt(numSpheres/2) );

void setup() {
  size( 600, 600, P3D );
  xPos = width/2;
  yPos = height/2;
  zPos = 0;
  colorMode(HSB,360,100,100,100);
}

void draw() {
  background(0);
  pushMatrix();
    noStroke();
    translate(xPos, yPos, zPos);

    
    /*
    // rotate around X access
    float xRot = radians(180 - millis()*0.01);
    rotateX( xRot ); 
    // rotate around Y access
    float yRot = radians(180 - millis()*0.01);
    rotateY( yRot ); 
    */


    // note: if there are more harnesses than vectors, they will be omitted!
    for (int i = 0; i < vectors.size(); i++) {
      PVector p = vectors.get(i);
      //println( i+": "+p.x+","+p.y+","+p.z );
      pushMatrix();
      /* // moves inner spheres in and out
        float scaler = sin(frameCount/100.0)*1.41;
        p = PVector.mult(p,scaler);
       */

      // draw the green inner spheres
        translate(p.x, p.y, p.z);
        fill( 100, 100, 100, 100 );
        sphere(INNER_SPHERE_RADIUS);
      popMatrix();
      if (((int)p.y) == 0) {
        if ( p.x < 0 ) {
          pushMatrix();
            translate(p.x-(INNER_SPHERE_RADIUS),p.y,p.z);
            fill( 200, 100, 100, 100 );
            sphere(4);
          popMatrix();
          pushMatrix();
            pushStyle();
              stroke(0,0,100);
              line( 0, 0, 0, p.x-(INNER_SPHERE_RADIUS*2), p.y, p.z );
            popStyle();
          popMatrix();
        } else {
          pushMatrix();
            translate(p.x+(INNER_SPHERE_RADIUS),p.y,p.z);
            fill( 250, 100, 100, 100 );
            sphere(4);
          popMatrix();
          pushMatrix();
            pushStyle();
              stroke(0,0,100);
              line( 0, 0, 0, p.x+(INNER_SPHERE_RADIUS*2), p.y, p.z );
            popStyle();
          popMatrix();
        }
      } else {
        if ( p.y < 0 ) {
          pushMatrix();
            translate(p.x,p.y-(INNER_SPHERE_RADIUS),p.z);
            fill( 300, 100, 100, 100 );
            sphere(4);
          popMatrix();
          pushMatrix();
            pushStyle();
              stroke(0,0,100);
              line( 0, 0, 0, p.x, p.y-(INNER_SPHERE_RADIUS*2), p.z );
            popStyle();
          popMatrix();
        } else {
          pushMatrix();
            translate(p.x,p.y+(INNER_SPHERE_RADIUS),p.z);
            fill( 350, 100, 100, 100 );
            sphere(4);
          popMatrix();
          pushMatrix();
            pushStyle();
              stroke(0,0,100);
              line( 0, 0, 0, p.x, p.y+(INNER_SPHERE_RADIUS*2), p.z );
            popStyle();
          popMatrix();
        }
      }
    }
    // Note: The outer sphere *must* be drawn *after* the inner sphere's, or
    // the inner spheres will not be visible, no matter what the alpha value is.
    pushStyle();
      fill( 200, 100, 100, 10 );
      sphere(OUTER_SPHERE_RADIUS);
    popStyle();
  popMatrix();
}
