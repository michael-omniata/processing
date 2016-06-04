import org.gicentre.utils.stat.*;    // For chart classes.
Table hourly;
BarChart hourlyChart;
int numRows;
int acm_new_users = 0;
int new_users = 0;
color chartColor;
 
// Initialises the sketch and loads data into the chart.
void setup()
{
  hourly = loadTable("gmet-hour-23.csv", "header, csv");
  numRows = hourly.getRowCount();
  float[] data = new float[2];
  
  size(800,800);
  
  //This aggregates the hourly data
  for(TableRow row : hourly.findRows("41", "organization_id")) {
    new_users += row.getFloat("new_users");
    acm_new_users += row.getFloat("acm_new_users");
 }


 //This is to perform the calculation of whether results are outside margin
 float deltaV = abs(new_users - acm_new_users);
 float average = (new_users + acm_new_users) / 2;
 float difference = (deltaV/average);
 
 //This sets the color if the results are outside the margin of error
 if(difference > 0.1) {
  chartColor = color(255, 0, 0); 
 } else chartColor = color(0,0,255,128);
  data[0] = new_users;
  data[1] = acm_new_users;
  
  //This is all the settings for the chart itself
  hourlyChart = new BarChart(this);
  hourlyChart.showValueAxis(true);
  hourlyChart.showCategoryAxis(true);
  hourlyChart.setMinValue(0);
  hourlyChart.setData(data);
  hourlyChart.setBarLabels(new String[] {"New Users", "Acm New Users"});
  hourlyChart.setBarColour(chartColor);
}
 
// Draws the chart in the sketch
void draw()
{
  background(255);
  hourlyChart.draw(50,50,width-30,height-60); 
}