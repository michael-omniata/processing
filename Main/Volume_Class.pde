//Volume has bricks assigned to it from different nodes

class Volume {
  String name;
  int xPos, yPos;
  float usage, capacity;
  ArrayList<Brick> bricks;

  Volume(ArrayList<Brick> brickArray) {
    bricks = brickArray;
    usage = 0;
    capacity = 0;
    capacity = this.getCapacity();
  }

  void setName(String newName) {
    name = newName;
  }

  String getName() {
    return name;
  }

  float getCapacity() { //This sets every time a change is made to capacity
    for (int i = 0; i < bricks.size(); i++) {
      Brick temp = bricks.get(i);
      capacity += temp.getCapacity();
    } 
    return capacity;
  }

  float getUsage() {
    for (int i = 0; i < bricks.size(); i++) {
      Brick temp = bricks.get(i);
      usage += temp.getUsage();
    } 
    return (usage/capacity);
  }
}