//+------------------------------------------------------------------+
//|                                                  OjectDrawers.mqh|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+
#include "co_initiators.mqh"
#include "helpers.mqh"
#include "enums.mqh"

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
    for(int i = 0; i < days_look_back; i++)
    {
       datetime time_1, time_2;
       double price_1, price_2;
       int bar_1_position, bar_2_position, num_elements ;
       int chart_id = 0;
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
       //ObjectSetString(chart_id, name, OBJPROP_TEXT, (string)GetPips(price_1, price_2)); 
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

      //if(times.day_of_week == 1 && WeeklyOpenLineShow == true) {
      // rolling ony here: DrawWeeklyOpenLines(date_time, "WeeklyOpenLine" + string(i), WeeklyOpenLineTime, WeeklyOpenLineColor);
      //}

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

    //if(times.day_of_week == 1 && WeeklyOpenLineShow == true) {
      // rolling ony here: DrawWeeklyOpenLines(date_time, "WeeklyOpenLine" + string(i), WeeklyOpenLineTime, WeeklyOpenLineColor);
    //}

    while(times.day_of_week > 5)
    {
    date_time = decDateTradeDay(date_time);
    TimeToStruct(date_time, times);
    } 
  }
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

      //if(times.day_of_week == 1 && WeeklyOpenLineShow == true) {
        // rolling ony here: DrawWeeklyOpenLines(date_time, "WeeklyOpenLine" + string(i), WeeklyOpenLineTime, WeeklyOpenLineColor);
      //}

      while(times.day_of_week > 5)
      {
      date_time = decDateTradeDay(date_time);
      TimeToStruct(date_time, times);
      } 
    }
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

//+------------------------------------------------------------------------+
//| DrawCustomPeriods: Draws Custom Period Seperators                      |
//+------------------------------------------------------------------------+
void DrawCustomPeriods(
     datetime date_time, 
     string obj_name,
    int days_look_back, 
    ENUM_LINE_STYLE CPLynStyle, 
    string periodStartTime,
     color WeekendsClr, 
     color MonFriClr, 
     color TueToThuClr
    )
  {    
  for(int i = 0; i < days_look_back; i++)
  {  
    string name = obj_name + string(i);
    color clr = clrBlack;
    int weekday = TimeDayOfWeek(date_time);
    switch(weekday) {
      case 0 : clr = WeekendsClr; break;
      case 1 : clr = MonFriClr;  break;
      case 2 : clr = TueToThuClr; break;
      case 3 : clr = TueToThuClr; break;
      case 4 : clr = TueToThuClr;  break;
      case 5 : clr = MonFriClr; break;
      case 6 : clr = WeekendsClr; break;
    }
    
   datetime time_1  = StringToTime(TimeToString(date_time, TIME_DATE) + " " + periodStartTime);
   
   max_price=ChartGetDouble(0,CHART_PRICE_MAX);
   min_price=ChartGetDouble(0,CHART_PRICE_MIN);   
   int heightinpixels = ChartHeightInPixelsGet(0,0);
   textprice = max_price-((max_price-min_price)*(0/heightinpixels)); 
   ObjectCreate(0, name, OBJ_TREND, 0, time_1, Point(), time_1, textprice);   
   ObjectSetInteger(0, name, OBJPROP_COLOR, clr);
   ObjectSetInteger(0, name, OBJPROP_STYLE, CPLynStyle); 

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


//+------------------------------------------------------------------------+
//| DrawTrueDay: Draws Custom period Seperators that show true day         |
//+------------------------------------------------------------------------+
void DrawTrueDay(
  datetime date_time,  
  string obj_name, 
  int days_look_back,
  string startTime, 
  string endTime, 
  color startColor, 
  color endColor,
  ENUM_LINE_STYLE truedayLineStyle
  )
{
  for(int i = 0; i < days_look_back; i++)
  {
 string name = obj_name + string(i);
 datetime time_start  = StringToTime(TimeToString(date_time, TIME_DATE) + " " + startTime);
 datetime time_end  = StringToTime(TimeToString(date_time, TIME_DATE) + " " + endTime);
 textprice = GetChartHighPrice();
 // TrueDay Start
 int _day = TimeDayOfWeek(date_time);
 if(_day > 0 && _day < 6){
   line.Create(0, name + "Start", 0, time_start, Point(), time_start, textprice);
   line.Color(startColor);
   line.Description("TrueDaySart");
   line.SetInteger(OBJPROP_STYLE, truedayLineStyle);
   line.SetString(OBJPROP_TEXT, "TrueDaySart");
   line.Tooltip("Start Trading");
   // TrueDay End
   line.Create(0, name + "End", 0, time_end, Point(), time_end, textprice);
   line.Color(endColor);
   line.Description("TrueDayEnd");
   line.SetInteger(OBJPROP_STYLE, truedayLineStyle);
   line.SetString(OBJPROP_TEXT, "TrueDayEnd");
   line.Tooltip("Close Trades");
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
//+----------------------------------------------------------------------------------------------+
//| DrawFlout: Range Found Between 2 True Days  used tp predict next day possibl high and low    |
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
     if(pips > MaxFavouribleRange) boxColor = unFavourible;
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


//+----------------------------------------------------------------------------------------------+
//| WriteTemplateName: WaterMark                                                                 |
//+----------------------------------------------------------------------------------------------+

void WriteTemplateName(
   string name, 
   string text, 
   color clr, 
   int font_size, 
   ENUM_BASE_CORNER corner, 
   ENUM_ANCHOR_POINT anchor, 
   int x, 
   int y
)
{
   ObjectCreate(0 , name, OBJ_LABEL, 0, 0, 0);
   ObjectSetInteger(0 ,name,OBJPROP_XDISTANCE,x); 
   ObjectSetInteger(0 ,name,OBJPROP_YDISTANCE,y); 
   ObjectSetInteger(0 ,name,OBJPROP_CORNER,corner); 
   ObjectSetString(0 ,name,OBJPROP_TEXT,text); 
   ObjectSetString(0 ,name,OBJPROP_FONT, "Arial"); 
   ObjectSetInteger(0 ,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(0 ,name,OBJPROP_ANCHOR,anchor); 
   ObjectSetInteger(0 ,name,OBJPROP_COLOR,clr); 
   ObjectSetInteger(0 ,name,OBJPROP_BACK, true); 
   ObjectSetInteger(0 ,name,OBJPROP_ZORDER, 0);   
}