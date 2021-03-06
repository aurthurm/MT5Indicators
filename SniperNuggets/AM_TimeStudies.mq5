//+------------------------------------------------------------------+
//|                                                  AM_TimeStudies.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Highs and Lows Price Time Studies"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#include "enums.mqh"

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == + Time Study Parameters  + == ";
int    NumberOfDays = 10;
input bool ShowTimeStudies = true;
input TIMEPRICE_CANDLES timePriceCandles = TWO;
input color timesColor = clrBlue;


//+-----------------------------------+

// data starting point
int min_rates_total;
int lookback;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    lookback = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME, "AM_TimeStudies");
    IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   for(int i = 0; i < lookback; i++)
     {
      ObjectDelete(0, "TimeS" + string(i) + "-High");
      ObjectDelete(0, "TimeS" + string(i) + "-Low");
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

    // if(rates_total < min_rates_total) return (RESET);
    if(rates_total < timePriceCandles*2 + 1) return(0);

    int start;

    //--- clean up arrays
    if(prev_calculated < (timePriceCandles*2 + 1) + timePriceCandles)
      start = timePriceCandles;
    else
      start = rates_total - (timePriceCandles*2 + 1); 

    datetime date_time = TimeCurrent();

    // Comment("Rates total = " +  (string)rates_total + "  Rates min = " + (string)min_rates_total + "  start = " + (string)start);

    if(ShowTimeStudies) PriceTimeStudies(date_time, "TimeS", start, rates_total, timesColor, timePriceCandles , high, low, time);

    return(rates_total);
  } 
//+------------------------------------------ END ITERATION FUNCTION

 
//+----------------------------------------------------------------------------------------------+
//| PriceTimeStudies:                                                                            |
//+----------------------------------------------------------------------------------------------+
void PriceTimeStudies(
  datetime  date_time,
  string obj_name, 
  int start,
  int look_back,
  color timeColor, 
  TIMEPRICE_CANDLES candleCount,
  const double &high[],
  const double &low[],
  const datetime  &time[]
  )
  {

    datetime time_1;
    double price_high, price_low;
    int chart_id = 0;
    string nameHigh, nameLow, time_show;


    for(int i = start; i < look_back - candleCount + 2 && !IsStopped(); i++)
    {
      // Set names
      nameHigh = obj_name + (string)i + "-High";
      nameLow  = obj_name + (string)i + "-Low";
      // get candle i time, etract sub string HH:MM
      time_1    = iTime(NULL, 0, i); // time[i] is giving an error
      time_show = StringSubstr((string)time_1, 10, 20);
      // get candle high and low
      price_high = iHigh(NULL, 0, i);
      price_low  = iLow(NULL, 0, i);

      //
      if (candleCount == 1) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>=high[i-1])
          {
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<=low[i-1])
          {
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          }
      } 

      if (candleCount == 2) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>=high[i-1] && high[i]>=high[i-2])
          {
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<=low[i-1] && low[i]<=low[i-2])
          {
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          }
      } 

      if (candleCount == 3) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3])
          {
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3])
          {
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          }
      } 

      if (candleCount == 4) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>high[i+4] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3] && high[i]>=high[i-4])
          {
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<low[i+4] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3] && low[i]<=low[i-4])
          {
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          }
      } 

      if (candleCount == 5) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>high[i+4] && high[i]>high[i+5] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3] && high[i]>=high[i-4] && high[i]>=high[i-5])
          {
            plotTimes(chart_id, nameHigh, time_1, time_show, price_high, timeColor);
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<low[i+4] && low[i]<low[i+5] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3] && low[i]<=low[i-4] && low[i]<=low[i-5])
          {
            plotTimes(chart_id, nameLow, time_1, time_show, price_low, timeColor);
          }
      } 
      //

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


void plotTimes(int obj_id, string obj_name, datetime obj_time, string obj_txt, double obj_price, color obj_clr){
  if(ObjectFind(obj_id, obj_name) == -1)
    {
        ObjectCreate(obj_id, obj_name, OBJ_TEXT, 0, obj_time, obj_price);
        ObjectSetString(obj_id, obj_name, OBJPROP_TEXT, obj_txt);
        ObjectSetInteger(obj_id, obj_name, OBJPROP_FONTSIZE, 8);
        ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
    }
}