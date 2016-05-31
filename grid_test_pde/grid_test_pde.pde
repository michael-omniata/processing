Creature[][][] grid;
int rows = 20;
int cols = 20;
int curgrid = 0;

void setup() {
  size( 200, 200 );
  background(0);
  
  grid = new Creature[2][rows][cols];
  for ( int i = 0; i < rows; i++ ) {
    for ( int j = 0; j < cols; j++ ) {
      grid[curgrid][i][j] = new Creature( i*10, j*10, 10, 10 );
    }
  }
  curgrid = curgrid ^ 1;
}

void draw() {
  background(0);
  int lastgrid = curgrid ^ 1;
  for (int i = 0; i < rows; i++) {
    for (int j = 0; j < cols; j++) {
      grid[curgrid][i][j] = grid[lastgrid][i][j];
      grid[curgrid][i][j].display();
      grid[curgrid][i][j].age++;
    }
  }
  curgrid = lastgrid;
}

class Creature {
  int  age;
  float x;
  float y;
  float w;
  float h;
  int  neighbors;
  Creature( float _x, float _y, float _h, float _w ) {
    age = 0;
    x = _x;
    y = _y;
    w = _w;
    h = _h;
    neighbors = 0;
  }
  void display() {
    stroke(128);
    fill((age+x+y) % 255);
    rect(x,y,w,h); 
  }
}


  
  