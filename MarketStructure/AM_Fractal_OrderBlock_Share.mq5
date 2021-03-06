//+------------------------------------------------------------------+
//|                                         AM_Fractal_OrderBlock.mq5|
//|                               Copyright © 2021, Aurthur Musendame|
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Aurthur Musendame"
#property description "OrderBlock Identifier"
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

//+-----------------------------------+
string obj_str = "AM_OrderBlock";

// data starting point
int min_rates_total, new_rates_total;

//+------------------------------------------------------------------+
//| initialization function                     |
//+------------------------------------------------------------------+
int OnInit()
  {
   IndicatorSetString(INDICATOR_SHORTNAME, obj_str);
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
   
   // Dray OrderBlocks Function
   OrderBlock(date_time, obj_str, start, new_rates_total, open, high, low, close, time);

   return(new_rates_total);
  }
//+------------------------------------------ END ITERATION FUNCTION

//+----------------------------------------------------------------------------------------------+
//| PriceTimeStudies:                                                                            |
//+----------------------------------------------------------------------------------------------+
void OrderBlock(
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
   double price_high, price_low, this_high, this_low;
   int chart_id = 0, bar_far_right_position, num_elements;

   for(int i = start; i < look_back - CandleCount*2 && !IsStopped(); i++)
     {
      // get current candle i high and low
      this_high = iHigh(NULL, 0, i);
      this_low  = iLow(NULL, 0, i);

      // Candle range Low and high ::   [bar_far_left_position, ..., i , ..., bar_far_right_position]
      num_elements = CandleCount*2 + 1; // range of bars to check
      bar_far_right_position = i - CandleCount;
      price_high = high[iHighest(Symbol(), Period(), MODE_HIGH, num_elements, bar_far_right_position)];
      price_low  = low[iLowest(Symbol(), Period(), MODE_LOW, num_elements, bar_far_right_position)];

      // high fractal
      if(this_high == price_high)
        {
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
