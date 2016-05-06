// 0  = hourstamp
// 1  = organization_id
// 2  = environment_id
// 3  = project_id
// 4  = platform_id
// 5  = country

// 6  = events
// 7  = acm_events
// 8  = users
// 9  = acm_users
// 10 = new_users
// 11 = acm_new_users
// 12 = payers
// 13 = acm_payers
// 14 = revenue
// 15 = acm_revenue
// 16 = purchases
// 17 = acm_purchases

HRStat hr;
HRStat[] hours = new HRStat[24]; 

void setup() {
  size( 800, 600, P3D );
  background(0);
  
  int hour;
  for ( hour = 0; hour < 24; hour++ ) {
    String [] lines = loadStrings(String.format("/Users/michael/hourly/gmet-hour-%02d.csv", hour));
    hr = new HRStat( hour );
    hours[hour] = hr;
    for (String line : lines) {
      String[] pieces = split(line, ',');
      hr.events        += int(pieces[6]);
      hr.acm_events    += int(pieces[7]);
      hr.users         += int(pieces[8]);
      hr.acm_users     += int(pieces[9]);
      hr.new_users     += int(pieces[10]);
      hr.acm_new_users += int(pieces[11]);
      hr.payers        += int(pieces[12]);
      hr.acm_payers    += int(pieces[13]);
      hr.revenue       += int(pieces[14]);
      hr.acm_revenue   += int(pieces[15]);
      hr.purchases     += int(pieces[16]);
      hr.acm_purchases += int(pieces[17]);
    }
  }
  
  for ( hour = 0; hour < 24; hour++ ) {
    println( hours[hour].hour, hours[hour].acm_events );
    hours[hour].draw(hours[23].acm_events );
  }
  //println( ghr.events, ghr.users, ghr.revenue/100.00, ghr.payers, ghr.revenue / ghr.payers );
}

class HRStat {
  int hour;
  int events;
  int acm_events;
  int users;
  int acm_users;
  int new_users;
  int acm_new_users;
  int payers;
  int acm_payers;
  int revenue;
  int acm_revenue;
  int purchases;
  int acm_purchases;
  
  float pos_x;
  float pos_y;
  HRStat( int h ) {
    hour = h;
    
    pos_x = ((width / 24) * hour) + ((width / 24) / 2);
    pos_y = height - 5;
  }
  void draw( int max ) {
    float rect_height = ((acm_events / (float)max) * height);
    rect(pos_x, pos_y, 10, -rect_height );
    println( pos_x, pos_y, 10, -rect_height);
  }
};