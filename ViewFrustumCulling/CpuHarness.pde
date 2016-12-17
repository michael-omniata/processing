//the cpu harness contains the attributes for visual representation of a cpu

HashMap cpuHarnesses = new HashMap();
CpuHarness CpuHarness_findOrCreate( String nodeName, String ID ) {
  String cpuID = nodeName+':'+ID;
  CpuHarness ch = (CpuHarness)cpuHarnesses.get( cpuID );
  if ( ch == null ) {
    ch = new CpuHarness( nodeName, cpuID );
    cpuHarnesses.put( cpuID, ch );
  }
  return ch;
}

class CpuHarness extends Harness {
  int DEFAULT_RADIUS = 5;
  public Cpu cpu;
  public NodeHarness nodeHarnessContainer;
  float radius;

  CpuHarness( String nodeName, String ID ) {
    super();
    radius = DEFAULT_RADIUS;

    nodeHarnessContainer = NodeHarness_findOrCreate( nodeName );
    cpu = Cpu_findOrCreate( nodeName, ID );
  }

  float calculateHue() {
    return (100-(100.0-cpu.idle));
  }
  float calculateBrightness() {
    return( 100 - cpu.iowait );
  }
  float calculateSaturation() {
    return 100;
  }
  float calculateRadius() {
    //return(radius * (1 + (cpu.iowait/100.0)));
    return( radius );
  }
}