class HarnessRect extends Harness {
  int wth, hgt;

  HarnessRect( int x, int y, int w, int h ) {
    super( x, y );
    wth = w;
    hgt = h;
  }
  void draw() {
    rect(xPos, yPos, wth, hgt);
  }
  @Override public boolean mouseHovering() {
    return (
      ((mouseX >= xPos) && (mouseX <= xPos+wth)) &&
      ((mouseY >= yPos) && (mouseY <= yPos+hgt)) );
  }
}