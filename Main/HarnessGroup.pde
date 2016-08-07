class HarnessGroup {
  public ArrayList<Harness> harnesses;
  public boolean rotationEnabled;
  public float containerRadius;
  public float containerHue;
  public float containerSaturation;
  public float containerBrightness;
  public int containerAlpha;
  public boolean containerEnabled;

  public boolean rotationXEnabled;
  public boolean rotationYEnabled;
  public float rotationXAngle;
  public float rotationYAngle;
  public float rotationXSpeed;
  public float rotationYSpeed;

  boolean reLayoutRequired = false;

  String layout;
  ArrayList<PVector> vectors;
  float radius;
  int xstep, ystep, cols;
  float xPos, yPos, zPos;
  float offset_from_poles;
  DawesomeToolkit ds;

  HarnessGroup( PApplet app, float _xPos, float _yPos, float _zPos ) {
    ds = new DawesomeToolkit( app );
    harnesses = new ArrayList<Harness>();
    xPos = _xPos;
    yPos = _yPos;
    zPos = _zPos;
    rotationXEnabled = false;
    rotationYEnabled = false;
    rotationXAngle = 180;
    rotationYAngle = 180;
    rotationXSpeed = 0.01;
    rotationYSpeed = 0.01;
    containerEnabled = false;
  }
  void setPosition( float _xPos, float _yPos, float _zPos ) {
    xPos = _xPos;
    yPos = _yPos;
    zPos = _zPos;
  }
  void setContainer( float _radius, float _hue, float _saturation, float _brightness, int _alpha ) {
    containerRadius     = _radius;
    containerHue        = _hue;
    containerSaturation = _saturation;
    containerBrightness = _brightness;
    containerAlpha      = _alpha;
  }
  void setRotationAnglesAndSpeeds( float _xDegrees, float _yDegrees, float _xSpeed, float _ySpeed ) {
    rotationXAngle = _xDegrees;
    rotationYAngle = _yDegrees;
    rotationXSpeed = _xSpeed;
    rotationYSpeed = _ySpeed;
  }
  void stopXRotation() {
    rotationXEnabled = false;
  }
  void startXRotation() {
    rotationXEnabled = true;
  }
  void stopYRotation() {
    rotationYEnabled = false;
  }
  void startYRotation() {
    rotationYEnabled = true;
  }
  void fibonacciSphereLayout( float _radius ) {
    layout = "fibonacciSphere";
    radius = _radius;
    vectors = ds.fibonacciSphereLayout( harnesses.size(), _radius );
  }
  void circularLayout( float _radius ) {
    layout = "circular";
    radius = _radius;
    vectors = ds.circularLayout( harnesses.size(), radius );
  }
  void gridLayout( int _xstep, int _ystep, int _cols ) {
    layout = "grid";
    xstep = _xstep;
    ystep = _ystep;
    cols  = _cols;
    vectors = ds.gridLayout( harnesses.size(), _xstep, _ystep, _cols );
  }
  void mapGridAroundSphere( float radius, float _offset_from_poles ) {
    layout = "sphere";
    offset_from_poles = _offset_from_poles;
    vectors = ds.mapPVectorsAroundSphere(vectors,radius,_offset_from_poles);
  }
  void reLayout() {
    if ( layout.equals("fibonacciSphere") ) {
      fibonacciSphereLayout( radius );
    } else if ( layout.equals("circular") ) {
      circularLayout( radius );
    } else if ( layout.equals("grid") ) {
      gridLayout( xstep, ystep, cols );
    } else if ( layout.equals("sphere") ) {
      gridLayout( xstep, ystep, cols );
      mapGridAroundSphere( radius, offset_from_poles );
    }
    reLayoutRequired = false;
  }
  void addHarness( Harness h ) {
    harnesses.add( h );
    reLayoutRequired = true;
  }
  void removeHarness( Harness h ) {
    for ( int i = 0; i < harnesses.size(); i++ ) {
      if ( harnesses.get(i) == h ) {
        harnesses.remove(i);
        reLayoutRequired = true;
        break;
      }
    }
  }

  void draw() {
    if ( reLayoutRequired ) {
      reLayout();
    }
    pushMatrix();
      noStroke();
      translate(xPos, yPos, zPos);

      if ( rotationXEnabled ) {
        float xRot = radians(rotationXAngle -  millis()*rotationXSpeed);
        rotateX( xRot ); 
      }
      if ( rotationYEnabled ) {
        float yRot = radians(rotationYAngle -  millis()*rotationYSpeed);
        rotateY( yRot ); 
      }
      for (int i = 0; i < vectors.size(); i++) {
        PVector p = vectors.get(i);
        Harness h = harnesses.get(i);
        if ( h.calculateVisibility() ) {
          pushMatrix();
            //float scaler = sin(frameCount/100.0)*1.5;
            //p = PVector.mult(p,scaler);
            translate(p.x, p.y, p.z);
            PVector polar = ds.cartesianToPolar(p);
            rotateY(polar.y);
            rotateZ(polar.z);
            h.draw3D();
          popMatrix();

          if ( h.hasActivity() ) {
            h.drawActivity( p );
          }
        }
      }
      // Note: The outer sphere *must* be drawn *after* the inner sphere's, or
      // the inner spheres will not be visible, no matter what the alpha value is.
      if ( containerEnabled ) {
        pushStyle();
          fill(
            containerHue,
            containerSaturation,
            containerBrightness,
            containerAlpha
          );
          sphere(containerRadius);
        popStyle();
      }
    popMatrix();
  }
}
