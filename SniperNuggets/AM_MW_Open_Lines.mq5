//+------------------------------------------------------------------+
//|                                             AM_MWD_Open_Lines.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Current Month Open Line an Rolling Weekly Open Lines"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info_0  =" == Weekly Open Lines == ";
input int    NumberOfDays = 10;
input bool  WeeklyOpenLineShow = true;
input string WeeklyOpenLineTime     ="00:00";
input color  WeeklyOpenLineColor   =clrRed;
input string Info_1  =" == Current Month Open Line == ";
input bool   MonthOpenLineShow = true;
input color  MonthOpenLineColor   =clrRed;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_MWD_Open_Lines");
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
      ObjectDelete(0, "MonthOpenLine");
      ObjectDelete(0, "WeeklyOpenLine");
      ObjectDelete(0, "WeeklyOpenLine" + string(i));
      Comment("");
      ChartRedraw(0);
   }
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
      
  if(WeeklyOpenLineShow) DrawWeeklyOpenLines(date_time, "WeeklyOpenLine", NumberOfDays, WeeklyOpenLineTime, WeeklyOpenLineColor);
  if(MonthOpenLineShow) DrawMonthOpenLine("MonthOpenLine", MonthOpenLineColor);

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
 
 //+------------------------------------------------------------------------+
//| DrawWeeklyOpenLines: Draws Weekly Open Horizontal Line spanning 5 days |
//+------------------------------------------------------------------------+
void DrawWeeklyOpenLines(
  datetime date_time,
  string object_name,
  int days_look_back,
  string time1,     
  color clr
  )
  {
    for(int i = 0; i < days_look_back; i++)
    {
   datetime time_1, time_2;
   double price_1;
   int bar_1_position;
   string name = object_name + string(i);      
   MqlDateTime times;
   TimeToStruct(date_time, times);


   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time1);
   time_2   = time_1 + 414100;

   bar_1_position = iBarShift(NULL, 0, time_1);
   price_1  = iOpen(Symbol(), Period(), bar_1_position);
   
   if(ObjectFind(0, name) == -1 && times.day_of_week == 1) 
     {
       ObjectCreate(0, name, OBJ_TREND, 0, time_1, price_1, time_2, price_1);
       ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
       ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
     }

  date_time = decDateTradeDay(date_time);  

  while(times.day_of_week > 5)
  {
  date_time = decDateTradeDay(date_time);
  TimeToStruct(date_time, times);
  } 
  }
}

//+------------------------------------------------------------------------+
//| DrawMonthOpenLine: Draws Month Open Horizontal Line                    |
//+------------------------------------------------------------------------+
void DrawMonthOpenLine(string name, color clr)
  {
   datetime time_1, time_2;
   double price_1;

   time_1   = iTime(NULL,PERIOD_MN1,0);
   time_2   = TimeCurrent() + 3600;
   price_1  = iOpen(Symbol(), PERIOD_MN1, 0);   
   
   if(ObjectFind(0, name) == -1) 
     {
       ObjectCreate(0, name, OBJ_TREND, 0, time_1, price_1, time_2, price_1);
       ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
       ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DASH);
     }
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