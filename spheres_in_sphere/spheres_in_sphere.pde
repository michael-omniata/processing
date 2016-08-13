import dawesometoolkit.*;
import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

int OUTER_SPHERE_RADIUS = 150;
int INNER_SPHERE_RADIUS = 50;
int numSpheres = 4;
DawesomeToolkit ds = new DawesomeToolkit( this );
int xPos;
int yPos;
int zPos;

ArrayList<PVector> vectors = ds.circularLayout( numSpheres, INNER_SPHERE_RADIUS * sqrt(numSpheres/2) );

Ellipsoid[] spheres = new Ellipsoid[4];
boolean clicked = false;

void setup() {
  size( 600, 600, P3D );
  xPos = width/2;
  yPos = height/2;
  zPos = 0;
  colorMode(HSB,360,100,100,100);
  for ( int i = 0; i < spheres.length; i++ ) {
    spheres[i] = new Ellipsoid(this, 64, 64);
    spheres[i].setRadius(INNER_SPHERE_RADIUS);
  }
}

int pick_index = 0;
void mouseClicked() {
  clicked = true;
}

void draw() {
  Shape3D picked;

  camera();
  background(0);
  pushMatrix();
    noStroke();
    translate(xPos, yPos, zPos);

    

    // rotate around X access
    float xRot = radians(180 - millis()*0.03);
    rotateX( xRot ); 
    // rotate around Y access
    float yRot = radians(180 - millis()*0.03);
    rotateY( yRot ); 

    if (clicked) {
      clicked = false;
      picked = Shape3D.pickShape(this, mouseX, mouseY);
      int i;
      for( i = 0; i < spheres.length; i++ ) {
        pick_index = i;
        if ( picked == spheres[i] ) {
          println( "Picked sphere "+i );
          break;
        }
      }
    }

    for (int i = 0; i < vectors.size(); i++) {
      PVector p = vectors.get(i);
      pushMatrix();
        spheres[i].moveTo(p);
        // draw the green inner spheres
        //translate(p.x, p.y, p.z);
        //fill( 100, 100, 100, 100 );
        //sphere(INNER_SPHERE_RADIUS);
        pushStyle();
          if ( i == pick_index ) {
            spheres[i].fill( color(0,100,50,100) );
          } else {
            spheres[i].fill( color(100,100,100,100) );
          }
        popStyle();
        spheres[i].tag = "Sphere " + i;
        spheres[i].draw();
      popMatrix();

      // draw small spheres on the inner spheres closest to the outer sphere
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
