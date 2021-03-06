//+------------------------------------------------------------------+
//|                                                AM_PivotPoints.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Pivot Points Plotter"
#property version   "1.1"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#include "pivots.mqh"

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
int    NumberOfDays = 5;
input string Info  =" == ==  Pivot Points  == == ";
input bool showPivots = true; // Show Pivot Points
input PIVOT_CHOICE PivotChoice = STANDARD;
input PIVOT_TIMEFRAME PivotTimeFrame = D; // Pivot TimeFrame
input string Info2  = " == ==  Standard Pivot Settings  == == ";
input PIVOT_METHODS PivotMethod = HLC; // Pivot Point Method
input bool SRPivots = true; // Show Support Resistance Lines
input color SupportPivotsColor = clrGreen;   // Support Pivots  Color
input color ResistancePivotsColor = clrGreen; // Resistance Pivot Color
input ENUM_LINE_STYLE SRPivotsLineStyle = STYLE_DASHDOTDOT; // SR Pivot Line Style
input bool MidPivots = false; // Show Mid Pivot Lines
input color MidPivotsColor = clrOrange;  // Mid Pivots Color
input ENUM_LINE_STYLE MidPivotsLineStyle  = STYLE_DASHDOT; // Mid Pivot Line Style


// data starting point
int min_rates_total;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"AM_PivotPoints");
    return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+    
void OnDeinit(const int reason)
  {
    Delete_Pivots();
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
      
    if(showPivots) Pivot_Points(
        date_time, "Pivots", PivotMethod, PivotTimeFrame, PivotChoice, 
        SRPivots, SupportPivotsColor, ResistancePivotsColor, SRPivotsLineStyle,
        MidPivots, MidPivotsColor, MidPivotsLineStyle );

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
 
 