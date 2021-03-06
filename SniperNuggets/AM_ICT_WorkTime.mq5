//+------------------------------------------------------------------+
//|                                               AM_ICT_WorkTime.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "ICT Session Specific Boxe Highlihter"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#include <ChartObjects/ChartObjectsLines.mqh>
CChartObjectTrend line;

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == Look Back Days == ";
input int    NumberOfDays = 5;
input bool   AsiaBoxShow = true;
input string AsiaBegin   ="02:00";
input string AsiaEnd     ="06:00";
input string AsiaSRMEnd  ="13:00";
input bool   AsiaSRMShow =true;
input color  AsiaSRMColor =clrBlue;
input color  AsiaColor   =clrLightGray;
input int AsiaMaxFavouribleRange = 40;
input color AsiaUnfavouribleColor = clrRed;
input bool   AsiaSDPrediction =false;
input bool   LondonOpenBoxShow = false;
input string LondonOpenBegin   ="07:00";
input string LondonOpenEnd     ="07:15";
input color  LondonOpenColor   =clrDarkGreen;
input bool   MProtractionBoxShow = false;
input string MProtractionBegin   ="08:00";
input string MProtractionEnd     ="08:15";
input color  MProtractionColor   =clrOlive;
input bool   NewYorkBoxShow = false;
input string NewYorkBegin   ="13:00";
input string NewYorkEnd     ="13:15";
input color  NewYorkColor   =clrDarkGreen;
input bool   CMEOpenBoxShow = false;
input string CMEOpenBegin   ="14:15";
input string CMEOpenEnd     ="14:30";
input color  CMEOpenColor   =clrOrange;
input bool   LondonCloseBoxShow = false;
input string LondonCloseBegin   ="18:00";
input string LondonCloseEnd     ="19:00";
input color  LondonCloseColor   =clrRed;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME, "SessionKillZones");
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   for(int i = 0; i < NumberOfDays; i++)
     {
      ObjectDelete(0, "Asia" + string(i));
      ObjectDelete(0, "Asia" + string(i) + " pips");
      ObjectDelete(0, "AsiaSRM" + string(i) + "R");
      ObjectDelete(0, "AsiaSRM" + string(i) + "M");
      ObjectDelete(0, "AsiaSRM" + string(i) + "S");
      ObjectDelete(0, "SessionOpen" + string(i) + "LO");
      ObjectDelete(0, "SessionOpen" + string(i) + "NO");
      ObjectDelete(0, "SessionOpen" + string(i) + "ZG");
      ObjectDelete(0, "London" + string(i));
      ObjectDelete(0, "MProtraction" + string(i));
      ObjectDelete(0, "NewYork" + string(i));
      ObjectDelete(0, "CMEOpen" + string(i));
      ObjectDelete(0, "LondonClose" + string(i));
      for(int n=0; n<20; n++){
        ObjectDelete(0, "Asia" + string(i) + "SD"  + string(n));
      }
     }
    Comment("");

   ChartRedraw(0);
  }

//+------------------------------------------------------------------+ 
//| iteration function                                    | 
//+------------------------------------------------------------------+ 
int OnCalculate(
                const int       rates_total,
                const int       prev_calculated,
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
  
   if(rates_total < min_rates_total) return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();   
      
    if(AsiaBoxShow) DrawSnipers(date_time, "Asia", NumberOfDays, AsiaBegin, AsiaEnd, AsiaColor, AsiaMaxFavouribleRange,  AsiaUnfavouribleColor, AsiaSDPrediction, high, low);
    if(AsiaSRMShow) DrawSRM(date_time, "AsiaSRM", NumberOfDays, AsiaBegin, AsiaEnd, AsiaSRMEnd, AsiaSRMColor, high, low);  
    if(LondonOpenBoxShow) DrawSnipers(date_time, "London", NumberOfDays, LondonOpenBegin, LondonOpenEnd, LondonOpenColor, 10000, LondonOpenColor, false, high, low);
    if(MProtractionBoxShow) DrawSnipers(date_time, "MProtraction", NumberOfDays, MProtractionBegin, MProtractionEnd, MProtractionColor, 10000, MProtractionColor, false, high, low);
    if(NewYorkBoxShow) DrawSnipers(date_time, "NewYork", NumberOfDays, NewYorkBegin, NewYorkEnd, NewYorkColor, 10000, NewYorkColor, false, high, low);
    if(CMEOpenBoxShow) DrawSnipers(date_time, "CMEOpen", NumberOfDays, CMEOpenBegin, CMEOpenEnd, CMEOpenColor, 10000, CMEOpenColor, false, high, low);
    if(LondonCloseBoxShow) DrawSnipers(date_time, "LondonClose", NumberOfDays, LondonCloseBegin, LondonCloseEnd, LondonCloseColor, 10000, LondonOpenColor, false, high, low);

   return(rates_total);
  } //+------------------------------------------ END ITERATION FUNCTION

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---
 }
 
//+----------------------------------------------------------------------------------------------+
//| SD_Predictions: Predict Standard Deviation for possible HOD LOD                              |
//+----------------------------------------------------------------------------------------------+

