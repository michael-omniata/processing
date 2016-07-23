
class Harness {
  float xPos, yPos;
  int boxSize;
  boolean overBox = false;
  boolean locked = false;
  float xOffset = 0.0; 
  float yOffset = 0.0; 


  Harness( int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
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
      xPos = mouseX-xOffset; 
      yPos = mouseY-yOffset;
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
      (mouseX > xPos-(boxSize/2)) && (mouseX < (xPos+(boxSize/2))) &&
      (mouseY > yPos-(boxSize/2)) && (mouseY < (yPos+(boxSize/2)))
      );
  }
  void setColor( color c ) {
    fill( c );
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
}