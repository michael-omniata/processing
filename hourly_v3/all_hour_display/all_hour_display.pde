import org.gicentre.utils.stat.*;    // For chart classes.
Table[] hourly = new Table[24]; 
String[] hours = new String[24];
BarChart hourlyChart;
int numRows;
int acm_events;
color chartColor = color(0,0,255,128);
 
// Initialises the sketch and loads data into the chart.
void setup()
{
  float[] data = new float[24];
  for(int i = 0; i < 24; i++) {
   acm_events = 0;
   String filename = "gmet-hour-" + nf(i, 2) + ".csv";
   hourly[i] = loadTable(filename, "header, csv");
   
   //This aggregates the hourly data
    for(TableRow row : hourly[i].findRows("41", "organization_id")) {
    acm_events += row.getFloat("acm_events");
   }
   data[i] = acm_events;
 }
  
  
  
  size(800,800);
  
  //These are all the settings for the chart
  for(int i = 0; i < 24; i++) {
   hours[i] = nf(i, 2); 
  }
  hourlyChart = new BarChart(this);
  hourlyChart.showValueAxis(true);
  hourlyChart.showCategoryAxis(true);
  hourlyChart.setMinValue(0);
  hourlyChart.setData(data);
  hourlyChart.setBarLabels(hours);
  hourlyChart.setBarColour(chartColor);
}
 
// Draws the chart in the sketch
void draw()
{
  background(255);
  hourlyChart.draw(50,50,width-30,height-60); 
}