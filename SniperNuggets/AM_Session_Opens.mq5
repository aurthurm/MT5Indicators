//+------------------------------------------------------------------+
//|                                              AM_Session_Opens.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Session Open Horizontal Lines"
#property version   "1.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info  =" == LondonOpen , NewYorkOpen, ZeroGMTOpen Lines == ";
input int    NumberOfDays = 5;
input string LondonOpenBegin  ="07:00";
input string NewYorkBegin   ="13:00";
input string CMEOpenBegin   ="14:15";
input string LondonCloseBegin   ="18:00";
input bool  Lo_OpenLineShow = true;
input bool  NY_OpenLineShow = false;
input bool  ZeroGMT_OpenLineShow = false;
input color Lo_OpenLineColor = clrOrange;
input color NY_OpenLineColor = clrOrange;
input color ZeroGMT_OpenLineColor = clrOrange;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_Session_Opens");
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
      ObjectDelete(0, "SessionOpen" + string(i) + "LO");
      ObjectDelete(0, "SessionOpen" + string(i) + "NO");
      ObjectDelete(0, "SessionOpen" + string(i) + "ZG");
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
  
   if(rates_total < min_rates_total) return (RESET);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);

   datetime date_time = TimeCurrent();   
      
    if(Lo_OpenLineShow || NY_OpenLineShow || ZeroGMT_OpenLineShow) DrawOpenLines(
       date_time, "SessionOpen", NumberOfDays, 
       LondonOpenBegin, NewYorkBegin, LondonCloseBegin, 
       Lo_OpenLineColor, NY_OpenLineColor, ZeroGMT_OpenLineColor,
       Lo_OpenLineShow, NY_OpenLineShow, ZeroGMT_OpenLineShow, open);   

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

 }
 
 //+------------------------------------------------------------------+
//| DrawOpenLines: Draws LondonOpen and NewYorkOpen Horizontal Lines |
//+------------------------------------------------------------------+
void DrawOpenLines(
  datetime date_time,
  string object_name,
  int days_look_back,
  string time1,
  string time2,
  string time3,       
  color LoColor,      
  color NyColor,      
  color ZgColor,
  bool LoShow,
  bool NyShow,
  bool ZgShow,
  const double &Open[]
  )
  {
    for(int i = 0; i < days_look_back; i++)
    {
   datetime time_1, time_2, time_3, time_4;
   double price_1, price_2, price_3;
   int bar_1_position, bar_2_position, bar_3_position;
   int chart_id = 0;
   string name = object_name + string(i);

   time_1   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time1);
   time_2   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time2);
   time_3   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + time3);
   time_4   = StringToTime(TimeToString(date_time, TIME_DATE) + " " + "00:00:00");

   bar_1_position = iBarShift(NULL, 0, time_1);
   bar_2_position   = iBarShift(NULL, 0, time_2);
   bar_3_position   = iBarShift(NULL, 0, time_4);

   price_1  = iOpen(Symbol(), Period(), bar_1_position);
   price_2  = iOpen(Symbol(), Period(), bar_2_position);
   price_3  = iOpen(Symbol(), Period(), bar_3_position);
   
  if(ObjectFind(chart_id, name) == -1) 
    {
    if(LoShow == true){
     ObjectCreate(chart_id, name + "LO", OBJ_TREND, 0, time_1, price_1, time_3, price_1);
     ObjectSetInteger(chart_id, name + "LO", OBJPROP_COLOR, LoColor);
     ObjectSetInteger(chart_id, name + "LO", OBJPROP_STYLE, STYLE_DASH);
     }
    if(NyShow == true){
     ObjectCreate(chart_id, name + "NO", OBJ_TREND, 0, time_2, price_2, time_3, price_2);
     ObjectSetInteger(chart_id, name + "NO", OBJPROP_COLOR, NyColor);
     ObjectSetInteger(chart_id, name + "NO", OBJPROP_STYLE, STYLE_DASH);
     }
    if(ZgShow == true){
     ObjectCreate(chart_id, name + "ZG", OBJ_TREND, 0, time_4, price_3, time_3, price_3);
     ObjectSetInteger(chart_id, name + "ZG", OBJPROP_COLOR, ZgColor);
     ObjectSetInteger(chart_id, name + "ZG", OBJPROP_STYLE, STYLE_DASH);
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