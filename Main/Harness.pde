
class Harness {
  int xPos, yPos;
  int len, hgt;

  Harness( int x, int y, int l, int h ) {
    xPos = x;
    yPos = y;
    len = l;
    hgt = h;
  }
  void update() {
    if ( mousePressed && mouseHovering() ) {
      setX( mouseX );
      setY( mouseY );
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
  void setLength(int newLen) {
   len = newLen; 
  }
  void setHeight(int newHgt) {
   hgt = newHgt; 
  }
}