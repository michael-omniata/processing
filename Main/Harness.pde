//Harness is the Superclass for all other harness classes 

class Harness {
  float xPos, yPos;
  boolean overImg = false;
  boolean locked = false;
  float xOffset = 0.0; 
  float yOffset = 0.0;
  int stroke;
  int stroke_weight;
  ArrayList<HarnessController>harnessControllers;

  Harness( int x, int y ) {
    xPos = x;
    yPos = y;
    harnessControllers = new ArrayList<HarnessController>();
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
  void setStroke( int x ) {
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
}
