//the HarnessGroup class contains and defines the shape of a group of other harnesses, like bricks or nodes

class HarnessGroup extends Harness {
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
  public boolean rotationZEnabled;
  public float rotationXAngle;
  public float rotationYAngle;
  public float rotationZAngle;
  public float rotationXSpeed;
  public float rotationYSpeed;
  public float rotationZSpeed;
  public float xOffset;
  public float yOffset;
  public float zOffset;

  boolean reLayoutRequired = false;

  String layout;
  ArrayList<PVector> vectors;
  float radius;
  float radiusOfNode;
  float resolution, spacing, increment;
  int xstep, ystep, cols;
  float xPos, yPos, zPos;
  float offset_from_poles;
  float min_radius, max_radius;
  float zIncrement;
  int  numItems;
  DawesomeToolkit ds;

  HarnessGroup( PApplet app, float _xPos, float _yPos, float _zPos, float _xOffset, float _yOffset, float _zOffset ) {
    ds = new DawesomeToolkit( app );
    this.harnesses = new ArrayList<Harness>();
    xPos = _xPos;
    yPos = _yPos;
    zPos = _zPos;
    xOffset = _xOffset;
    yOffset = _yOffset;
    zOffset = _zOffset;
    rotationXEnabled = false;
    rotationYEnabled = false;
    rotationZEnabled = false;
    rotationXAngle = 180;
    rotationYAngle = 180;
    rotationZAngle = 180;
    rotationXSpeed = 0.01;
    rotationYSpeed = 0.01;
    rotationZSpeed = 0.01;
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
  void setRotationAnglesAndSpeeds( float _xDegrees, float _yDegrees, float _zDegrees, float _xSpeed, float _ySpeed, float _zSpeed ) {
    rotationXAngle = _xDegrees;
    rotationYAngle = _yDegrees;
    rotationZAngle = _zDegrees;
    rotationXSpeed = _xSpeed;
    rotationYSpeed = _ySpeed;
    rotationZSpeed = _zSpeed;
    rotationXEnabled = (_xSpeed > 0);
    rotationYEnabled = (_ySpeed > 0);
    rotationZEnabled = (_zSpeed > 0);
  }
  void stopXRotation()  { rotationXEnabled = false; }
  void startXRotation() { rotationXEnabled = true; }
  void stopYRotation()  { rotationYEnabled = false; }
  void startYRotation() { rotationYEnabled = true; }
  void stopZRotation()  { rotationZEnabled = false; }
  void startZRotation() { rotationZEnabled = true; }

  void setXRotationAngle( float _angle ) {
    rotationXAngle = _angle;
  }
  void setYRotationAngle( float _angle ) {
    rotationYAngle = _angle;
  }
  void setZRotationAngle( float _angle ) {
    rotationZAngle = _angle;
  }
  void setXRotationSpeed( float _speed ) {
    rotationXSpeed = _speed;
    rotationXEnabled = (_speed > 0);
  }
  void setYRotationSpeed( float _speed ) {
    rotationYSpeed = _speed;
    rotationYEnabled = (_speed > 0);
  }
  void setZRotationSpeed( float _speed ) {
    rotationZSpeed = _speed;
    rotationZEnabled = (_speed > 0);
  }

  void spiralLayout( float _radius, float _resolution, float _spacing, float _increment ) {
    layout = "spiral";
    radius = _radius;
    resolution = _resolution;
    spacing = _spacing;
    increment = _increment;
    vectors = ds.spiralLayout( this.harnesses.size(), (int)radius, resolution, spacing, increment );
  }
  void vogelLayout( float _radiusOfNode ) {
    layout = "vogel";
    radiusOfNode = _radiusOfNode;
    vectors = ds.vogelLayout( this.harnesses.size(), (int)radiusOfNode );
  }
  void helixLayout( float _zIncrement, float _increment, int _numItems, float _radius ) {
    layout = "helix";
    zIncrement = _zIncrement;
    increment  = _increment;
    numItems   = _numItems;
    radius     = _radius;
    vectors    = helix( zIncrement, increment, numItems, radius );
  }
  void fibonacciSphereLayout( float _radius ) {
    layout = "fibonacciSphere";
    radius = _radius;
    vectors = ds.fibonacciSphereLayout( this.harnesses.size(), radius );
  }
  void concentricSphereLayout( float _min_radius, float _max_radius ) {
    layout = "concentric";
    min_radius = _min_radius;
    max_radius = _max_radius;
    float cur_radius = min_radius;

    if ( this.harnesses.size() > 0 ) {
      float interval = (max_radius - min_radius) / this.harnesses.size();
      for ( int i = 0; i < this.harnesses.size(); i++ ) {
        Harness h = this.harnesses.get(i);
        h.radius = cur_radius;
        cur_radius += interval;
      }
    }
  }

  void circularLayout( float _radius ) {
    layout = "circular";
    radius = _radius;
    vectors = ds.circularLayout( this.harnesses.size(), radius );
  }
  void gridLayout( int _xstep, int _ystep, int _cols ) {
    layout = "grid";
    xstep = _xstep;
    ystep = _ystep;
    cols  = _cols;
    vectors = ds.gridLayout( this.harnesses.size(), _xstep, _ystep, _cols );
  }
  void mapGridAroundSphere( float radius, float _offset_from_poles ) {
    layout = "sphere";
    offset_from_poles = _offset_from_poles;
    vectors = ds.mapPVectorsAroundSphere(vectors,radius,_offset_from_poles);
  }
  void reLayout() {
    if ( layout.equals("fibonacciSphere") ) {
      fibonacciSphereLayout( radius );
    } else if ( layout.equals("helix") ) {
      helixLayout( zIncrement, increment, numItems, radius );
    } else if ( layout.equals("concentric") ) {
      concentricSphereLayout( min_radius, max_radius );
    } else if ( layout.equals("circular") ) {
      circularLayout( radius );
    } else if ( layout.equals("grid") ) {
      gridLayout( xstep, ystep, cols );
    } else if ( layout.equals("sphere") ) {
      gridLayout( xstep, ystep, cols );
      mapGridAroundSphere( radius, offset_from_poles );
    } else if ( layout.equals("vogel") ) {
      vogelLayout( radiusOfNode );
    } else if ( layout.equals("spiral") ) {
      spiralLayout( radius, resolution, spacing, increment );
    }
    reLayoutRequired = false;
  }
  void addHarness( Harness h ) {
    this.harnesses.add( h );  // add to local list
    globalHarnesses.add( h ); // add to global list
    reLayoutRequired = true;
  }
  void removeHarness( Harness h ) {
    // remove from harness group list
    for ( int i = 0; i < this.harnesses.size(); i++ ) {
      if ( this.harnesses.get(i) == h ) {
        this.harnesses.remove(i);
        reLayoutRequired = true;
        break;
      }
    }
    // remove from global list too
    for ( int i = 0; i < globalHarnesses.size(); i++ ) {
      if ( globalHarnesses.get(i) == h ) {
        globalHarnesses.remove(i);
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


if ( !freezeEverything ) {
      if ( rotationXEnabled ) {
        float xRot = radians(rotationXAngle -  millis()*rotationXSpeed);
        rotateX( xRot ); 
      }
      if ( rotationYEnabled ) {
        float yRot = radians(rotationYAngle -  millis()*rotationYSpeed);
        rotateY( yRot ); 
      }
      if ( rotationZEnabled ) {
        float zRot = radians(rotationZAngle -  millis()*rotationZSpeed);
        rotateZ( zRot ); 
      }
}

      for (Harness h : this.harnesses) {
        h.preTransform();
      }
      if ( clicked ) {
        if ( isClickable ) {
          pushMatrix();
            selectedShape = Shape3D.pickShape(app, mouseX, mouseY);
            if ( selectedShape != null ) {
              println( "Selected shape at "+mouseX+","+mouseY );
            } else {
              println( "Nothing at "+mouseX+","+mouseY );
            }
          popMatrix();
        }
        clicked = false;
      }

      if ( vectors == null ) {
        for (int i = 0; i < this.harnesses.size(); i++) {
          Harness h = this.harnesses.get(i);
          h.draw3D();
        }
      } else {
        // note: if there are more harnesses than vectors, they will be omitted!
        for (int i = 0; i < min(vectors.size(),this.harnesses.size()); i++) {
          PVector p = vectors.get(i);
          Harness h = this.harnesses.get(i);
          if ( h.calculateVisibility() ) {
            pushMatrix();
              //float scaler = sin(frameCount/100.0)*1.5;
              //p = PVector.mult(p,scaler);
              if ( isClickable ) {
                //h.shape.moveTo(p);
                h.shape.moveTo(p.x + xOffset, p.y + yOffset, p.z + zOffset);
              } else {
                translate(p.x + xOffset, p.y + yOffset, p.z + zOffset);
              }
              h.pvector = p;
              h.draw3D();

            popMatrix();

            if ( h.hasActivity() ) {
              h.drawActivity( p );
            }
          }
        }
      }
      // Note: The outer sphere *must* be drawn *after* the inner sphere's, or
      // the inner spheres will not be visible, no matter what the alpha value is.
      if ( containerEnabled ) {
        /*
        pushMatrix();
        pushStyle();
          fill(
            containerHue,
            containerSaturation,
            containerBrightness,
            containerAlpha
          );
          translate(xOffset, yOffset, zOffset);
          sphere(containerRadius);
        popStyle();
        popMatrix();
        */
      }
    popMatrix();
  }
}