//+------------------------------------------------------------------+
//|                                                   SniperTimes.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//|                                I Edited the i-sessions indicator |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Secific Times of Action in the Market: Kill Zones"
#property version   "1.00"
#property indicator_chart_window 
#property indicator_buffers 0 
#property indicator_plots   0

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int    NumberOfDays = 2;
input string Box1Begin   ="02:00";
input string Box1End     ="06:00";
input string Box1SRMEnd  ="13:00";
input bool   Box1SRMShow =true;
input color  Box1SRMColor =clrBlue;
input color  Box1Color   =clrLightGray;
input string Box2Begin   ="07:00";
input string Box2End     ="07:15";
input color  Box2Color   =clrDarkGreen;
input string Box3Begin   ="08:00";
input string Box3End     ="08:15";
input color  Box3Color   =clrOlive;
input string Box4Begin   ="13:00";
input string Box4End     ="13:15";
input color  Box4Color   =clrDarkGreen;
input string Box5Begin   ="14:15";
input string Box5End     ="14:30";
input color  Box5Color   =clrOrange;
input string Box6Begin   ="18:00";
input string Box6End     ="19:00";
input color  Box6Color   =clrRed;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
//---- Initialization of variables of data calculation starting point
   min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);

//--- creation of the name to be displayed in a separate sub-window and in a pop up help
   IndicatorSetString(INDICATOR_SHORTNAME,"SessionKillZones");

//--- determination of accuracy of displaying the indicator values
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//---- end of initialization
  }
//+------------------------------------------------------------------+
//| i-Sessions deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
//----
   for(int i = 0; i < NumberOfDays; i++)
     {
      ObjectDelete(0, "Box1" + string(i));
      ObjectDelete(0, "Box1SRM" + string(i));
      ObjectDelete(0, "Box2" + string(i));
      ObjectDelete(0, "Box3" + string(i));
      ObjectDelete(0, "Box4" + string(i));
      ObjectDelete(0, "Box5" + string(i));
      ObjectDelete(0, "Box6" + string(i));
     }
//----
   ChartRedraw(0);
  }
//+------------------------------------------------------------------+ 
//| i-Sessions iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int       rates_total,    // amount of history in bars at the current tick
                const int       prev_calculated,// amount of history in bars at the previous tick
                const datetime  &time[],
                const double    &open[],
                const double    &high[],
                const double    &low[],
                const double    &close[],
                const long      &tick_volume[],
                const long      &volume[],
                const int       &spread[]
                )
  {
//---- checking for the sufficiency of the number of bars for the calculation
   if(rates_total < min_rates_total) return (RESET);

//---- indexing elements in arrays as in timeseries  
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();
   for(int i = 0; i < NumberOfDays; i++)
     {
      DrawSnipers(date_time, "Box1" + string(i), Box1Begin, Box1End, Box1Color, high, low);
      if(Box1SRMShow == true) DrawSRM(date_time, "Box1SRM" + string(i), Box1Begin, Box1End, Box1SRMEnd, Box1SRMColor, high, low);   
      DrawSnipers(date_time, "Box2" + string(i), Box2Begin, Box2End, Box2Color, high, low);
      DrawSnipers(date_time, "Box3" + string(i), Box3Begin, Box3End, Box3Color, high, low);
      DrawSnipers(date_time, "Box4" + string(i), Box4Begin, Box4End, Box4Color, high, low);
      DrawSnipers(date_time, "Box5" + string(i), Box5Begin, Box5End, Box5Color, high, low);
      DrawSnipers(date_time, "Box6" + string(i), Box6Begin, Box6End, Box6Color, high, low);

      date_time = decDateTradeDay(date_time);
      MqlDateTime times;
      TimeToStruct(date_time, times);

      while(times.day_of_week > 5)
        {
         date_time = decDateTradeDay(date_time);
         TimeToStruct(date_time, times);
        }
     }
//----     
   return(rates_total);
  }


//+------------------------------------------------------------------+
//| Drawing objects in the chart                                     |
//| Parameters:                                                      |
//|   date_time - date of the trading day                                   |
//|   object_name - name of the object                                        |
//|   session_start_time - starting time of the session                              |
//|   session_end_time - ending time of the session                                |
//+------------------------------------------------------------------+
void DrawSnipers(
  datetime date_time,
  string object_name,
  string session_start_time,
  string session_end_time,
  color clr,
  const double &High[],
  const double &Low[])
  {

   datetime time_1, time_2;
   double price_1, price_2;
   int bar_1_position, bar_2_position, num_elements ;

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_start_time);
   time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_end_time);

   bar_1_position = iBarShift(NULL, 0, time_1);
   bar_2_position   = iBarShift(NULL, 0, time_2);

   num_elements  = bar_1_position - bar_2_position;

   price_1  = High[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_2_position)];
   price_2  = Low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_2_position)];

   SetRectangle(0, object_name, 0, time_1, price_1, time_2, price_2, clr, false, object_name);
  }

