//+------------------------------------------------------------------+
//|                                                 SniperNuggets.mq5|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2019, Aurthur Musendame"
#property description "Liquidity Snipper Nuggets Indicator"
#property version   "2.0"
#property indicator_chart_window 
#property indicator_buffers 0
#property indicator_plots 0

#include "import-all.mqh"

#define RESET 0 

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info_1  =" == Look Back Days == ";
input int    NumberOfDays = 5;

input string Info_2  =" == Sessions Parameters == ";
input bool   AsiaBoxShow = false;
input string AsiaBegin   ="02:00";
input string AsiaEnd     ="06:00";
input string AsiaSRMEnd  ="13:00";
input bool   AsiaSRMShow =false;
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

input string Info_3  =" == LondonOpen , NewYorkOpen, ZeroGMTOpen Lines == ";
input bool  Lo_OpenLineShow = false;
input bool  NY_OpenLineShow = false;
input bool  ZeroGMT_OpenLineShow = false;
input color Lo_OpenLineColor = clrOrange;
input color NY_OpenLineColor = clrOrange;
input color ZeroGMT_OpenLineColor = clrOrange;

input string Info_4  =" == Weekly Open Lines == ";
input bool  WeeklyOpenLineShow = false;
input string WeeklyOpenLineTime     ="00:00";
input color  WeeklyOpenLineColor   =clrRed;

input string Info_5  =" == Current Month Open Line == ";
input bool   MonthOpenLineShow = false;
input color  MonthOpenLineColor   =clrRed;

input string Info_6  =" == Previous Day/Week/Month HiLO == ";
input bool  YesterdayHighLowShow = false;
input color YesterdayHighLowColor   = clrRed;
input int HistoryDayHiLoShift   = 1;
input bool  YestWeekHighLowShow = false;
input color YestWeekHighLowColor   = clrRed;
input int HistoryWeekHiLoShift   = 1;
input bool  YestMonthHighLowShow = false;
input color YestMonthHighLowColor   = clrRed;
input int HistoryMonthHiLoShift   = 1;

input string Info_7  =" == Custom Period Seperator == ";
input bool ShowCustomPeriods = false;
input string CustomPeriodStartTime = "00:00";
input color WeekendColor = clrRed;
input color MondayandFridayColor = clrYellow;
input color TuesdayToThursdayColor = clrAqua;
input ENUM_LINE_STYLE CPLineStyle = STYLE_DASHDOTDOT;

input string Info_8  =" == True Day Parameters == ";
input bool ShowTrueDay = false;
input string TrueDayStartTime = "02:00";
input string TrueDayEndTime = "19:00";
input color TrueDayStartColor = clrGreen;
input color TrueDayEndColor = clrRed;
input ENUM_LINE_STYLE TrueDayLineStyle = STYLE_DASHDOTDOT;

input string Info_9  =" == + Flout Range Parameters  + == ";
input bool ShowFlout = false;
input string FloutStartTime = "21:00";
input CUSTOM_TIMES_CALCS FloutLength = H09M00;
input color FloutBoxColor = clrGreen;
input bool FloutBoxBG = true;
input color FloutTextColor = clrGreen;
input int FloutMaxFavouribleRange = 40;
input color FloutUnfavouribleColor = clrRed;
input bool  FloutSDPrediction =false;
ENUM_ANCHOR_POINT FloutTextAnchor = ANCHOR_LOWER;

input string Info_10  =" == + CBDR Range Parameters + == ";
input bool ShowCBDR = false;
input string CBDRStartTime = "20:00";
input CUSTOM_TIMES_CALCS CBDRLength = H06M00; //CBDR Length
input color CBDRBoxColor = clrGreen;
input bool CBDRBoxBG = true;
input color CBDRTextColor = clrGreen;
input int CBDRMaxFavouribleRange = 40;
input color CBDRUnfavouribleColor = clrRed;
input bool   CBDRSDPrediction =false;
input ENUM_ANCHOR_POINT CBDRTextAnchor = ANCHOR_LOWER;

input string Info_11  =" == == ADR Marker == == ";
input bool showADR  = false; // Show ADR 
input color adrmColor = clrBlue; // Markers Color
input int adrm_LThickness = 1; // Markers Line Thickness
input ENUM_LINE_STYLE adr_line_style = STYLE_DASHDOTDOT;
input bool useCustomRange  = false; // Use  Custom Range Days 
input int adr_past_days = 5; // Range Days for ADR Calc\
input bool DrawMarkers  = false; // Draw ADR Markers