void SD_Predictions(string name, 
  datetime start_time, 
  datetime end_time , 
  double price_high, 
  double price_low, 
  color Color, 
  bool flout_)
{
  double _range, predicted_sds[20];
  _range = price_high - price_low;
  if(flout_) _range = _range/2;
  predicted_sds[0] = price_high + _range*1;
  predicted_sds[1] = price_high + _range*2;
  predicted_sds[2] = price_high + _range*3;
  predicted_sds[3] = price_high + _range*4;
  predicted_sds[4] = price_high + _range*5;
  predicted_sds[5] = price_high + _range*6;
  predicted_sds[6] = price_high + _range*7;
  predicted_sds[7] = price_high + _range*8;
  predicted_sds[8] = price_high + _range*9;
  predicted_sds[9] = price_high + _range*10;
  predicted_sds[10] = price_low - _range*1;
  predicted_sds[11] = price_low - _range*2;
  predicted_sds[12] = price_low - _range*3;
  predicted_sds[13] = price_low - _range*4;
  predicted_sds[14] = price_low - _range*5;
  predicted_sds[15] = price_low - _range*6;
  predicted_sds[16] = price_low - _range*7;
  predicted_sds[17] = price_low - _range*8;
  predicted_sds[18] = price_low - _range*9;
  predicted_sds[19] = price_low - _range*10;
  for(int i=0; i<20; i++){ 
   line.Create(0, name + "SD"  + string(i), 0, start_time, predicted_sds[i], end_time, predicted_sds[i]);
   line.Color(Color);
  }
}


//+------------------------------------------------------------------+
//| DrawSnipers: Draws Sessions as Boxes                             |
//+------------------------------------------------------------------+

void DrawSnipers(
  datetime date_time,
  string object_name,
  int days_look_back,
  string session_start_time,
  string session_end_time,
  color Color,
  int FavouribleRange,  
  color UnfavouribleColor,
  bool showPredictions,
  const double &High[],
  const double &Low[])
  {
    color favouribleColor = Color;
    datetime time_1, time_2;
    double price_1, price_2;
    int bar_1_position, bar_2_position, num_elements ;
    int chart_id = 0;
    
    for(int i = 0; i < days_look_back; i++)
    {
       
       string name = object_name + string(i);

       time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_start_time);
       time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + session_end_time);

       bar_1_position = iBarShift(NULL, 0, time_1);
       bar_2_position   = iBarShift(NULL, 0, time_2);

       num_elements  = bar_1_position - bar_2_position;

       price_1  = High[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_2_position)];
       price_2  = Low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_2_position)];
       double pips = GetPips(price_1, price_2);
       
       if(pips > FavouribleRange) 
       {
         Color = UnfavouribleColor; 
       } else {
         Color = favouribleColor;
       }
       
       int this_day  = TimeDayOfWeek(date_time);

       if(ObjectFind(chart_id, name) == -1)
      {
       ObjectCreate(chart_id, name, OBJ_RECTANGLE, 0, time_1, price_1, time_2, price_2);
       ObjectSetInteger(chart_id, name, OBJPROP_COLOR, Color);
       ObjectSetInteger(chart_id, name, OBJPROP_FILL, true);
       ObjectSetInteger(chart_id, name, OBJPROP_BACK, false);
       ObjectSetInteger(chart_id, name, OBJPROP_BACK, true); 
       ObjectSetString(chart_id, name,OBJPROP_TOOLTIP  , (string) pips);
       if (StringSubstr(name, 0, 4) == "Asia" && this_day != 0 && this_day != 6){
          ObjectCreate(chart_id, name + " pips", OBJ_TEXT, 0, time_1, price_2);
          ObjectSetString(chart_id, name + " pips", OBJPROP_TEXT, DoubleToString(GetPips(price_1, price_2),2) + " pips");
          ObjectSetInteger(chart_id, name + " pips", OBJPROP_FONTSIZE, 8);
          ObjectSetInteger(chart_id, name + " pips", OBJPROP_COLOR, Color);
          if(showPredictions) SD_Predictions(name, time_1, time_2 , price_1, price_2, Color, false);
       } 
      } 
      date_time = decDateTradeDay(date_time);        
      MqlDateTime times;
      TimeToStruct(date_time, times);

      while(times.day_of_week > 5)
      {
      date_time = decDateTradeDay(date_time);
      TimeToStruct(date_time, times);
      } 
    }
  }

//+------------------------------------------------------------------+
//| DrawSRM: Draws Asian Session Support, Resistance and Midline     |
//+------------------------------------------------------------------+
void DrawSRM(
  datetime date_time,
  string object_name,
  int days_look_back,
  string session_start_time,
  string session_end_time,
  string time_srm_end,       
  color Color,
  const double &High[],
  const double &Low[]
  )
  {
    for(int i = 0; i < days_look_back; i++)
    {
   datetime time_1, time_2, time_3;
   double price_1, price_2;
   int bar_1_position, bar_2_position, num_elements;
   int chart_id = 0;
   string name = object_name + string(i);

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
    date_time = decDateTradeDay(date_time);        
    MqlDateTime times;
    TimeToStruct(date_time, times);

    while(times.day_of_week > 5)
    {
    date_time = decDateTradeDay(date_time);
    TimeToStruct(date_time, times);
    } 
  }
  }

//+------------------------------------------------------------------+
int TimeDayOfWeek(datetime date)
  {
    MqlDateTime tm;
    TimeToStruct(date,tm);
    return(tm.day_of_week);
  }    

//+------------------------------------------------------------------+
double GetPips(double price_high, double price_low) 
  {
    return MathRound((MathAbs( price_high - price_low)/Point()))/10.0;
  }


//+------------------------------------------------------------------+
datetime decDateTradeDay(datetime date_time)
  {
   MqlDateTime times;
   TimeToStruct(date_time, times);
   int time_years  = times.year;
   int time_months = times.mon;
   int time_days   = times.day;
   int time_hours  = times.hour;
   int time_mins   = times.min;

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
   return(StringToTime(text));
  }
//+------------------------------------------------------------------+