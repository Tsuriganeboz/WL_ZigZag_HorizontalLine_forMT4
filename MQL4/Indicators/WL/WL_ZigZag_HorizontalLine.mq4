//+------------------------------------------------------------------+
//|                                     WL_ZigZag_HorizontalLine.mq4 |
//|                                    Copyright 2016, Tsuriganeboz  |
//|                                  https://github.com/Tsuriganeboz |
//+------------------------------------------------------------------+
#include <WL/WL_MTF_ZigZagUtil.mqh>

#property copyright "Copyright 2016, Tsuriganeboz"
#property link      "https://github.com/Tsuriganeboz"
#property version   "1.00"
#property strict
#property indicator_chart_window

//--- 
input int InpDepth = 12;     // Depth
input int InpDeviation = 5;  // Deviation
input int InpBackstep = 3;   // Backstep

input int HLineMax = 12;
input color HLineColor = clrMediumSlateBlue;
input color HLineAverageColor = clrWhite;

//---
#define WL_OBJ_NAME_H_LINE          "WL_ZigZagHLine"
#define WL_OBJ_NAME_H_LINE_AVERAGE  "WL_ZigZagHLineAverage"


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WL_CreateHLine(string name, color col)
{
   ObjectCreate(name, OBJ_HLINE, 0, 0, 0);
   ObjectSet(name, OBJPROP_COLOR, col);
   
   // 
   ObjectSet(name, OBJPROP_STYLE, STYLE_DASHDOT);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WL_MoveHLine(string name, double price)
{
   ObjectMove(name, 0, 0, price);
}


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

   for (int i = 0; i < HLineMax; i++)
   {  
      string name = WL_OBJ_NAME_H_LINE + IntegerToString(i);
      ObjectDelete(name);
   }
   
   ObjectDelete(WL_OBJ_NAME_H_LINE_AVERAGE);
   
//---
   //Alert("Deinit !");
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
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
//---
   double highestHigh = 0;
   double lowestLow = 0;

   double priceSum = 0;

   int lineCount = 0;

   for (int i = 0; i < Bars; i++)
   {
      double price = WL_MTFGetZigZag(Symbol(), Period(), i);
      if (price != 0)
      {
         priceSum += price;
      
         if (lineCount == 0)
         {
            // 何もしない。
         }
         else if (highestHigh == 0 && lowestLow == 0)
         {
            highestHigh = price;
            lowestLow = price;
         }
         else if (highestHigh < price)
         {
            highestHigh = price;
         }
         else if (lowestLow > price)
         {
             lowestLow = price;
         }
         else {}
         
         
         // 
         string name = WL_OBJ_NAME_H_LINE + IntegerToString(lineCount);
      
         if (ObjectFind(name) == -1)
         {
            WL_CreateHLine(name, HLineColor);
         }
         else {}
         WL_MoveHLine(name, price);
         ObjectSetString(0, name, OBJPROP_TEXT, TimeToStr(time[i], TIME_DATE | TIME_MINUTES));
      
         ++lineCount;
         if (lineCount >= HLineMax)
            break;
      }
      else {}   
   }
                        
   //{{
   if (ObjectFind(WL_OBJ_NAME_H_LINE_AVERAGE) == -1)
   {
      WL_CreateHLine(WL_OBJ_NAME_H_LINE_AVERAGE, HLineAverageColor);
   }
   else {}
   WL_MoveHLine(WL_OBJ_NAME_H_LINE_AVERAGE, NormalizeDouble(priceSum / HLineMax, Digits));
   //}}

   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
