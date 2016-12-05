//the harness controller lets you associate a CP5 widget with a harness

class HarnessController {
  public Controller c;
  float xOffset, yOffset;
  HarnessController( Controller _c, float _xOffset, float _yOffset ) {
    c = _c;
    xOffset = _xOffset;
    yOffset = _yOffset;
  }
  void setPosition( float _xPos, float _yPos ) {
    c.setPosition( _xPos+xOffset, _yPos+yOffset );
  }
}