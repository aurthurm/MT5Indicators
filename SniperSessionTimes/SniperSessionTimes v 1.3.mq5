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
#include "ObjectDrawers.mqh"
#include "DateCalculate.mqh"

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input int    NumberOfDays = 5;
input bool   AsiaBoxShow = true;
input string AsiaBegin   ="02:00";
input string AsiaEnd     ="06:00";
input string AsiaSRMEnd  ="13:00";
input bool   AsiaSRMShow =true;
input color  AsiaSRMColor =clrBlue;
input color  AsiaColor   =clrLightGray;
input bool   LondonOpenBoxShow = true;
input string LondonOpenBegin   ="07:00";
input string LondonOpenEnd     ="07:15";
input color  LondonOpenColor   =clrDarkGreen;
input bool   MProtractionBoxShow = true;
input string MProtractionBegin   ="08:00";
input string MProtractionEnd     ="08:15";
input color  MProtractionColor   =clrOlive;
input bool   NewYorkBoxShow = true;
input string NewYorkBegin   ="13:00";
input string NewYorkEnd     ="13:15";
input color  NewYorkColor   =clrDarkGreen;
input bool   CMEOpenBoxShow = true;
input string CMEOpenBegin   ="14:15";
input string CMEOpenEnd     ="14:30";
input color  CMEOpenColor   =clrOrange;
input bool   LondonCloseBoxShow = true;
input string LondonCloseBegin   ="18:00";
input string LondonCloseEnd     ="19:00";
input color  LondonCloseColor   =clrRed;
input bool  LO_NY_OpenLineShow = false;
input color  LO_NY_OpenLineColor = clrOrange;
input bool  WeeklyOpenLineShow = false;
input string WeeklyOpenLineTime     ="00:00";
input color  WeeklyOpenLineColor   =clrRed;

//+-----------------------------------+

// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
void OnInit()
  {
   min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
   IndicatorSetString(INDICATOR_SHORTNAME,"SessionKillZones");
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
  }
//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
   for(int i = 0; i < NumberOfDays; i++)
     {
      ObjectDelete(0, "Asia" + string(i));
      ObjectDelete(0, "AsiaSRM" + string(i) + "R");
      ObjectDelete(0, "AsiaSRM" + string(i) + "M");
      ObjectDelete(0, "AsiaSRM" + string(i) + "S");
      ObjectDelete(0, "SessionOpen" + string(i) + "LO");
      ObjectDelete(0, "SessionOpen" + string(i) + "NO");
      ObjectDelete(0, "London" + string(i));
      ObjectDelete(0, "MProtraction" + string(i));
      ObjectDelete(0, "NewYork" + string(i));
      ObjectDelete(0, "CMEOpen" + string(i));
      ObjectDelete(0, "LondonClose" + string(i));
      ObjectDelete(0, "WeeklyOpenLine" + string(i));
     }
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
   
   for(int i = 0; i < NumberOfDays; i++)
     { 
      
      if(AsiaBoxShow == true) DrawSnipers(date_time, "Asia" + string(i), AsiaBegin, AsiaEnd, AsiaColor, high, low);
      if(AsiaSRMShow == true) DrawSRM(date_time, "AsiaSRM" + string(i), AsiaBegin, AsiaEnd, AsiaSRMEnd, AsiaSRMColor, high, low);
      if(LO_NY_OpenLineShow == true) DrawOpenLines(date_time, "SessionOpen" + string(i), LondonOpenBegin, NewYorkBegin, LondonCloseBegin, LO_NY_OpenLineColor, open);   
      if(LondonOpenBoxShow == true) DrawSnipers(date_time, "London" + string(i), LondonOpenBegin, LondonOpenEnd, LondonOpenColor, high, low);
      if(MProtractionBoxShow == true) DrawSnipers(date_time, "MProtraction" + string(i), MProtractionBegin, MProtractionEnd, MProtractionColor, high, low);
      if(NewYorkBoxShow == true) DrawSnipers(date_time, "NewYork" + string(i), NewYorkBegin, NewYorkEnd, NewYorkColor, high, low);
      if(CMEOpenBoxShow == true) DrawSnipers(date_time, "CMEOpen" + string(i), CMEOpenBegin, CMEOpenEnd, CMEOpenColor, high, low);
      if(LondonCloseBoxShow == true) DrawSnipers(date_time, "LondonClose" + string(i), LondonCloseBegin, LondonCloseEnd, LondonCloseColor, high, low);


      date_time = decDateTradeDay(date_time);     
      MqlDateTime times;
      TimeToStruct(date_time, times); 
      
      if(times.day_of_week == 1 && WeeklyOpenLineShow == true) {
        DrawWeeklyOpenLines(date_time, "WeeklyOpenLine" + string(i), WeeklyOpenLineTime, WeeklyOpenLineColor);
       }
      
      while(times.day_of_week > 5)
        {
         date_time = decDateTradeDay(date_time);
         TimeToStruct(date_time, times);
        }
     }  
   return(rates_total);
  }
