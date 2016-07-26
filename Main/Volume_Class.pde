//Volume has bricks assigned to it from different nodes

class Volume {
  String name;
  boolean status;
  float usage, capacity;
  ArrayList<Brick> bricks;

  Volume( String _name ) {
    name = _name;
    bricks = new ArrayList<Brick>();
    capacity = this.getCapacity();
  }

  void setName(String newName) {
    name = newName;
  }

  String getName() {
    return name;
  }
  void addBrick( Brick _brick ) {
    bricks.add( _brick );
  }

  float getCapacity() { //This sets every time a change is made to capacity
    capacity = 0;
    println( "checking "+bricks.size()+" bricks" );
    for (int i = 0; i < bricks.size(); i++) {
      Brick temp = bricks.get(i);
      println( "brick "+i+" capacity is "+temp.getCapacity() );
      capacity += temp.getCapacity();
    }
    println( "Volume capacity is "+capacity );
    return capacity;
  }

  float getUsage() {
    usage = 0;
    if ( capacity == 0 ) return 0;
    for (int i = 0; i < bricks.size(); i++) {
      Brick temp = bricks.get(i);
      usage += temp.getUsage();
    }
    usage /= bricks.size();
    return (100*(usage/100*capacity)/capacity);
  }
}