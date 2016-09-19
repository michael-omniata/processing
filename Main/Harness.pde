//Harness is the Superclass for all other harness classes 
import shapes3d.utils.*;
import shapes3d.animation.*;
import shapes3d.*;

class Harness {
  float xPos, yPos, zPos;
  float modelX, modelY, modelZ;
  float screenX, screenY;
  public float radius;
  boolean overImg = false;
  boolean locked = false;
  float xOffset = 0.0; 
  float yOffset = 0.0;
  float zOffset = 0.0;
  String label;
  color stroke;
  boolean isLookedAt = false;
  boolean isInside = false;
  int updatedMillis; // when model was updated with actual values
  int stroke_weight;
//  public boolean isClickable;
  PVector pvector;
  Shape3D shape;
  int curColor;
  DawesomeToolkit ds;
  ArrayList<HarnessController>harnessControllers;

  Harness() {
    harnessControllers = new ArrayList<HarnessController>();
    ds = new DawesomeToolkit( app );
    shape = new Ellipsoid( app, 64, 64 );

    Ellipsoid s = (Ellipsoid)shape;
    s.setRadius( 10 );

    //isClickable = true;
    isClickable = false;
  }
  
  void setSphere() {
    //shape = new Ellipsoid( app, 64, 64 );
  }
  void moveTo( float x, float y ) {
    xPos = x;
    yPos = y;
  }
  void moveTo( float x, float y, float z ) {
    xPos = x;
    yPos = y;
    zPos = z;
  }
  void setLabel( String value ) {
    label = value;
  }
  String getLabel() {
    return label;
  }
  void addController( Controller c, int _xOffset, int _yOffset ) {
    HarnessController hc = new HarnessController( c, _xOffset, _yOffset );
    hc.setPosition( xPos, yPos );
    harnessControllers.add( hc );
  }
  boolean mouseHovering() {
    // override this in subclasses
    return false;
  }
  void hideControllers() {
    for ( HarnessController hc : harnessControllers ) {
      hc.c.hide();
    }
  }
  void showControllers() {
    for ( HarnessController hc : harnessControllers ) {
      hc.c.show();
    }
  }  
  void update() {
    if ( this.mouseHovering() ) {
      overImg = true;  
      if (!locked) { 
  //      stroke(255);
      }
    } else {
  //    stroke(153);
      overImg = false;
    }
    if (locked) {
      // If we're here, the harness is selected.
      // Move it, and all of the associated controllers
      setPosition( mouseX-xOffset, mouseY-yOffset );
    }
    if ( mousePressed ) {
      if (overImg) { 
        locked = true;
      } else {
        locked = false;
      }
      xOffset = mouseX-xPos; 
      yOffset = mouseY-yPos;
    } else {
      locked = false;
    }
  }
  void setColor( color c ) {
    fill( c );
  }
  void setStroke( color x ) {
    stroke = x;
  }
  void setStrokeWeight( int x) {
    stroke_weight = x;
  }
  void setPosition( float _x, float _y ) {
    xPos = _x;
    yPos = _y;
    for (HarnessController hc : harnessControllers ) {
      hc.setPosition( xPos, yPos );
    }
  }
  // override this in subclasses
  float calculateHue() {
    return( 0 );
  }
  // override this in subclasses
  float calculateSaturation() {
    return( 100 );
  }
  // override this in subclasses
  float calculateBrightness() {
    return( 100 );
  }
  // override this in subclasses
  boolean calculateVisibility() {
    return( true );
  }
  float calculateRadius() {
    return( 10 );
  }
  boolean hasActivity() {
    return false;
  }
  float calculateActivityIndicatorHue() {
    return 200; // blue
  }
  float calculateActivityIndicatorWeight() {
    return 1;
  }
  // override this in subclasses
  float calculateContainerHue() {
    return( 0 );
  }
  // override this in subclasses
  float calculateContainerSaturation() {
    return( 100 );
  }
  // override this in subclasses
  float calculateContainerBrightness() {
    return( 100 );
  }
  // override this in subclasses
  boolean calculateContainerVisibility() {
    return( false );
  }
  // override this in subclasses
  float calculateContainerRadius() {
    return( 90 );
  }

  // override this in subclasses
  void preTransform() {
  }

  // override this in subclasses
  void draw3D() {
    if ( isClickable ) {
      if ( shape == selectedShape ) {
  println( "Found selected shape" );
        Ellipsoid s = (Ellipsoid)shape;
        s.setRadius( 2 * calculateRadius() );
        selectedShape = null;
      }
      int thisColor = color(calculateHue(), calculateSaturation(), calculateBrightness());
      if ( thisColor != curColor ) {
        Ellipsoid s = (Ellipsoid)shape;
        s.fill( thisColor );
        curColor = thisColor;

  //    s.setRadius( calculateRadius() );
      }
      shape.draw();
    } else {
      fill(calculateHue(), calculateBrightness(), calculateSaturation());
      sphere(calculateRadius());

    }

    modelX = modelX( 0, 0, 0 );
    modelY = modelY( 0, 0, 0 );
    modelZ = modelZ( 0, 0, 0 );
    screenX = screenX(0, 0, 0);
    screenY = screenY(0, 0, 0);

  }
  void drawLabel() {
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    translate( 10, 10 );
    if ( label != null ) {
      text( label, 0, 0 );
    } else {
      text( "modelX: "+modelX+"\n"+"modelY: "+modelY+"\n"+"modelZ: "+modelZ, 0, 0 );
      //text( "Unknown", 0, 0 );
    }
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }
  void drawHUD() {
    hint(DISABLE_DEPTH_TEST);
    pushMatrix();
    translate( 200, 200 );
    pushStyle();
    fill( 200, 100, 100 );
    text( "modelX: "+modelX+"\n"+"modelY: "+modelY+"\n"+"modelZ: "+modelZ, 0, 10, 400, 400 );
    popStyle();
    popMatrix();
    hint(ENABLE_DEPTH_TEST);
  }

  void drawActivity( PVector p ) {
    pushStyle();
    // set the color of the line to be based on a ratio of reads to writes
    stroke(calculateActivityIndicatorHue());
    strokeWeight(calculateActivityIndicatorWeight());
    rayTrace( p.x, p.y, p.z, 0, 0, 0, calculateContainerRadius() );
    popStyle();
  }
}

