import controlP5.*;

import org.gicentre.utils.stat.*;    // For chart classes.
Table[] hourly = new Table[24]; 
String[] hours = new String[24];
BarChart hourlyChart;
int numRows;
int acm_events;
color chartColor = color(63, 127, 255, 128);
ControlP5 cp5;
float[] data;
RadioButton r1;
String[] measures = {
  "events", "acm_events",
  "users", "acm_users",
  "new_users", "acm_new_users",
  "revenue", "acm_revenue"
};

// Initialises the sketch and loads data into the chart.
void setup()
{
  size(1000, 1000);

  cp5 = new ControlP5(this);
  r1 = cp5.addRadioButton("radioButton")
    .setPosition(0, 0)
    .setSize(50, 40)
    .setColorForeground(color(120))
    .setColorActive(color(255))
    .setColorLabel(color(255))
    .setItemsPerRow(10)
    .setSpacingColumn(75)
    ;
    
  for ( int i = 0; i < measures.length; i++ ) {
    r1.addItem( measures[i], i );
  }

  for (Toggle t : r1.getItems()) {
    t.getCaptionLabel().setColorBackground(color(255, 80));
    t.getCaptionLabel().getStyle().moveMargin(-7, 0, 0, -3);
    t.getCaptionLabel().getStyle().movePadding(7, 0, 0, 3);
    t.getCaptionLabel().getStyle().backgroundWidth = 70;
    t.getCaptionLabel().getStyle().backgroundHeight = 13;
  }

  data = populate( 41, "users" );

  //These are all the settings for the chart
  for (int i = 0; i < 24; i++) {
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

void controlEvent(ControlEvent theEvent) {
  if(theEvent.isFrom(r1)) {
    print("got an event from "+theEvent.getName()+"\t");
    for(int i=0;i<theEvent.getGroup().getArrayValue().length;i++) {
      print(int(theEvent.getGroup().getArrayValue()[i]));
    }
    int measure_idx = (int)theEvent.getValue();
    println("\t "+theEvent.getValue());
    data = populate( 41, measures[measure_idx] );
    hourlyChart.setData(data);
    /* populate() */
  }
}

void radioButton(int a) {
  println("a radio Button event: "+a);
}

float[] populate(int org_id, String measure ) {
  float[] data = new float[24];
  float measure_value;
  for (int i = 0; i < 24; i++) {
    measure_value = 0;
    String filename = "gmet-hour-" + nf(i, 2) + ".csv";
    try {
      hourly[i] = loadTable(filename, "header");
      //This aggregates the hourly data
      for (TableRow row : hourly[i].findRows(str(org_id), "organization_id")) {
        measure_value += row.getFloat(measure);
      }
      data[i] = measure_value;
    } catch (Exception e) {
      print( "Couldn't open "+filename );
      data[i] = 0;
    }
  }
  return data;
}

// Draws the chart in the sketch
void draw()
{
  background(color(0,0,0));
  hourlyChart.draw(100, 50, width-150, height-100);
}