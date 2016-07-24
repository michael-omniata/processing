//The Brick class, contains the status, capacity, usage, and name of a brick

class Brick {
  boolean status;
  float capacity;
  int usage;
  String deviceName;

  Brick (float cap, int use, boolean state) {
    capacity = cap;
    usage = use;
    status = state;
  }
  void update() {
    // this might be used to periodically get the *actual* status of the brick
  }
  void setDeviceName( String _deviceName ) {
    println( "Brick setting device name to "+_deviceName );
    deviceName = _deviceName;
  }
  String getDeviceName() {
    return deviceName;
  }
  void setStatus(boolean update) { 
    status = update;
  }
  boolean getStatus() { 
    return status;
  }
  void setCapacity(float newCap) {
    capacity = newCap;
  }
  float getCapacity() {
    return capacity;
  }
  void setUsage(int newUsage) { 
    usage = newUsage;
  }
  int getUsage() {
    return usage;
  }
}