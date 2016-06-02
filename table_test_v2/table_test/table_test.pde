import org.gicentre.utils.stat.*;    // For chart classes.
Table hourly;
BarChart hourlyChart;
int numRows;
 
// Initialises the sketch and loads data into the chart.
void setup()
{
  hourly = loadTable("gmet-hour-23.csv", "header, csv");
  numRows = hourly.getRowCount();
  float[] data = new float[numRows];
  size(500,500);
  for(int i = 0; i < numRows; i++) {
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