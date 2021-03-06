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
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
  long result=-1;
  ResetLastError();
  if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
  {
    Print(__FUNCTION__+", Error Code = ",GetLastError());
  }
  return((int)result);
  }

//+------------------------------------------------------------------+
double GetChartHighPrice()
  {
    max_price=ChartGetDouble(0,CHART_PRICE_MAX);
    min_price=ChartGetDouble(0,CHART_PRICE_MIN);   
    return(max_price-((max_price-min_price) * (0/ChartHeightInPixelsGet(0, 0)))); 
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