input string Info_12  =" == ==  Pivot Points  == == ";
input bool showPivots = false; // Show Pivot Points
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

input string Info_13  =" == == Template Name == == ";
input bool showTName  = true; // Show Template Name 
input string TName  = "Template Name"; // Template Name 
input color TNameColor = clrYellow; // Template Name Color
input int TNameSize = 20; // Template Name Size
input ENUM_BASE_CORNER TNameCorner = CORNER_RIGHT_LOWER; // Template Name Text Corner
input ENUM_ANCHOR_POINT TNameAnchor = ANCHOR_RIGHT_LOWER; // Template Name Anchor
input int TName_x_pos = 10; // TName X POSITION
input int TName_y_pos = 10; //  TName Y POSITION


//+-----------------------------------+

// data starting point
int min_rates_total;
// custome period seperators
double textprice, newtextprice,
       max_price, min_price;
      
//ADR
double pnt;
int _digits;

//+------------------------------------------------------------------+   
//| initialization function                     | 
//+------------------------------------------------------------------+ 
int OnInit()
  {
    min_rates_total = NumberOfDays * PeriodSeconds(PERIOD_D1)/PeriodSeconds(PERIOD_CURRENT);
    IndicatorSetString(INDICATOR_SHORTNAME,"SessionKillZones");
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
    //--- find the highest and lowest values of the chart then calculate textposition == GetChartHighPrice
    textprice  = GetChartHighPrice();  
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
      ObjectDelete(0, "WeeklyOpenLine");
      ObjectDelete(0, "WeeklyOpenLine" + string(i));
      ObjectDelete(0, "MonthOpenLine");
      ObjectDelete(0, "CPL" + string(i));
      ObjectDelete(0, "TrueDay" + string(i));
      ObjectDelete(0, "TrueDay" + string(i) + "Start");
      ObjectDelete(0, "TrueDay" + string(i) + "End");
      ObjectDelete(0, "Flout" + string(i));
      ObjectDelete(0, "Flout" + string(i) + " pips");
      ObjectDelete(0, "CBDR" + string(i));
      ObjectDelete(0, "CBDR" + string(i) + " pips");
      for(int n=0; n<20; n++){
        ObjectDelete(0, "Asia" + string(i) + "SD"  + string(n));
        ObjectDelete(0, "CBDR" + string(i) + "SD"  + string(n));
        ObjectDelete(0, "Flout" + string(i) + "SD"  + string(n));
      }
     }
    ObjectDelete(0, "YestDHi");
    ObjectDelete(0, "YestDLo");
    ObjectDelete(0, "YestWHi");
    ObjectDelete(0, "YestWLo");
    ObjectDelete(0, "YestMHi");
    ObjectDelete(0, "YestMLo");
    ObjectDelete(0, "MonthOpenLine");
    ObjectDelete(0, "ADRMHigh");
    ObjectDelete(0, "ADRMLow");
    ObjectDelete(0, "ADRMStart");
    ObjectDelete(0, "TName");
    Delete_Pivots();
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
      
    if(AsiaBoxShow) DrawSnipers(date_time, "Asia", NumberOfDays, AsiaBegin, AsiaEnd, AsiaColor, AsiaMaxFavouribleRange,  AsiaUnfavouribleColor, AsiaSDPrediction, high, low);
    if(AsiaSRMShow) DrawSRM(date_time, "AsiaSRM", NumberOfDays, AsiaBegin, AsiaEnd, AsiaSRMEnd, AsiaSRMColor, high, low);
    if(Lo_OpenLineShow || NY_OpenLineShow || ZeroGMT_OpenLineShow) DrawOpenLines(
       date_time, "SessionOpen", NumberOfDays, 
       LondonOpenBegin, NewYorkBegin, LondonCloseBegin, 
       Lo_OpenLineColor, NY_OpenLineColor, ZeroGMT_OpenLineColor,
       Lo_OpenLineShow, NY_OpenLineShow, ZeroGMT_OpenLineShow, open);   
      if(LondonOpenBoxShow) DrawSnipers(date_time, "London", NumberOfDays, LondonOpenBegin, LondonOpenEnd, LondonOpenColor, 10000, LondonOpenColor, false, high, low);
    if(MProtractionBoxShow) DrawSnipers(date_time, "MProtraction", NumberOfDays, MProtractionBegin, MProtractionEnd, MProtractionColor, 10000, MProtractionColor, false, high, low);
    if(NewYorkBoxShow) DrawSnipers(date_time, "NewYork", NumberOfDays, NewYorkBegin, NewYorkEnd, NewYorkColor, 10000, NewYorkColor, false, high, low);
    if(CMEOpenBoxShow) DrawSnipers(date_time, "CMEOpen", NumberOfDays, CMEOpenBegin, CMEOpenEnd, CMEOpenColor, 10000, CMEOpenColor, false, high, low);
    if(LondonCloseBoxShow) DrawSnipers(date_time, "LondonClose", NumberOfDays, LondonCloseBegin, LondonCloseEnd, LondonCloseColor, 10000, LondonOpenColor, false, high, low);
    if(ShowCustomPeriods) DrawCustomPeriods(date_time,  "CPL", NumberOfDays, CPLineStyle, CustomPeriodStartTime, WeekendColor, MondayandFridayColor, TuesdayToThursdayColor);
    if(ShowTrueDay) DrawTrueDay(date_time, "TrueDay", NumberOfDays, TrueDayStartTime, TrueDayEndTime, TrueDayStartColor, TrueDayEndColor, TrueDayLineStyle);
    if(ShowFlout) DrawFlout(date_time, "Flout", NumberOfDays, FloutStartTime, FloutLength,  FloutBoxColor,FloutBoxBG, FloutTextColor, FloutTextAnchor, FloutMaxFavouribleRange, FloutUnfavouribleColor, FloutSDPrediction, high, low);
    if(ShowCBDR) DrawFlout(date_time, "CBDR", NumberOfDays, CBDRStartTime, CBDRLength,  CBDRBoxColor, CBDRBoxBG, CBDRTextColor, CBDRTextAnchor, CBDRMaxFavouribleRange, CBDRUnfavouribleColor, CBDRSDPrediction, high, low);
    if(WeeklyOpenLineShow) DrawWeeklyOpenLines(date_time, "WeeklyOpenLine", NumberOfDays, WeeklyOpenLineTime, WeeklyOpenLineColor);

    if(AsiaBoxShow) DrawSnipers(date_time, "Asia", NumberOfDays, AsiaBegin, AsiaEnd, AsiaColor, AsiaMaxFavouribleRange,  AsiaUnfavouribleColor, AsiaSDPrediction, high, low);
     
    if(YesterdayHighLowShow) DrawYesterHiLo("YestD", HistoryDayHiLoShift, YesterdayHighLowColor, PERIOD_D1, " Day" ); 
    if(YestWeekHighLowShow) DrawYesterHiLo("YestW", HistoryWeekHiLoShift, YestWeekHighLowColor, PERIOD_W1, " Week"); 
    if(YestMonthHighLowShow) DrawYesterHiLo("YestM", HistoryMonthHiLoShift, YestMonthHighLowColor, PERIOD_MN1, "Month");
     
    if(MonthOpenLineShow) DrawMonthOpenLine("MonthOpenLine", MonthOpenLineColor); 
    if(showADR) ADR_Maker(date_time, "ADRM", adrmColor, adrm_LThickness, adr_line_style, useCustomRange, adr_past_days, DrawMarkers, high, low);
    if(showPivots) Pivot_Points(
        date_time, "Pivots", PivotMethod, PivotTimeFrame, PivotChoice, 
        SRPivots, SupportPivotsColor, ResistancePivotsColor, SRPivotsLineStyle,
        MidPivots, MidPivotsColor, MidPivotsLineStyle );
    if(showTName) WriteTemplateName("TName", TName, TNameColor, TNameSize, TNameCorner, TNameAnchor, TName_x_pos, TName_y_pos);

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
   if(id==CHARTEVENT_CHART_CHANGE)
     {
      // Custom Periods Aligh to Chart Height
      textprice = GetChartHighPrice();      
      int total_trends_ = ObjectsTotal(0, 0, OBJ_TREND);
      for (int i = 0; i <= total_trends_; i++){
        string _name = ObjectName(0, i , 0 , OBJ_TREND);
        if (StringSubstr(_name, 0, 3) == "CPL"){
          long t1 = ObjectGetInteger(0, _name, OBJPROP_TIME, 1);
           ObjectMove(0, _name, 1, t1, textprice);
        }
        // TrueDay CustomPeriods
        if (StringSubstr(_name, 0, 7) == "TrueDay"){
          long t1 = ObjectGetInteger(0, _name, OBJPROP_TIME, 1);
           ObjectMove(0, _name, 1, t1, textprice);
        }
      }
      newtextprice = textprice;    
      ChartRedraw();    
   }
 }
 
 