//+------------------------------------------------------------------+
//|                                                  OjectDrawers.mqh|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Drawing objects in the chart                                     |
//| Parameters:                                                      |
//|   date_time - date of the trading day                            |
//|   object_name - name of the object                               |
//|   session_start_time - starting time of the session              |
//|   session_end_time - ending time of the session                  |
//+------------------------------------------------------------------+
void DrawSnipers(
  datetime date_time,
  string object_name,
  string session_start_time,
  string session_end_time,
  color Color,
  const double &High[],
  const double &Low[])
  {

   datetime time_1, time_2;
   double price_1, price_2;
   int bar_1_position, bar_2_position, num_elements ;
   int chart_id = 0;
   string name = object_name;

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_start_time);
   time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_end_time);

   bar_1_position = iBarShift(NULL, 0, time_1);
   bar_2_position   = iBarShift(NULL, 0, time_2);

   num_elements  = bar_1_position - bar_2_position;

   price_1  = High[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_2_position)];
   price_2  = Low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_2_position)];

   if(ObjectFind(chart_id, name) == -1)
  {
   ObjectCreate(chart_id, name, OBJ_RECTANGLE, 0, time_1, price_1, time_2, price_2);
   ObjectSetInteger(chart_id, name, OBJPROP_COLOR, Color);
   ObjectSetInteger(chart_id, name, OBJPROP_FILL, true);
   ObjectSetInteger(chart_id, name, OBJPROP_BACK, false);
   ObjectSetString(chart_id, name, OBJPROP_TOOLTIP, "\n"); 
   ObjectSetInteger(chart_id, name, OBJPROP_BACK, true); 
  }
  }

void DrawSRM(
  datetime date_time,
  string object_name,
  string session_start_time,
  string session_end_time,
  string time_srm_end,       
  color Color,
  const double &High[],
  const double &Low[]
  )
  {
   datetime time_1, time_2, time_3;
   double price_1, price_2;
   int bar_1_position, bar_2_position, num_elements;
   int chart_id = 0;
   string name = object_name;

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_start_time);
   time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_end_time);
   time_3   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time_srm_end);

   bar_1_position = iBarShift(NULL, 0, time_1);
   bar_2_position   = iBarShift(NULL, 0, time_2);

   num_elements  = bar_1_position - bar_2_position;

   price_1  = High[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_2_position)];
   price_2  = Low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_2_position)];
   
    if(ObjectFind(chart_id, name) == -1) 
    {
    double mprice = (price_1 + price_2)/2; // midline price
     ObjectCreate(chart_id, name + "R", OBJ_TREND, 0, time_1, price_1, time_3, price_1); // Range High Resistance
     ObjectSetInteger(chart_id, name + "R", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "R", OBJPROP_STYLE, STYLE_DASHDOT);
     ObjectCreate(chart_id, name + "M", OBJ_TREND, 0, time_1, mprice, time_3, mprice); // Range Middle Support/Resistance
     ObjectSetInteger(chart_id, name + "M", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "M", OBJPROP_STYLE, STYLE_DOT);
     ObjectCreate(chart_id, name + "S", OBJ_TREND, 0, time_1, price_2, time_3, price_2); // Range Low Support
     ObjectSetInteger(chart_id, name + "S", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "S", OBJPROP_STYLE, STYLE_DASHDOT);
    }
  }

//+------------------------------------------------------------------+
void DrawOpenLines(
  datetime date_time,
  string object_name,
  string time1,
  string time2,
  string time3,       
  color Color,
  const double &Open[]
  )
  {
   datetime time_1, time_2, time_3;
   double price_1, price_2;
   int bar_1_position, bar_2_position;
   int chart_id = 0;
   string name = object_name;

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time1);
   time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time2);
   time_3   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time3);

   bar_1_position = iBarShift(NULL, 0, time_1);
   bar_2_position   = iBarShift(NULL, 0, time_2);

   price_1  = iOpen(Symbol(), Period(), bar_1_position);
   price_2  = iOpen(Symbol(), Period(), bar_2_position);
   
  if(ObjectFind(chart_id, name) == -1) 
    {
     ObjectCreate(chart_id, name + "LO", OBJ_TREND, 0, time_1, price_1, time_3, price_1);
     ObjectSetInteger(chart_id, name + "LO", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "LO", OBJPROP_STYLE, STYLE_DASH);
     ObjectCreate(chart_id, name + "NO", OBJ_TREND, 0, time_2, price_2, time_3, price_2);
     ObjectSetInteger(chart_id, name + "NO", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "NO", OBJPROP_STYLE, STYLE_DASH);
    }
  }

//+------------------------------------------------------------------+
void DrawWeeklyOpenLines(
  datetime date_time,
  string object_name,
  string time1,     
  color clr
  )
  {
   datetime time_1, time_2;
   double price_1;
   int bar_1_position;

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time1);
   time_2   = time_1 + 414100;
   // (StringToTime(TimeToString(date_time, TIME_DATE) + " " + "23:59") - time_1) + 327660; //

   bar_1_position = iBarShift(NULL, 0, time_1);
   price_1  = iOpen(Symbol(), Period(), bar_1_position);
   
   if(ObjectFind(0, object_name) == -1) 
     {
       ObjectCreate(0, object_name, OBJ_TREND, 0, time_1, price_1, time_2, price_1);
       ObjectSetInteger(0, object_name, OBJPROP_COLOR, clr);
       ObjectSetInteger(0, object_name, OBJPROP_STYLE, STYLE_DASH);
     }
  }
