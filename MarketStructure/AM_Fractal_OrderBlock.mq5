//+------------------------------------------------------------------+
//|                                         AM_Fractal_OrderBlock.mq5|
//|                               Copyright © 2021, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Aurthur Musendame"
#property description "Highs and Lows Price Time Studies"
#property version   "1.2"
#property indicator_chart_window
#property indicator_buffers 0
#property indicator_plots 0

#define RESET 0

//+-----------------------------------+
//|  INDICATOR INPUT PARAMETERS       |
//+-----------------------------------+
input string Info0  =" == + General Settings + == ";
input int HistoryLookBack = 1000; // Look Back candle count (0 for all)
input int CandleCount = 11; // Candles around high/low
//
input string Info1  =" == + OrderBlock + == ";
input bool ShowBullishOrderBlocks = true; // Show Bearish OrderBlocks
input color buOColor = clrOrange;  // Bearish OrderBlock color
input bool ShowBearishOrderBlocks = true; // Show Bullish OrderBlocks
input color beOColor = clrGreenYellow;  // Bullish OrderBlock color
//
input string Info2  =" == + Price and Time Studies  + == ";
input bool ShowTimeStudies = false; // Show Time Studies
//
input bool ShowFractals = true; // Show Fractal Arrows
input color arrowHColor = clrRed;
input color arrowLColor = clrGreen;
//
input bool ShowTimes = false; //  Show Fractal Time labels
input color timeHColor = clrRed;  // Fractal High Time Label color
input color timeLColor = clrGreen;  // Fractal High Time Label color
//
input bool ShowPrices = false; // Show Fractal Price Labels
input color priceHColor = clrRed;
input color priceLColor = clrGreen;


//+-----------------------------------+
string obj_str = "AMFractal";

// data starting point
int min_rates_total, new_rates_total;

