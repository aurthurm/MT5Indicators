//+------------------------------------------------------------------+
//|                                                  AM_Fractals.mq5 |
//|                                Copyright 2020, Aurthur Musendame |
//|                          credits to Metaquotes Fractal indicator |
//+------------------------------------------------------------------+
#property copyright "2021, Aurthur Musendame"
//--- indicator settings
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
#property indicator_type1   DRAW_ARROW
#property indicator_type2   DRAW_ARROW
#property indicator_color1  Gray
#property indicator_color2  Gray
#property indicator_label1  "Fractal Up"
#property indicator_label2  "Fractal Down"
//--- indicator buffers
double ExtUpperBuffer[];
double ExtLowerBuffer[];
//--- 10 pixels upper from high price
int    ExtArrowShift=-10;

//--- User Input Controllable Settings
enum FACTAL_CHOICE
{
   TIMESTUDY = 1,  // TIME STUDIES
   STANDARD = 2,  // STANDARD FRACTAL
};

enum FRACTAL_CANDLES
{
   ONE = 1,  // ONE CANDLE
   TWO = 2,  // TWO CANDLES
   THREE = 3,  // THREE CANDLES
   FOUR = 4,  // FOUR CANDLES
   FIVE = 5,  // FIVE CANDLES
};

input FACTAL_CHOICE fractalChoice = TIMESTUDY;
input FRACTAL_CANDLES fractalCandles = FIVE;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
void OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtUpperBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ExtLowerBuffer,INDICATOR_DATA);
   IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
//--- sets first bar from what index will be drawn
   PlotIndexSetInteger(0,PLOT_ARROW,217);
   PlotIndexSetInteger(1,PLOT_ARROW,218);
//--- arrow shifts when drawing
   PlotIndexSetInteger(0,PLOT_ARROW_SHIFT,ExtArrowShift);
   PlotIndexSetInteger(1,PLOT_ARROW_SHIFT,-ExtArrowShift);
//--- sets drawing line empty value--
   PlotIndexSetDouble(0,PLOT_EMPTY_VALUE,EMPTY_VALUE);
   PlotIndexSetDouble(1,PLOT_EMPTY_VALUE,EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//|  Fractals on 5 bars                                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{
  if(rates_total<5)
    return(0);

  int start;

    //--- clean up arrays
    if(prev_calculated<7)
    {
      start=2;
      ArrayInitialize(ExtUpperBuffer,EMPTY_VALUE);
      ArrayInitialize(ExtLowerBuffer,EMPTY_VALUE);
    }
    else
      start=rates_total-5;

    //--- main cycle of calculations
    for(int i=start; i<rates_total-3 && !IsStopped(); i++)
    {

      if (fractalCandles == 1) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>=high[i-1])
          {
            ExtUpperBuffer[i]=high[i];
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<=low[i-1])
          {
            ExtLowerBuffer[i]=low[i];
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 2) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>=high[i-1] && high[i]>=high[i-2])
          {
            ExtUpperBuffer[i]=high[i];
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<=low[i-1] && low[i]<=low[i-2])
          {
            ExtLowerBuffer[i]=low[i];
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 3) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3])
          {
            ExtUpperBuffer[i]=high[i];
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3])
          {
            ExtLowerBuffer[i]=low[i];
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 4) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>high[i+4] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3] && high[i]>=high[i-4])
          {
            ExtUpperBuffer[i]=high[i];
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<low[i+4] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3] && low[i]<=low[i-4])
          {
            ExtLowerBuffer[i]=low[i];
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      if (fractalCandles == 5) 
      {
          //--- Upper Fractal
          if(high[i]>high[i+1] && high[i]>high[i+2] && high[i]>high[i+3] && high[i]>high[i+4] && high[i]>high[i+5] && high[i]>=high[i-1] && high[i]>=high[i-2] && high[i]>=high[i-3] && high[i]>=high[i-4] && high[i]>=high[i-5])
          {
            ExtUpperBuffer[i]=high[i];
          } else {
            ExtUpperBuffer[i]=EMPTY_VALUE;
          }

          //--- Lower Fractal
          if(low[i]<low[i+1] && low[i]<low[i+2] && low[i]<low[i+3] && low[i]<low[i+4] && low[i]<low[i+5] && low[i]<=low[i-1] && low[i]<=low[i-2] && low[i]<=low[i-3] && low[i]<=low[i-4] && low[i]<=low[i-5])
          {
            ExtLowerBuffer[i]=low[i];
          } else {
            ExtLowerBuffer[i]=EMPTY_VALUE;
          }
      } 
      //
  }
//--- OnCalculate done. Return new prev_calculated.
   return(rates_total);
}

//+------------------------------------------------------------------+
