//Harness is the Superclass for all other harness classes 

class Harness {
  float xPos, yPos;
  int len, hgt;
  boolean overBox = false;
  boolean locked = false;
  float xOffset = 0.0; 
  float yOffset = 0.0;
  ArrayList<HarnessController>harnessControllers;

  Harness( int x, int y, int l, int h ) {
    xPos = x;
    yPos = y;
    len = l;
    hgt = h;
    harnessControllers = new ArrayList<HarnessController>();
  }
  void addController( Controller c, int _xOffset, int _yOffset ) {
    HarnessController hc = new HarnessController( c, _xOffset, _yOffset );
    hc.setPosition( xPos, yPos );
    harnessControllers.add( hc );
  }
  void update() {
    if ( mouseHovering() ) {
      overBox = true;  
      if (!locked) { 
        stroke(255);
      }
    } else {
      stroke(153);
      overBox = false;
    }
    if (locked) {
      // If we're here, the harness is selected.
      // Move it, and all of the associated controllers
      xPos = mouseX-xOffset; 
      yPos = mouseY-yOffset;
      for (HarnessController hc : harnessControllers ) {
        hc.setPosition( xPos, yPos );
      }
    }
    if ( mousePressed ) {
      if (overBox) { 
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
  boolean mouseHovering() {
    return (
      (mouseX > (xPos-len/2)) && (mouseX < (xPos+len/2)) &&
      (mouseY > (yPos-hgt/2)) && (mouseY < (yPos+hgt/2))
      );
  }
  void setColor( color c ) {
    fill( c );
  }
  void setStroke( int x) {
    stroke( x );
  }
  float getX() { 
    return xPos;
  }
  float getY() { 
    return yPos;
  }
  void setX(float newX) { 
    xPos = newX;
  }
  void setY(float newY) { 
    yPos = newY;
  }
  void setLength(int newLen) {
   len = newLen; 
  }
  void setHeight(int newHgt) {
   hgt = newHgt; 
  }
}