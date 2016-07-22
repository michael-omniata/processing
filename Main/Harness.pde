
class Harness {
  int xPos, yPos;
  int boxSize;

  Harness( int x, int y, int size ) {
    xPos = x;
    yPos = y;
    boxSize = size;
  }
  void update() {
    if ( mousePressed && mouseHovering() ) {
      setX( mouseX );
      setY( mouseY );
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
  int getX() { 
    return xPos;
  }
  int getY() { 
    return yPos;
  }
  void setX(int newX) { 
    xPos = newX;
  }
  void setY(int newY) { 
    yPos = newY;
  }
}