//+------------------------------------------------------------------+
//| Decrease date on one trading day                                 |
//| Parameters:                                                      |
//|   date_time - date of the trading day                                   |
//+------------------------------------------------------------------+
datetime decDateTradeDay(datetime date_time)
  {
//----
   MqlDateTime times;
   TimeToStruct(date_time, times);
   int time_years  = times.year;
   int time_months = times.mon;
   int time_days   = times.day;
   int time_hours  = times.hour;
   int time_mins   = times.min;
//----
   time_days--;
   if(time_days == 0)
     {
      time_months--;

      if(!time_months)
        {
         time_years--;
         time_months = 12;
        }

      if(time_months == 1 || time_months == 3 || time_months == 5 || time_months == 7 || time_months == 8 || time_months == 10 || time_months == 12) time_days = 31;
      if(time_months == 2) if(!MathMod(time_years, 4)) time_days = 29; else time_days = 28;
      if(time_months == 4 || time_months == 6 || time_months == 9 || time_months == 11) time_days = 30;
     }

   string text;
   StringConcatenate(text, time_years, ".", time_months, ".", time_days, " ", time_hours, ":" , time_mins);
//----
   return(StringToTime(text));
  }

//+------------------------------------------------------------------+
//| Creating rectangle object:                                       |
//+------------------------------------------------------------------+
void CreateRectangle
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // time 1
 double   price1,        // price 1
 datetime time2,         // time 2
 double   price2,        // price 2
 color    Color,         // line color
 bool     background,    // line background display
 string   text           // text
 )
//---- 
  {
//----
   ObjectCreate(chart_id, name, OBJ_RECTANGLE, nwin, time1, price1, time2, price2);
   ObjectSetInteger(chart_id, name, OBJPROP_COLOR, Color);
   ObjectSetInteger(chart_id, name, OBJPROP_FILL, true);
   ObjectSetInteger(chart_id, name, OBJPROP_BACK, background);
   ObjectSetString(chart_id, name, OBJPROP_TOOLTIP, "\n"); // tooltip disabling
   ObjectSetInteger(chart_id, name, OBJPROP_BACK, true); // background object
//----
  }
//+------------------------------------------------------------------+
//|  Reinstallation of the rectangle object                          |
//+------------------------------------------------------------------+
void SetRectangle
(
 long     chart_id,      // chart ID
 string   name,          // object name
 int      nwin,          // window index
 datetime time1,         // time 1
 double   price1,        // price 1
 datetime time2,         // time 2
 double   price2,        // price 2
 color    Color,         // line color
 bool     background,    // line background display
 string   text           // text
 )
//---- 
  {
//----
   if(ObjectFind(chart_id, name) == -1) CreateRectangle(chart_id, name, nwin, time1, price1, time2, price2, Color, background, text);
   else
     {
      ObjectMove(chart_id, name, 0, time1, price1);
      ObjectMove(chart_id, name, 1, time2, price2);
     }
//----
  }
//+------------------------------------------------------------------+

void DrawSRM(
  datetime date_time,
  string object_name,
  string session_start_time,
  string session_end_time,
  string time_srm_end,       
  color clr,
  const double &High[],
  const double &Low[]
  )
  {
   datetime time_1, time_2, time_3;
   double price_1, price_2;
   int bar_1_position, bar_2_position, num_elements;

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_start_time);
   time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_end_time);
   time_3   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time_srm_end);

   bar_1_position = iBarShift(NULL, 0, time_1);
   bar_2_position   = iBarShift(NULL, 0, time_2);

   num_elements  = bar_1_position - bar_2_position;

   price_1  = High[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_2_position)];
   price_2  = Low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_2_position)];
   
   SetSRM(0, object_name, 0, time_1, price_1, time_2, price_2, time_3, clr, false, object_name);
  }

  void CreateSRM
  (
   long     chart_id,      // chart ID
   string   name,          // object name
   int      nwin,          // window index
   datetime time1,         // time 1
   double   price1,        // price 1
   datetime time2,         // time 2
   double   price2,        // price 2
   datetime time3,        // box1 srm endtime
   color    Color,         // line color
   bool     background,    // line background display
   string   text           // text
   )
    {
    double mprice = (price1 + price2)/2; // midline price
     ObjectCreate(chart_id, name + "R", OBJ_TREND, nwin, time1, price1, time3, price1); // Range High Resistance
     ObjectSetInteger(chart_id, name + "R", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "R", OBJPROP_STYLE, STYLE_DASHDOT);
     ObjectCreate(chart_id, name + "M", OBJ_TREND, nwin, time1, mprice, time3, mprice); // Range Middle Support/Resistance
     ObjectSetInteger(chart_id, name + "M", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "M", OBJPROP_STYLE, STYLE_DOT);
     ObjectCreate(chart_id, name + "S", OBJ_TREND, nwin, time1, price2, time3, price2); // Range Low Support
     ObjectSetInteger(chart_id, name + "S", OBJPROP_COLOR, Color);
     ObjectSetInteger(chart_id, name + "S", OBJPROP_STYLE, STYLE_DASHDOT);
    }

void SetSRM
    (
     long     chart_id,      // chart ID
     string   name,          // object name
     int      nwin,          // window index
     datetime time1,         // time 1
     double   price1,        // price 1
     datetime time2,         // time 2
     double   price2,        // price 2 
     datetime time3,        // box srm end time
     color    Color,         // line color
     bool     background,    // line background display
     string   text           // text
     )
      {
       if(ObjectFind(chart_id, name) == -1) 
       {
          CreateSRM(chart_id, name, nwin, time1, price1, time2, price2, time3, Color, background, text);
       } 
       else
     {
      ObjectMove(chart_id, name, 0, time1, price1);
      ObjectMove(chart_id, name, 1, time2, price2);
     }
      }