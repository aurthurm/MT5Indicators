//+------------------------------------------------------------------+
//|                                                 AM_MWD_HiLo.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Monthly Weekly Daily High and Low"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0 

#include <ChartObjects/ChartObjectsLines.mqh>
CChartObjectTrend line;

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == Previous Day/Week/Month HiLO == ";
int    NumberOfDays = 0;
input bool  YesterdayHighLowShow = true;
input color YesterdayHighLowColor   = clrRed;
input int HistoryDayHiLoShift   = 1;
input bool  YestWeekHighLowShow = false;
input color YestWeekHighLowColor   = clrRed;
input int HistoryWeekHiLoShift   = 1;
input bool  YestMonthHighLowShow = false;
input color YestMonthHighLowColor   = clrRed;
input int HistoryMonthHiLoShift   = 1;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_MWD_HiLo");
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits);  
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
    ObjectDelete(0, "YestDHi");
    ObjectDelete(0, "YestDLo");
    ObjectDelete(0, "YestWHi");
    ObjectDelete(0, "YestWLo");
    ObjectDelete(0, "YestMHi");
    ObjectDelete(0, "YestMLo");
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
      
    if(YesterdayHighLowShow) DrawYesterHiLo("YestD", HistoryDayHiLoShift, YesterdayHighLowColor, PERIOD_D1, " Day" ); 
    if(YestWeekHighLowShow) DrawYesterHiLo("YestW", HistoryWeekHiLoShift, YestWeekHighLowColor, PERIOD_W1, " Week"); 
    if(YestMonthHighLowShow) DrawYesterHiLo("YestM", HistoryMonthHiLoShift, YestMonthHighLowColor, PERIOD_MN1, "Month");

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
//| DrawYesterHiLo: Draws Previous Hi and low  Month, week / days          |
//+------------------------------------------------------------------------+
void DrawYesterHiLo(
      string name,
      int days_shift, 
      color Color,
      ENUM_TIMEFRAMES time_frame,
      string name_post_fix
      
   )
  {    
    double   YestHi_Price     = iHigh(Symbol(), time_frame, days_shift);
    double   YestLo_Price     = iLow(Symbol(), time_frame, days_shift);
    datetime time_beg_of_day  = iTime(Symbol(), time_frame, days_shift);
    datetime time_end_of_day  = StringToTime( "23:00:00");
    //ObjectCreate(0, "YestHi", OBJ_TREND, 0, time_beg_of_day, YestHi_Price, time_end_of_day, YestHi_Price);

    line.Create(0, name + "Hi", 0, time_beg_of_day, YestHi_Price, time_end_of_day, YestHi_Price);    
    line.Color(Color);
    line.Description("  Prev " + string(days_shift) + " " + name_post_fix + " High: " + DoubleToString(YestHi_Price,5));  
      
    line.Create(0, name + "Lo", 0, time_beg_of_day, YestLo_Price, time_end_of_day, YestLo_Price);
    line.Color(Color);
    line.Description("  Prev " + string(days_shift) + " " + name_post_fix + " Low: " + DoubleToString(YestLo_Price,5));
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