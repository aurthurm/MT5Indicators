//+------------------------------------------------------------------+
//|                                                  AM_ICT_CBDR.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "ICT Central Banks Dealers Range"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#include "enums.mqh"

#include <ChartObjects/ChartObjectsShapes.mqh>
#include <ChartObjects/ChartObjectsLines.mqh>
CChartObjectTrend line;
CChartObjectRectangle rectangle_ob;

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info_10  =" == + CBDR Range Parameters + == ";
input int    NumberOfDays = 5;
input bool ShowCBDR = true;
input string CBDRStartTime = "20:00";
input CUSTOM_TIMES_CALCS CBDRLength = H06M00; //CBDR Length
input color CBDRBoxColor = clrGreen;
input bool CBDRBoxBG = true;
input color CBDRTextColor = clrGreen;
input int CBDRMaxFavouribleRange = 40;
input color CBDRUnfavouribleColor = clrRed;
input bool   CBDRSDPrediction =false;
input ENUM_ANCHOR_POINT CBDRTextAnchor = ANCHOR_LOWER;


//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_ICT_CBDR");
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   for(int i = 0; i < NumberOfDays; i++)
     {
      ObjectDelete(0, "CBDR" + string(i));
      ObjectDelete(0, "CBDR" + string(i) + " pips");
      for(int n=0; n<20; n++){
        ObjectDelete(0, "CBDR" + string(i) + "SD"  + string(n));
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
  
  ///=============Testing Ideas
  ///=============ENDOF Testing Ideas
  
  
   if(rates_total < min_rates_total) return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();   
      
  if(ShowCBDR) DrawFlout(date_time, "CBDR", NumberOfDays, CBDRStartTime, CBDRLength,  CBDRBoxColor, CBDRBoxBG, CBDRTextColor, CBDRTextAnchor, CBDRMaxFavouribleRange, CBDRUnfavouribleColor, CBDRSDPrediction, high, low);

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
//| DrawFlout: Range Found Between 2 True Days  used to predict next day possible high and low    |
//+----------------------------------------------------------------------------------------------+
void DrawFlout(
  datetime  date_time,
  string obj_name, 
  int days_look_back,
  string startTime, 
  CUSTOM_TIMES_CALCS floutLength,
  color boxColor, 
  bool boxBG,
  color textColor,
  ENUM_ANCHOR_POINT textAnchor,
  int MaxFavouribleRange,
  color unFavourible,
  bool showPredictions,
  const double &High[],
  const double &Low[]
  )
  {
  color favouribleColor = boxColor;
    for(int i = 0; i < days_look_back; i++)
    {
     datetime time_1, time_2;
     double price_high, price_low;
     int bar_1_position, bar_2_position, num_elements ;
     int chart_id = 0;
     string name = obj_name + string(i);
   
     time_1   = StringToTime(TimeToString(date_time , TIME_DATE) + " " + startTime);
     time_2   = time_1 + floutLength;
          
     bar_1_position = iBarShift(NULL, 0, time_1);
     bar_2_position = iBarShift(NULL, 0, time_2);
     num_elements  = bar_1_position - bar_2_position;
     price_high  = High[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_2_position)];
     price_low  = Low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_2_position)];
     double pips = GetPips(price_high, price_low);

      if(pips > MaxFavouribleRange)
      {
         boxColor = unFavourible; 
      } else {
         boxColor = favouribleColor;
      }
       
     int _day = TimeDayOfWeek(date_time);
     if(_day > 0 && _day < 5) {
      rectangle_ob.Create(0, name, 0, time_1, price_high, time_2, price_low);
      rectangle_ob.Color(boxColor);
      if(boxBG == true){
         rectangle_ob.SetInteger(OBJPROP_BACK, false);
         rectangle_ob.SetInteger(OBJPROP_BGCOLOR, boxColor);
         rectangle_ob.SetInteger(OBJPROP_FILL, true);
      }
      ObjectCreate(0, name + " pips", OBJ_TEXT, 0, time_1, price_low);
      ObjectSetString(0, name + " pips", OBJPROP_TEXT, DoubleToString(pips, 2)  + " pips");
      ObjectSetInteger(0, name + " pips", OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(0, name + " pips", OBJPROP_COLOR, boxColor); 
      bool is_flout = false;
      if(StringSubstr(name, 0, 5) == "Flout") is_flout = true;
      if(showPredictions) SD_Predictions(name, time_1, time_2 , price_high, price_low, boxColor, is_flout);
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
//|                                                  OjectDrawers.mqh|
//|                               Copyright © 2019, Aurthur Musendame|
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