//+------------------------------------------------------------------+
//| initialization function                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, "AM_TimeStudies");
   IndicatorSetInteger(INDICATOR_DIGITS, _Digits);
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| deinitialization function                             |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll(0, obj_str, -1, -1); // this must delete everything but its not working
   int obj_total = ObjectsTotal(0, -1, -1);
   for(int i=0; i < obj_total; i++)
     {
      ObjectDelete(0, obj_str + string(i) + "-TimeH");
      ObjectDelete(0, obj_str + string(i) + "-TimeL");
      ObjectDelete(0, obj_str + string(i) + "-PriceH");
      ObjectDelete(0, obj_str + string(i) + "-PriceL");
      ObjectDelete(0, obj_str + string(i) + "-ArrowH");
      ObjectDelete(0, obj_str + string(i) + "-ArrowL");
      ObjectDelete(0, obj_str + string(i) + "-BuOBH");
      ObjectDelete(0, obj_str + string(i) + "-BeOBH");
      ObjectDelete(0, obj_str + string(i) + "-BuOBL");
      ObjectDelete(0, obj_str + string(i) + "-BeOBL");
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

   if(HistoryLookBack == 0)
      new_rates_total = rates_total;
   else
      new_rates_total = HistoryLookBack;

   if(new_rates_total < CandleCount*2 + 1)
      return(0);

   int start;

//--- clean up arrays
   if(prev_calculated < (CandleCount*2 + 1) + CandleCount)
      start = CandleCount;
   else
      start = new_rates_total - (CandleCount*2 + 1);

   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);

   datetime date_time = TimeCurrent();

   PriceTimeStudies(
      date_time,
      "AMFractal",
      start,
      new_rates_total,
      open,
      high,
      low,
      close,
      time
   );

   return(new_rates_total);
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
   const double &open[],
   const double &high[],
   const double &low[],
   const double &close[],
   const datetime  &time[]
)
  {

   datetime time_1;
   double price_high, price_low, this_high, this_low;
   int chart_id = 0, bar_far_right_position, num_elements;
   string nameHigh, nameLow, time_show;
   int angle_high = 75; //  45,
   int angle_low = -45; // -45,



   for(int i = start; i < look_back - CandleCount*2 && !IsStopped(); i++)
     {
      // Set names
      nameHigh = obj_name + (string)i + "-High";
      nameLow  = obj_name + (string)i + "-Low";
      // get candle i time, etract sub string HH:MM
      time_1    =  time[i]; // iTime(NULL, 0, i); // time[i]
      time_show = StringSubstr((string)time_1, 10, 20);
      // get current high and low
      this_high = iHigh(NULL, 0, i);
      this_low  = iLow(NULL, 0, i);

      // Candle range Low and high ::   [bar_far_left_position, ..., i , ..., bar_far_right_position]
      num_elements = CandleCount*2 + 1;
      bar_far_right_position = i - CandleCount;
      price_high = high[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_far_right_position)];
      price_low  = low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_far_right_position)];

      // high fractal
      if(this_high == price_high)
        {
         if(ShowTimeStudies && ShowTimes)
            plotTimes(chart_id, obj_name + (string)i+ "-TimeL", time_1, time_show, price_high, timeHColor, angle_high);
         if(ShowTimeStudies && ShowPrices)
            plotPrices(chart_id, obj_name + (string)i+ "-PriceL", time_1, price_high, priceHColor);
         if(ShowTimeStudies && ShowFractals)
            plotArrow(chart_id, obj_name + (string)i+ "-ArrowL", time_1, price_high, OBJ_ARROW_DOWN, ANCHOR_BOTTOM, arrowHColor);

         if(ShowBearishOrderBlocks)
           {
            //Bearish OrderBlock Search search range = 4
            double bulls_array[4];
            int bulls_indexes[4];
            for(int x=0; x<4; x++)
              {
               bulls_array[x]=0.0;
               bulls_indexes[x]=0.0;
              }

            int s_arr[1];
            for(int s = i + 4; s>=i; s--)
              {
               s_arr[0] = s;
               if(IsBullishCandle(open[s], close[s]))
                 {
                  ArrayInsert(bulls_indexes, s_arr, 0, 0, 1); // copy/insert the corresponding price index
                  ArrayInsert(bulls_array, high, 0, s, 1); // copy/insert the price_high
                  // plot all bearish orderblocks within the search range.
                  //plotArrow(chart_id, obj_name + (string)s + "-BuOB", time[s], high[s], OBJ_ARROW_DOWN, ANCHOR_BOTTOM, clrDarkCyan);
                 }
               //
              }
            int idx = bulls_indexes[ArrayMaximum(bulls_array)];
            //ArrayPrint(bulls_array);
            //ArrayPrint(bulls_indexes);
            //Print("max_ind: " + ArrayMaximum(bulls_array) + " idx: " + idx + " time: " + time[idx] + " high: " + high[idx]);
            // plot the highest orderblock
            plotArrow(chart_id, obj_name + (string)idx+ "-BuOBH", time[idx], high[idx], OBJ_ARROW_DOWN, ANCHOR_BOTTOM, buOColor);
            plotArrow(chart_id, obj_name + (string)idx+ "-BuOBL", time[idx], low[idx], OBJ_ARROW_UP, ANCHOR_TOP, buOColor);
           }
        }

      // low fractal
      if(this_low == price_low)
        {
         if(ShowTimeStudies && ShowTimes)
            plotTimes(chart_id, obj_name + (string)i+ "-TimeL", time_1, time_show, price_low, timeLColor, angle_low);
         if(ShowTimeStudies && ShowPrices)
            plotPrices(chart_id, obj_name + (string)i+ "-PriceL", time_1, price_low, priceLColor);
         if(ShowTimeStudies && ShowFractals)
            plotArrow(chart_id, obj_name + (string)i+ "-ArrowL", time_1, price_low, OBJ_ARROW_UP, ANCHOR_TOP, arrowLColor);

         if(ShowBullishOrderBlocks)
           {
            //Bullish OrderBlock Search search range = 4
            double bears_array[4];
            int bears_indexes[4];
            for(int x=0; x<4; x++)
              {
               bears_array[x]=99999999999999.99;
               bears_indexes[x]=0.0;
              }

            int s_arr[1];
            for(int s = i + 4; s>=i; s--)
              {
               s_arr[0] = s;
               if(IsBearishCandle(open[s], close[s]))
                 {
                  ArrayInsert(bears_indexes, s_arr, 0, 0, 1); // copy/insert the corresponding price index
                  ArrayInsert(bears_array, low, 0, s, 1); // copy/insert the price_low
                  // plot all bearish orderblocks within the search range.
                  // plotArrow(chart_id, obj_name + (string)s + "-BeOBL", time[s], low[s], OBJ_ARROW_UP, ANCHOR_TOP, clrDarkCyan);
                 }
               //
              }
            int idx = bears_indexes[ArrayMinimum(bears_array)];
            //ArrayPrint(bears_array);
            //ArrayPrint(bears_indexes);
            //Print("min_ind: " + ArrayMinimum(bears_array) + " idx: " + idx + " time: " + time[idx] + " low: " + low[idx]);
            // plot the lowest orderblock
            plotArrow(chart_id, obj_name + (string)idx+ "-BeOBH", time[idx], high[idx], OBJ_ARROW_DOWN, ANCHOR_BOTTOM, beOColor);
            plotArrow(chart_id, obj_name + (string)idx+ "-BeOBL", time[idx], low[idx], OBJ_ARROW_UP, ANCHOR_TOP, beOColor);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBullishCandle(double open_price, double close_price)
  {
   if(open_price == close_price) //doji
      return false;
   return close_price > open_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsBearishCandle(double open_price, double close_price)
  {
   if(open_price == close_price) //doji
      return false;
   return close_price < open_price;
  }
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

      if(time_months == 1 || time_months == 3 || time_months == 5 || time_months == 7 || time_months == 8 || time_months == 10 || time_months == 12)
         time_days = 31;
      if(time_months == 2)
         if(!MathMod(time_years, 4))
            time_days = 29;
         else
            time_days = 28;
      if(time_months == 4 || time_months == 6 || time_months == 9 || time_months == 11)
         time_days = 30;
     }

   string text;
   StringConcatenate(text, time_years, ".", time_months, ".", time_days, " ", time_hours, ":", time_mins);
   return(StringToTime(text));
  }

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void plotTimes(int obj_id, string obj_name, datetime obj_time, string obj_txt, double obj_price, color obj_clr, int obj_angle)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, OBJ_TEXT, 0, obj_time, obj_price);
      ObjectSetString(obj_id, obj_name, OBJPROP_TEXT, obj_txt);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_FONTSIZE, 8);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
      ObjectSetDouble(obj_id, obj_name, OBJPROP_ANGLE, obj_angle);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void plotPrices(int obj_id, string obj_name, datetime obj_time, double obj_price, color obj_clr)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, OBJ_ARROW_LEFT_PRICE, 0, obj_time, obj_price);
      ObjectSetInteger(obj_id,  obj_name, OBJPROP_COLOR, obj_clr);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void plotArrow(int obj_id, string obj_name, datetime obj_time, double obj_price, ENUM_OBJECT obj_arrow, ENUM_ARROW_ANCHOR obj_anchor, color obj_clr)
  {
   if(ObjectFind(obj_id, obj_name) == -1)
     {
      ObjectCreate(obj_id, obj_name, obj_arrow, 0, obj_time, obj_price);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_ANCHOR, obj_anchor);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_COLOR, obj_clr);
      ObjectSetInteger(obj_id, obj_name, OBJPROP_WIDTH, 2);
     }
  }
//+------------------------------------------------------------------+
