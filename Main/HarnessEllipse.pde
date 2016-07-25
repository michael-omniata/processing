class HarnessEllipse extends Harness {
  int wth, hgt;

  HarnessEllipse( int x, int y, int _wth, int _hgt ) {
    super( x, y );
    wth = _wth;
    hgt = _hgt;
  }
  void draw() {
    ellipse(xPos, yPos, wth, hgt);
  }
  @Override public boolean mouseHovering() {
    return (
      ((mouseX >= xPos) && (mouseX <= xPos+wth)) &&
      ((mouseY >= yPos) && (mouseY <= yPos+hgt)) );
  }
}