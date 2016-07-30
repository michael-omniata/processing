class HarnessRect extends Harness {
  int wth, hgt;

  HarnessRect( int x, int y, int w, int h ) {
    super( x, y );
    wth = w;
    hgt = h;
  }
  void draw() {
    pushStyle();
    strokeWeight( stroke_weight );
    stroke( stroke );
    rect(xPos, yPos, wth, hgt);
    popStyle();
  }
  @Override public boolean mouseHovering() {
    return (
      ((mouseX >= xPos) && (mouseX <= xPos+wth)) &&
      ((mouseY >= yPos) && (mouseY <= yPos+hgt)) );
  }
}
