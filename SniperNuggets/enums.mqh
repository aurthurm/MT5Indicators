//+------------------------------------------------------------------+
//|                                                  OjectDrawers.mqh|
//|                               Copyright © 2019, Aurthur Musendame|
//+------------------------------------------------------------------+

enum CUSTOM_TIMES_CALCS
{
   H05M00 = 60*60*5,  // 5Hours
   H06M00 = 60*60*6,  // 6Hours
   H07M00 = 60*60*7,  // 7Hours
   H08M00 = 60*60*8,  // 8Hours
   H09M00 = 60*60*9,  // 9Hours
   H10M00 = 60*60*10, // 10Hours
   H11M00 = 60*60*11, // 11Hours
   H12M00 = 60*60*12  // 12Hours
};

// CUSTOM_TIMES_CALCS FloutLengthTime = H09M00;

enum PIVOT_METHODS 
{ 
  HLC  =  1,      // Avg of High, Low, Close
  HLCC =  2,     // Avg of High, Low, Close, Close
  HLOC =  3,     // Avg of High, Low, Open, Close
  HLOO =  4,     // Avg of High, Low, Open, Open
  HLO  =  5,      // Avg of High, Low, Open
};

enum PIVOT_TIMEFRAME
{
  M = 1,     // MN
  W = 2,     // W1
  D = 3,     // D1
};

enum PIVOT_CHOICE
{
   STANDARD = 1, // Standard Pivots
   CAMARILLA = 2, // Camarrila Pivots
   FIBONACHI = 3, // Fibonachi Pivots
};


enum TIMEPRICE_CANDLES
{
   ONE = 1,  // ONE CANDLE
   TWO = 2,  // TWO CANDLES
   THREE = 3,  // THREE CANDLES
   FOUR = 4,  // FOUR CANDLES
   FIVE = 5,  // FIVE CANDLES
};