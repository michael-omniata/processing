boolean ringsEnabled = true;

class Ring {
  public float frequency;
  float outside_radius;
  float inside_radius;
  float phase_correction;
  int segments;
  int colorValue;

  boolean sweeping;
  boolean sweep_enabled;
  float sweep_interval;
  float sweep_step, sweep_steps;
  float a, b;

  Ring(float _outside_radius, float _inside_radius, int _segments, int _colorValue, float _frequency ) {
    outside_radius = _outside_radius;
    inside_radius = _inside_radius;
    segments = _segments;
    colorValue = _colorValue;
    frequency = _frequency;
    phase_correction = 0.0;
    sweep_interval = 1; // when changing frequencies, ramp from f1 to f2 in 'sweep_interval' seconds
    sweep_steps = 1000;
    sweep_enabled = false;
  }

  void draw( float targetFrequency ) {
    if ( ringsEnabled == false ) {
      return;
    }
    pushStyle();
      pushMatrix();

        int t = millis();

        fill( colorValue );
        float deltaA=(1.0/(float)segments)*TWO_PI;

        float frequencyDelta = targetFrequency - frequency;
        if ( abs(frequencyDelta) > 0.0 ) { // calculate phase correction 
          float p1 = t * 0.001 * TWO_PI * targetFrequency;
          float p2 = t * 0.001 * TWO_PI * frequency;
          phase_correction = p1 - p2;
          sweeping = true;
          b = log(targetFrequency/frequency) / sweep_interval;
          a = TWO_PI * frequency / b;
          sweep_step = 0;
        }
        if ( sweep_enabled ) {
          if ( sweeping ) {
            float delta = sweep_step/sweep_steps;
            sweep_step++;
            float it = sweep_interval * delta;
            frequency = a * exp(b * it);
            if ( sweep_step >= sweep_steps ) {
              sweeping = false;
              frequency = targetFrequency;
            }
          } else {
            frequency = targetFrequency;
          }
        } else {
          frequency = targetFrequency;
        }
        float phase = (t * 0.001 * TWO_PI * frequency) - phase_correction;

        rotateX( phase );
        beginShape(QUADS);
        for( int i = 0; i < segments; i++ ) {
          vertex(outside_radius*cos(i*deltaA),outside_radius*sin(i*deltaA));
          vertex(inside_radius*cos(i*deltaA),inside_radius*sin(i*deltaA));
          vertex(inside_radius*cos((i+1)*deltaA),inside_radius*sin((i+1)*deltaA));
          vertex(outside_radius*cos((i+1)*deltaA),outside_radius*sin((i+1)*deltaA));
        }
        endShape();
      popMatrix();
    popStyle();
  } 
}
