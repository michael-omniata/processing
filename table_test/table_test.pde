import org.gicentre.utils.stat.*;    // For chart classes.
Table hourly;
BarChart hourlyChart;
 
// Initialises the sketch and loads data into the chart.
void setup()
{
  float[] data = new float[5];
  hourly = loadTable("gmet-hour-00.csv");
  size(500,500);
  for(int i = 0; i < 5; i++) {
    data[i] = hourly.getFloat(i, 1);
 }
  
  hourlyChart = new BarChart(this);
  hourlyChart.showValueAxis(true);
  hourlyChart.setData(data);
}
 
// Draws the chart in the sketch
void draw()
{
  background(255);
  hourlyChart.draw(15,15,width-30,height-30); 
}