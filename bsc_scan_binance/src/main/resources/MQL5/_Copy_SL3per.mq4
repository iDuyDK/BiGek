//+------------------------------------------------------------------+
//|                                               OpenTrade_X100.mq4 |
//|                                  Copyright 2024, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2024, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
//-----------------------------------------------------------------------------
int    NUMBER_OF_TRADER = 10;
double INIT_EQUITY      = 10000.0;   // Vốn đầu tư
double INIT_VOLUME      = 0.01;     // Lot
double dbRiskRatio      = 0.01;     // Rủi ro 1%
double FIXED_SL_AMP     = 10;
double NEXT_10PER_AMP   = FIXED_SL_AMP/2;
double MAX_PERCENT_POTENTIAL_LOSS = 30; // 30%
double INIT_CLOSE_W1    = 2295;
double AMP_DC           = 3;
double AMP_TP           = 25;
string VER = "V240705";
string INDI_NAME = VER;
//-----------------------------------------------------------------------------
string telegram_url="https://api.telegram.org";
//-----------------------------------------------------------------------------
#define BtnD10                   "BtnD10_"
#define BtnTrend                 "BtnTrend_"
#define BtnNoticeDH21            "BtnNoticeDH21"
#define BtnNoticeD1              "BtnNoticeD1"
#define BtnNoticeH4              "BtnNoticeH4"
#define BtnNoticeH1              "BtnNoticeH1"
#define BtnTradeD10H4            "BtnTradeD10H4_"
#define BtnTradeWma10            "BtnTradeWma10_"
#define BtnTradeByWaitH4         "BtnTradeByWaitH4_"
#define BtnTradeByStoD21         "BtnTradeByStoD21_"
#define BtnTradeNowTp1D          "BtnTradeNowTp1D"
#define BtnTradeRev10D           "BtnTradeRev10D"
#define BtnCloseSymbol           "BtnCloseSymbol"
#define BtnCloseLimit            "BtnCloseLimit"
#define BtnCloseAllLimit         "BtnCloseAllLimit"
#define BtnCloseAllTicket        "BtnCloseAllTicket"
#define BtnTelegramMessage       "Telegram_Message"
#define BtnTpDay_06_07           "BtnTpDay_06_07"
#define BtnTpDay_13_14           "BtnTpDay_13_14"
#define BtnTpDay_20_21           "BtnTpDay_20_21"
#define BtnTpDay_27_28           "BtnTpDay_27_28"
#define BtnTpDay_34_35           "BtnTpDay_34_35"
#define BtnSendNotice_D1         "BtnSendNoticeD1"
#define BtnSendNotice_H4         "BtnSendNoticeH4"
#define BtnSendNotice_H1         "BtnSendNoticeH1"
#define BtnTradeBySeqH4          "BtnTradeBySeqH4"
#define SendTeleMsg_             "SendTeleMsg_"
#define SendTeleSeqMsg_          "SendTeleSeqMsg_"
#define START_TRADE_LINE         "START_TRADE"
//-----------------------------------------------------------------------------
bool IS_WAITTING_10PER_BUY = false;
bool IS_WAITTING_10PER_SEL = false;
bool IS_CONTINUE_TRADING_CYCLE_BUY = false;
bool IS_CONTINUE_TRADING_CYCLE_SEL = false;
double PRICE_START_TRADE = 0.0;
//-----------------------------------------------------------------------------
double store = 0.0;
bool   DEBUG_MODE = true;
string TREND_BUY = "BUY";
string TREND_SEL = "SELL";
string MASK_DANGER   = "(X)";
string MASK_HEDG     = "(HG)";
string MASK_ROOT     = "(RO)";
string MASK_EXIT     = "(EX)";
string MASK_MANUAL   = "(ML)";
string MASK_10PER    = "(HS)";
string MASK_TP1D     = "(D.1)";
string MASK_D10      = "(D.X)";
string MASK_REV_D10  = "(R.V)";
string MASK_SEQ_H4   = "(S.Q)";
string MASK_MARKET   = "(M.K)";
string MASK_LIMIT    = "(L.M)";
string MASK_TRIPLE   = "(X.3)";
string MASK_TREND_TRANSFER = "(T.F)";
string SWITCH_TREND_BY_HISTOGRAM = "SwByHistogram_";
string LOCK = "(Lock)";
double MAXIMUM_DOUBLE = 999999999;
int count_closed_today = 0;
string FILE_NAME_SEND_MSG = "_send_msg_today.txt";
string FILE_NAME_AUTO_TRADE = "_auto_trade_today.txt";
datetime ALERT_MSG_TIME = 0;
datetime TIME_OF_ONE_H1_CANDLE = 3600;
datetime TIME_OF_ONE_H4_CANDLE = 14400;
datetime TIME_OF_ONE_D1_CANDLE = 86400;
datetime TIME_OF_ONE_W1_CANDLE = 604800;
string lable_profit_buy = "", lable_profit_sel = "", lableBtnPaddingTrade = "", lable_profit_positive_orders = "";
int DEFAULT_WAITING_DCA_IN_MINUS = 30, BUTTON_HEIGH = 20;
int MINUTES_BETWEEN_ORDER = 10;
int LIMIT_D = 365;
string arr_largest_negative_trader_name[100];
double arr_largest_negative_trader_amount[100];
string INIT_TREND_TODAY = "";
double FIBO_1618 = 1.618;
double FIBO_2618 = 2.618;
bool isDragging = false;
double INIT_START_PRICE = 0.0;
color clrActiveBtn = clrLightGreen;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//X100:111119988-Real31, Cent50k1:111119992-Real31, Cent50k2:87149162-Real30:
string REAL_ACCOUNT = ",111119988,111119992,87149162";
string ARR_SYMBOLS_CENT[] =
  {
   "XAUUSDc"
   , "AUDJPYc", "NZDJPYc", "EURJPYc", "GBPJPYc", "USDJPYc"
   , "AUDCHFc", "AUDNZDc", "AUDUSDc"
   , "EURAUDc", "EURCADc", "EURCHFc", "EURGBPc", "EURNZDc", "EURUSDc"
   , "GBPCHFc", "GBPNZDc", "GBPUSDc"
   , "NZDUSDc"
   , "USDCADc", "USDCHFc",
  };

//69478966
string ARR_SYMBOLS_USD[] =
  {
   "XAUUSD"
   , "AUDJPY", "NZDJPY", "EURJPY", "GBPJPY", "USDJPY"
   , "AUDCHF", "AUDNZD", "AUDUSD"
   , "EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURNZD", "EURUSD"
   , "GBPCHF", "GBPNZD", "GBPUSD"
   , "NZDUSD"
   , "USDCAD", "USDCHF"
   , "USOIL", "BTCUSD", "US30", "US500", "USTEC", "FR40", "JP225"
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CandleData
  {
public:
   datetime          time;   // Thời gian
   double            open;   // Giá mở
   double            high;   // Giá cao
   double            low;    // Giá thấp
   double            close;  // Giá đóng
   string            trend_heiken;
   int               count_heiken;
   double            ma10;
   string            trend_by_ma10;
   int               count_ma10;
   string            trend_vector_ma10;
   string            trend_by_ma05;
   string            trend_ma3_vs_ma5;
   int               count_ma3_vs_ma5;
   string            trend_seq;
   double            ma50;
   string            trend_ma10vs20;
   string            trend_ma5vs10;

                     CandleData()
     {
      time = 0;
      open = 0.0;
      high = 0.0;
      low = 0.0;
      close = 0.0;
      trend_heiken = "";
      count_heiken = 0;
      ma10 = 0;
      trend_by_ma10 = "";
      count_ma10 = 0;
      trend_vector_ma10 = "";
      trend_by_ma05 = "";
      trend_ma3_vs_ma5 = "";
      count_ma3_vs_ma5 = 0;
      trend_seq = "";
      ma50 = 0;
      trend_ma10vs20 = "";
      trend_ma5vs10 = "";
     }

                     CandleData(
      datetime t, double o, double h, double l, double c,
      string trend_heiken_, int count_heiken_,
      double ma10_, string trend_by_ma10_, int count_ma10_, string trend_vector_ma10_,
      string trend_by_ma05_, string trend_ma3_vs_ma5_, int count_ma3_vs_ma5_,
      string trend_seq_, double ma50_, string trend_ma10vs20_, string trend_ma5vs10_)
     {
      time = t;
      open = o;
      high = h;
      low = l;
      close = c;
      trend_heiken = trend_heiken_;
      count_heiken = count_heiken_;
      ma10 = ma10_;
      trend_by_ma10 = trend_by_ma10_;
      count_ma10 = count_ma10_;
      trend_vector_ma10 = trend_vector_ma10_;
      trend_by_ma05 = trend_by_ma05_;
      trend_ma3_vs_ma5 = trend_ma3_vs_ma5_;
      count_ma3_vs_ma5 = count_ma3_vs_ma5_;
      trend_seq = trend_seq_;
      ma50 = ma50_;
      trend_ma10vs20 = trend_ma10vs20_;
      trend_ma5vs10 = trend_ma5vs10_;
     }
  };

//+------------------------------------------------------------------+
//| OpenTrade_X100                                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//WriteAvgAmpToFile();
   string symbol = Symbol();

   Draw_Fibo(symbol, PERIOD_D1);

   if(Period() <= PERIOD_D1)
     {
      draw_trend_macd(symbol, PERIOD_D1, clrBlack);
      draw_trend_macd(symbol, PERIOD_H4, clrBlack);
      draw_trend_macd(symbol, PERIOD_H1, clrYellowGreen);
     }

   Draw_Heiken(symbol);

   Draw_Notice_Ma10D();
   Draw_CurPrice_Line();

   Draw_Buttons_Trend(symbol);

   string date_fr = "";
   string date_to = "";
   get_time_zones(symbol, date_fr, date_to);

   Draw_TimeZones(symbol + "1", date_fr, date_to, 5);
   Draw_TimeZones(symbol + "2", date_to, date_fr, 25);

//string time1, time2;
//double price1, scale;
//getGannGridProperties(symbol, time1, time2, price1, scale);
//if(price1 > 0 && scale > 0)
//   createGannGrid("GannGrid", StringToTime(time1), StringToTime(time2), price1, scale);
//else
//   ObjectDelete(0, "GannGrid");

   if(is_same_symbol(symbol, "XAU"))
      Draw_Lines(symbol);

   DeleteArrowObjects();

   DeleteObjectsFor_PERIOD_W1();

//EventSetTimer(900); //1800=30minutes; 900=15minutes; 300=5minutes; 180=3minutes; 60=1minute;
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
   string symbol = Symbol();
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(vietnamTime, time_struct);
//-------------------------------------------------------------------------------
   int cur_hour = time_struct.hour;
   int pre_check_hour = -1;
   if(GlobalVariableCheck("timer_one_hour"))
      pre_check_hour = (int)GlobalVariableGet("timer_one_hour");
   GlobalVariableSet("timer_one_hour", cur_hour);
   bool allow_re_check_after_1h = false;
   if(pre_check_hour != cur_hour)
      allow_re_check_after_1h = true;
//-------------------------------------------------------------------------------
   Draw_CurPrice_Line();

   string PROFIT = (string)(int)AccountInfoDouble(ACCOUNT_PROFIT);
   ObjectSetString(0, BtnCloseAllTicket, OBJPROP_TEXT, "CloseAll: " + PROFIT + "$");
//-------------------------------------------------------------------------------
   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string find_trend = "";
      double total_profit = 0;
      bool has_opened_today = false;
      int count_L = 0, count_limit = 0, count_buy = 0, count_sel = 0;

      string temp_symbol = getSymbolAtIndex(index);
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(is_same_symbol(OrderSymbol(), temp_symbol))
              {
               if(OrderType() == OP_BUY)
                  count_buy += 1;
               if(OrderType() == OP_SELL)
                  count_sel += 1;

               if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                  count_limit += 1;

               if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                 {
                  count_L += 1;
                  double profit = OrderProfit() + OrderSwap() + OrderCommission();
                  total_profit += profit;
                  find_trend = (OrderType() == OP_BUY) ? TREND_BUY : TREND_SEL;

                  color clrTrend = (profit > 0) ? clrBlue : clrRed;

                  if(is_same_symbol(symbol, temp_symbol))
                     create_lable_simple((string)OrderTicket(), find_trend + " " + (string)(int)profit + " $", OrderOpenPrice(), clrTrend);
                  else
                     ObjectDelete(0, (string)OrderTicket());

                  if(allow_re_check_after_1h)
                     has_opened_today = is_order_opened_today(temp_symbol);
                 }
              }

      if(count_L > 0)
        {
         string objName = BtnD10 + temp_symbol;
         string buttonLabel = ObjectGetString(0, objName, OBJPROP_TEXT);
         string str_profit = (total_profit > 0 ? "+":"") + (string)(int)total_profit + to_percent(total_profit, 1) ;
         if(count_buy > 0)
            str_profit += (string)count_buy + "B";
         if(count_sel > 0)
            str_profit += (string)count_sel + "S";


         if(count_limit > 0)
            str_profit += ".L" + (string) count_limit;

         ObjectSetString(0, objName, OBJPROP_TEXT, ReplaceStringAfter(buttonLabel, "$", str_profit));

         if(allow_re_check_after_1h && has_opened_today == false)
           {
            if(is_allow_trade_now_by_stoc(symbol, PERIOD_H1, find_trend, 5, 3, 2))
              {
               Alert(symbol + " H1 allow " + find_trend);
              }
           }
        }

      if(count_L == 0 && count_limit > 0)
        {
         ClosePosition(symbol, OP_BUYLIMIT, TREND_BUY);
         ClosePosition(symbol, OP_SELLLIMIT, TREND_SEL);
         ObjectDelete(0, BtnCloseLimit);
        }
     }
//-------------------------------------------------------------------------------
     {
      int cur_minus = time_struct.min;
      int pre_check_minus = -1;
      if(GlobalVariableCheck("timer_one_minu"))
         pre_check_minus = (int)GlobalVariableGet("timer_one_minu");
      GlobalVariableSet("timer_one_minu", cur_minus);
      if(pre_check_minus != cur_minus)
        {
         Draw_Notice_Ma10D();
         Auto_SL_TP();
         DeleteObjectsFor_PERIOD_W1();
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Notice_Ma10D()
  {
   int x = 5;
   int y = 5;
   int btn_width = 210;
   int btn_heigh = 20;
   int chart_width = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));
   int chart_1_2_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS))/2;
   double minimum_profit = minProfit();

   string STR_SYMBOLS_OPENING = "";
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), STR_SYMBOLS_OPENING) == false)
            STR_SYMBOLS_OPENING += "_" + OrderSymbol();

   ObjectDelete(0, BtnCloseSymbol);
   ObjectDelete(0, BtnCloseLimit);
   int count = 0;
   string master_msg = "";
   string prefix_msg = "";
   string arrNoticeSymbols_D[];
   string arrNoticeSymbols_H4[];
   string arrNoticeSymbols_H1[];
   string strNoticeSymbols = "";
   string strTrade_Symbols_H4 = "";
   double risk_1p = risk_1_Percent_Account_Balance();

   ObjectDelete(0, "SL_BUY");
   ObjectDelete(0, "SL_SELL");
   bool is_reset_time = is_setting_reset_on_new_day();

   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string symbol = getSymbolAtIndex(index);
      bool is_cur_tab = is_same_symbol(symbol, Symbol());

      string trend_stoc_21_d1 = "", trend_stoc_21_h4 = "";
      int    count_stoc_21_d1 = 0,  count_stoc_21_h4 = 0;
      Count_Stoc_Candles(symbol, PERIOD_D1, trend_stoc_21_d1, count_stoc_21_d1,21,7,7, true);
      Count_Stoc_Candles(symbol, PERIOD_H4, trend_stoc_21_h4, count_stoc_21_h4,21,7,7);

      string trend_buy_sel_d1 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_D1, true);
      string trend_buy_sel_h4 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_H4, true);

      CandleData temp_array_D1[];
      get_arr_heiken(symbol, PERIOD_D1, temp_array_D1, 45, true);

      string Notice_Symbol = (string) GetGlobalVariable(SendTeleMsg_ + symbol);
      string key_d1_buy = (string)PERIOD_D1 + (string)OP_BUY;
      string key_d1_sel = (string)PERIOD_D1 + (string)OP_SELL;

      if(is_reset_time)
        {
         if(trend_stoc_21_d1 == TREND_BUY)
           {
            Notice_Symbol = key_d1_sel;
            GlobalVariableSet(SendTeleMsg_ + symbol, (double)Notice_Symbol);
           }

         if(trend_stoc_21_d1 == TREND_SEL)
           {
            Notice_Symbol = key_d1_buy;
            GlobalVariableSet(SendTeleMsg_ + symbol, (double)Notice_Symbol);
           }
         return;
        }

      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

      string str_profit = "";
      string trading_trend = "";
      double total_profit = 0;
      int count_L = 0, cur_count_limit = 0, count_limit = 0, count_all_limit = 0, count_buy = 0, count_sel = 0, count_tp_1d = 0;
      if(is_same_symbol(symbol, STR_SYMBOLS_OPENING))
         for(int i = OrdersTotal() - 1; i >= 0; i--)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
              {
               if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                  count_all_limit += 1;

               if(is_same_symbol(OrderSymbol(), symbol))
                 {
                  string find_trend = (OrderType() == OP_BUY)?TREND_BUY:(OrderType() == OP_SELL)?TREND_SEL:"";

                  trading_trend += find_trend;
                  total_profit += OrderProfit() + OrderSwap() + OrderCommission();

                  if(OrderType() == OP_BUY)
                     count_buy += 1;
                  if(OrderType() == OP_SELL)
                     count_sel += 1;
                  if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                     count_L += 1;

                  if(is_same_symbol(OrderComment(), MASK_TP1D))
                     if(OrderType() == OP_BUY || OrderType() == OP_SELL)
                        count_tp_1d += 1;

                  if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                     cur_count_limit += 1;
                 }

               if(is_same_symbol(Symbol(), OrderSymbol()))
                  if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                     count_limit += 1;
              }

      string strCountBSL = "";
      if(count_buy > 0)
         strCountBSL += (string)count_buy + "B";
      if(count_sel > 0)
         strCountBSL += (string)count_sel + "S";
      if(cur_count_limit > 0)
         strCountBSL += ".L" + (string)cur_count_limit;

      if(count_L > 0)
         str_profit = " $" + (total_profit > 0 ? "+":"") + (string)(int)total_profit + to_percent(total_profit, 1);

      if(count_limit > 0)
         createButton(BtnCloseLimit, "Close " + (string) count_limit + " Limit", 5, chart_heigh-70, 150, 20, clrBlack, clrWhite, 7);

      if(count_all_limit > 0)
         createButton(BtnCloseAllLimit, "Close All " + (string) count_all_limit + " Limit", 5, chart_heigh-120, 150, 20, clrBlack, clrWhite, 7);

      CandleData temp_array_H4[];
      get_arr_heiken(symbol, PERIOD_H4, temp_array_H4, 15, true);

      CandleData temp_array_H1[];
      get_arr_heiken(symbol, PERIOD_H1, temp_array_H1, 15, true);

      string trend_by_ma10d_vs_ma10w = temp_array_D1[0].ma10 > temp_array_D1[0].ma10 ? TREND_BUY : TREND_SEL;

      string trend_by_macd_d1 = "", trend_mac_vs_signal_d1 = "", trend_mac_vs_zero_d1 = "", trend_vector_histogram_d1 = "", trend_vector_signal_d1 = "", trend_macd_note_d1="";
      get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_D1, trend_by_macd_d1, trend_mac_vs_signal_d1, trend_mac_vs_zero_d1, trend_vector_histogram_d1, trend_vector_signal_d1, trend_macd_note_d1);

      int count_d10 = temp_array_D1[0].count_ma10;
      int count_hei_d1 = temp_array_D1[0].count_heiken;
      int count_hei_h4 = temp_array_H4[0].count_heiken;
      int count_hei_h1 = temp_array_H1[0].count_heiken;

      string trend_by_ma10_h4 = temp_array_H4[0].trend_by_ma10;
      string trend_by_ma10_d1 = temp_array_D1[0].trend_by_ma10;
      string trend_heiken_d1 = temp_array_D1[0].trend_heiken;
      string trend_heiken_h4 = temp_array_H4[0].trend_heiken;
      string trend_heiken_h1 = temp_array_H1[0].trend_heiken;
      string trend_ma10vs20_d1 = temp_array_D1[0].trend_ma10vs20;
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      if(is_same_symbol(Notice_Symbol, key_d1_buy) && is_same_symbol(Notice_Symbol, key_d1_sel))
         GlobalVariableSet(SendTeleMsg_ + symbol, -1);
      else
         if(is_same_symbol(Notice_Symbol, key_d1_buy) || is_same_symbol(Notice_Symbol, key_d1_sel))
           {
            string find_trend = is_same_symbol(Notice_Symbol, key_d1_buy)? TREND_BUY :
                                is_same_symbol(Notice_Symbol, key_d1_sel) ? TREND_SEL : "";

            if(find_trend == trend_stoc_21_d1 &&
               find_trend == temp_array_D1[0].trend_heiken &&
               find_trend == temp_array_H4[0].trend_heiken &&
               find_trend == temp_array_H1[0].trend_heiken)
              {
               StringReplace(Notice_Symbol, key_d1_buy, "");
               StringReplace(Notice_Symbol, key_d1_sel, "");
               GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);

               SendTelegramMessage(symbol, find_trend, SendTeleMsg_ + symbol + " D1 " + find_trend, true);

               OpenChartWindow(symbol);
              }
           }
      //----------------------------------------------------------------------------------
      string key_h4_buy = (string)PERIOD_H4 + (string)OP_BUY;
      string key_h4_sel = (string)PERIOD_H4 + (string)OP_SELL;
      if(is_same_symbol(Notice_Symbol, key_h4_buy) && is_same_symbol(Notice_Symbol, key_h4_sel))
         GlobalVariableSet(SendTeleMsg_ + symbol, -1);
      else
         if(is_same_symbol(Notice_Symbol, key_h4_buy) || is_same_symbol(Notice_Symbol, key_h4_sel))
           {
            bool allow_send_h4 = false;
            string find_trend = is_same_symbol(Notice_Symbol, key_h4_buy)? TREND_BUY : is_same_symbol(Notice_Symbol, key_h4_sel) ? TREND_SEL : "";

            if(find_trend == trend_stoc_21_h4 &&
               find_trend == temp_array_H4[0].trend_heiken &&
               find_trend == temp_array_H1[0].trend_heiken &&
               (temp_array_H4[0].count_heiken < 3 || temp_array_H4[0].count_ma10 < 3 || count_stoc_21_h4 <= 3))
               allow_send_h4 = true;

            if(allow_send_h4)
              {
               StringReplace(Notice_Symbol, key_h4_buy, "");
               StringReplace(Notice_Symbol, key_h4_sel, "");
               GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);

               SendTelegramMessage(symbol, find_trend, SendTeleMsg_ + symbol + " H4 " + find_trend, true);

               OpenChartWindow(symbol);
              }
           }
      //----------------------------------------------------------------------------------
      string key_h1_buy = (string)PERIOD_H1 + (string)OP_BUY;
      string key_h1_sel = (string)PERIOD_H1 + (string)OP_SELL;
      if(is_same_symbol(Notice_Symbol, key_h1_buy) && is_same_symbol(Notice_Symbol, key_h1_sel))
         GlobalVariableSet(SendTeleMsg_ + symbol, -1);
      else
         if(is_same_symbol(Notice_Symbol, key_h1_buy) || is_same_symbol(Notice_Symbol, key_h1_sel))
           {
            bool allow_send_h1 = false;
            string find_trend = is_same_symbol(Notice_Symbol, key_h1_buy)? TREND_BUY : is_same_symbol(Notice_Symbol, key_h1_sel) ? TREND_SEL : "";

            if(find_trend == trend_stoc_21_h4 &&
               find_trend == temp_array_H4[0].trend_heiken &&
               find_trend == temp_array_H1[0].trend_heiken &&
               (temp_array_H1[0].count_heiken < 3 || temp_array_H1[0].count_ma3_vs_ma5 < 3 ||
                temp_array_H1[0].count_ma10 < 3 || count_stoc_21_h4 < 3))
               allow_send_h1 = true;

            if(allow_send_h1)
              {
               StringReplace(Notice_Symbol, key_h1_buy, "");
               StringReplace(Notice_Symbol, key_h1_sel, "");
               GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);

               SendTelegramMessage(symbol, find_trend, SendTeleMsg_ + symbol + " H1 " + find_trend, true);

               OpenChartWindow(symbol);
              }
           }
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      if(total_profit > minimum_profit)
        {
         string key_d_count = "_" + (string)count_d10 + "_";
         string day_stop_trade = get_day_stop_trade(symbol, true);
         if(is_same_symbol(day_stop_trade, key_d_count))
           {
            string trend_reverse_d1 = get_trend_reverse(trend_stoc_21_d1);
            string oo_h4 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_H4);
            if(is_same_symbol(oo_h4, trend_reverse_d1))
              {
               string oo_h1 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_H1);
               if(is_same_symbol(oo_h1, trend_reverse_d1))
                 {
                  string oo_05 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_M5);
                  if(is_same_symbol(oo_05, trend_reverse_d1))
                     if(ClosePositivePosition(symbol, trend_stoc_21_d1))
                        SendTelegramMessage(symbol, trend_stoc_21_d1, "TAKE_PROFIT " + symbol
                                            + " by count_d10=" + (string)count_d10
                                            + " Profit: " + (string)(int) total_profit, true);
                 }
              }
           }
        }
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      string mask_d1 = "";
      if(is_same_symbol(trend_buy_sel_d1, trend_stoc_21_d1) == false)
         mask_d1 = MASK_DANGER ;

      string mask_h4 = "";
      if(is_same_symbol(trend_buy_sel_h4, trend_stoc_21_d1) == false)
         mask_h4 = MASK_DANGER ;

      if((mask_d1+mask_h4 != MASK_DANGER+MASK_DANGER) && trend_stoc_21_d1 == trend_heiken_h1)
        {
         if(trend_stoc_21_d1 == trend_stoc_21_h4 && trend_stoc_21_d1 == trend_heiken_h1 && count_hei_h1 <= 3)
            if(trend_stoc_21_d1 == get_trend_by_stoc2(symbol, PERIOD_H1, 21, 7, 7, 1))
              {
               int num_h1 = ArraySize(arrNoticeSymbols_H1);
               ArrayResize(arrNoticeSymbols_H1, num_h1+1);
               string lblDH1Stoc21 = str_profit
                                     + " " + mask_d1 + " D." + (string)count_stoc_21_d1
                                     + " (H1) Hei." + (string)count_hei_h1
                                     + " " + trend_stoc_21_d1 + "~" + symbol;

               arrNoticeSymbols_H1[num_h1] = lblDH1Stoc21;

               CheckSendTeleSeqToday(symbol, PERIOD_H1, lblDH1Stoc21);

               if(is_cur_tab)
                 {
                  lblDH1Stoc21 = "(" + (string)count_tp_1d + "L) " + lblDH1Stoc21;

                  execBtnTradeByH1(lblDH1Stoc21, false);
                  createButton(BtnTradeNowTp1D, lblDH1Stoc21, (int)(chart_width/2) - 150, (int)(chart_heigh/2), 300, 20, clrBlack, count_tp_1d == 0 ? clrActiveBtn : clrLightGray, 6);
                 }
              }

         //----------------------------------------------------------------------------------
         if(trend_stoc_21_d1 == trend_stoc_21_h4 && trend_stoc_21_d1 == trend_heiken_h4 &&
            (count_hei_h4 <= 3 || count_stoc_21_h4 <= 3 || temp_array_H4[0].count_ma10 <= 3))
           {
            int num_h4 = ArraySize(arrNoticeSymbols_H4);
            ArrayResize(arrNoticeSymbols_H4, num_h4+1);

            string lblDH4Stoc21 = str_profit
                                  + " " + mask_d1 + "D." + (string)count_hei_d1
                                  + " " + mask_h4 + "H4." + (string)count_hei_h4
                                  + " " + trend_stoc_21_d1 + "~" + symbol;

            arrNoticeSymbols_H4[num_h4] = lblDH4Stoc21;

            if(is_same_symbol(lblDH4Stoc21, MASK_DANGER) == false)
               CheckSendTeleSeqToday(symbol, PERIOD_H4, lblDH4Stoc21);
           }
        }
      //----------------------------------------------------------------------------------
      string notice_d1 = "";
      if(1 <= count_hei_d1 && count_hei_d1 <= 3 && trend_heiken_d1 == trend_stoc_21_d1)
         notice_d1 = " Hei " + getShortName(trend_stoc_21_d1) + "." + (string) count_hei_d1 + " ~" + symbol;
      else
         if(1 <= count_d10 && count_d10 <= 3 && trend_by_ma10_d1 == trend_stoc_21_d1)
            notice_d1 = " Ma " + getShortName(trend_stoc_21_d1) + "." + (string) count_d10 + " ~" + symbol;
         else
            if(count_stoc_21_d1 <= 3)
               notice_d1 = " Sto " + getShortName(trend_stoc_21_d1) + "." + (string) count_stoc_21_d1 + " ~" + symbol;

      if(notice_d1 != "")
        {
         if(is_same_symbol(trend_buy_sel_d1, trend_stoc_21_d1) == false)
            notice_d1 = MASK_DANGER + notice_d1;

         int num_symbols = ArraySize(arrNoticeSymbols_D);
         ArrayResize(arrNoticeSymbols_D, num_symbols+1);

         strNoticeSymbols += symbol + ".";
         arrNoticeSymbols_D[num_symbols] = str_profit + notice_d1;
        }
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      //----------------------------------------------------------------------------------
      color clrD10 = trend_stoc_21_d1 == TREND_BUY ? clrBlue : clrRed;

      string lblWeek = "";
      bool pass_count_cond_d10 = (count_d10 <= 3) || (count_stoc_21_d1 <= 3);

      string lblBtn10 = symbol + " " + getShortName(trend_stoc_21_d1) + "" + (string)(count_d10) + "";
      if(count_L > 0)
         lblBtn10 += str_profit;
      lblBtn10 += strCountBSL;

      color clrBackground = pass_count_cond_d10 ? clrLightGreen : pass_count_cond_d10 ? clrYellowGreen : clrLightGray;
      if(is_cur_tab)
         clrBackground = clrPaleTurquoise;

      string strErrPosition = "";
      if(count_L > 0 && trend_stoc_21_d1 != "")
         strErrPosition = (!is_same_symbol(trading_trend, trend_stoc_21_d1) ? " Sto21." + getShortName(trend_stoc_21_d1):"")
                          +(!is_same_symbol(trading_trend, trend_heiken_d1) ? " Hei." + getShortName(trend_heiken_d1):"")
                          +(!is_same_symbol(trading_trend, temp_array_D1[0].trend_by_ma10) ? " Ma10." + getShortName(temp_array_D1[0].trend_by_ma10):"");
      if(strErrPosition != "")
        {
         clrBackground = clrYellow;
         if(is_cur_tab)
           {
            int chart_macd_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 1))/5;
            string lblErrPosition = strCountBSL + " != (D)" + strErrPosition;

            createButton("ErrPosition", lblErrPosition, chart_width - 265, chart_macd_heigh+5, 260, chart_macd_heigh*3-7, clrBlack, clrYellow, 8, 1);
           }
        }

      string strLblBtnTradeBySeqH4 = "";
      color clrText = total_profit > 0 ? clrBlue : (MathAbs(total_profit) > risk_1p/10) ? clrFireBrick : clrBlack;


      string strLblAppend = "";
      if(trend_stoc_21_d1 == trend_stoc_21_h4 && count_stoc_21_h4 <= 3)
        {
         strLblAppend= " OK(h4).";

         if((GetGlobalVariable(BtnTradeByWaitH4 + symbol) != -1))
            if(is_same_symbol(get_trend_allow_trade_now_by_stoc(symbol, PERIOD_M5), trend_stoc_21_d1))
              {
               GlobalVariableSet(BtnTradeByWaitH4 + symbol, -1);
               SendTelegramMessage(symbol, trend_stoc_21_d1, BtnTradeByWaitH4 + symbol + " " + trend_stoc_21_d1 + strLblAppend, true);
              }
        }

      btn_heigh = index == 0 ? 80 : 20;
      if(index == 0 && size < 22)
         btn_heigh = 80;
      if(index == 0 && size >= 22)
         btn_heigh = 110;

      if(index == 0)
         lblBtn10 += " " + format_double_to_string(SymbolInfoDouble(symbol, SYMBOL_BID), 1) + "$";
      if(index == 8)
        {count = 0; x = btn_width+10; y = 35; btn_heigh = 20;}
      if(index == 15)
        {count = 0; x = btn_width+10; y = 65; btn_heigh = 20;}
      if(index == 21)
        {count = 0; x = btn_width+10; y = 95; btn_heigh = 20;}

      int sub_window = 3;
      createButton(BtnD10 + symbol, lblBtn10, x + (btn_width + 5)*count, is_cur_tab && (index > 0) ? y - 7 : y, btn_width, (index == 0) ? btn_heigh : is_cur_tab ? btn_heigh+15 : btn_heigh, clrText, clrBackground, 7, sub_window);

      if(is_same_symbol(symbol, STR_SYMBOLS_OPENING))
         createButton("_" + symbol, "", x + (btn_width + 5)*count, y + (is_cur_tab ? 3 : 0) + btn_heigh, btn_width, 5, clrBlack, clrLightGreen, 8, sub_window);
      count += 1;

      double vol = 0;
      if(is_cur_tab)
        {
         double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
         double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
         double price = (bid+ask)/2;

         Comment(GetComments());
         ObjectSetString(0, BtnD10 + symbol, OBJPROP_FONT, "Arial Bold");
         ObjectSetInteger(0, BtnD10 + symbol, OBJPROP_COLOR, clrText);

         createButton(BtnTpDay_06_07, "D 06 07", 10, chart_1_2_heigh-25*2, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_06_07 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_13_14, "D 13 14", 10, chart_1_2_heigh-25*1, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_13_14 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_20_21, "D 20 21", 10, chart_1_2_heigh-25*0, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_20_21 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_27_28, "D 27 28", 10, chart_1_2_heigh+25*1, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_27_28 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);
         createButton(BtnTpDay_34_35, "D 34 35", 10, chart_1_2_heigh+25*2, 60, 20, clrBlack, GetGlobalVariable(BtnTpDay_34_35 + "_" + Symbol()) > 0 ? clrActiveBtn : clrWhite, 7);

         double sl_buy = calc_SL_7d_for_trade_arr(symbol, temp_array_D1, TREND_BUY, amp_w1);
         double sl_sel = calc_SL_7d_for_trade_arr(symbol, temp_array_D1, TREND_SEL, amp_w1);
         create_lable("AMP_W1_BUY", TimeCurrent()-TIME_OF_ONE_W1_CANDLE, sl_buy, "---------------------------------------------- w", trend_stoc_21_d1 == TREND_BUY ? TREND_SEL : TREND_BUY);
         create_lable("AMP_W1_SEL", TimeCurrent()-TIME_OF_ONE_W1_CANDLE, sl_sel, "---------------------------------------------- w", trend_stoc_21_d1 == TREND_BUY ? TREND_BUY : TREND_SEL);

         double tp_buy1 = price + amp_d1;
         double tp_sel1 = price - amp_d1;
         double tp_buy2 = price + amp_d1*2;
         double tp_sel2 = price - amp_d1*2;
         double tp_buy3 = price + amp_d1*3;
         double tp_sel3 = price - amp_d1*3;
         create_lable("TP_1D", TimeCurrent(), trend_stoc_21_d1 == TREND_BUY ? tp_buy1 : tp_sel1, "--------------------1", TREND_BUY);
         create_lable("TP_2D", TimeCurrent(), trend_stoc_21_d1 == TREND_BUY ? tp_buy2 : tp_sel2, "--------------------2", TREND_BUY);
         create_lable("TP_3D", TimeCurrent(), trend_stoc_21_d1 == TREND_BUY ? tp_buy3 : tp_sel3, "--------------------3", TREND_BUY);

         if(is_same_symbol(strTrade_Symbols_H4, symbol))
           {
            color clrBtnTradeBySeqH4 = is_same_symbol(strLblBtnTradeBySeqH4, TREND_BUY) ? clrBlue : clrRed;
            createButton(BtnTradeBySeqH4, strLblBtnTradeBySeqH4, int(chart_width/2) - 150, chart_1_2_heigh, 300, 20, clrBtnTradeBySeqH4, clrWhite, 7);

            execBtnTradeBySeqH4(strLblBtnTradeBySeqH4, false);
           }

         vol = calc_volume_by_amp(symbol, amp_w1, risk_1p);

         double valueH4 = GetGlobalVariable(BtnTradeByWaitH4 + symbol);
         color clrColorH4 = (valueH4 != -1) ? clrActiveBtn : trend_stoc_21_d1 == trend_stoc_21_h4 ? clrWhite : clrSilver;

         string lblBtnH4 = symbol;
         lblBtnH4 += " D21." + trend_stoc_21_d1 + ".c" + (string)count_stoc_21_d1;
         if(trend_stoc_21_d1 == trend_stoc_21_h4)
            lblBtnH4 += " H4."  + trend_stoc_21_h4 + ".c" + (string)count_stoc_21_h4;
         else
           {
            lblBtnH4 += " Wait ";
            lblBtnH4 += (valueH4 == OP_BUY ? TREND_BUY : valueH4 == OP_SELL ? TREND_SEL : "") + " H4.c1 -> " + trend_stoc_21_d1;
           }
         lblBtnH4 += strLblAppend;

         string lblBtnD1 = MASK_D10 + " Ma10." + trend_stoc_21_d1 + " " + symbol + " 1%(" + (string)(int) risk_1p + "$) " + format_double_to_string(vol, 2) + " lot. " + strCountBSL;
         createButton(BtnTradeByStoD21, lblBtnD1, int(chart_width/2) - 300, (trend_stoc_21_d1 == TREND_BUY ? chart_heigh-50 : 50), 300, 20, trend_stoc_21_d1 == TREND_BUY ? clrBlue : clrFireBrick, clrActiveBtn, 6);
         createButton(BtnTradeByWaitH4, lblBtnH4, int(chart_width/2) + 010, (trend_stoc_21_d1 == TREND_BUY ? chart_heigh-50 : 50), 300, 20, is_same_symbol(strLblAppend, "OK") ? clrBlue : clrBlack, clrColorH4, 6);

         string strLblTP = "(Close) ";
         if(count_buy > 0)
            strLblTP += (string)count_buy + "B";
         if(count_sel > 0)
            strLblTP += (string)count_sel + "S";
         strLblTP += " " + symbol + " $" + (total_profit>0?"+":"") + (string)(int) total_profit + " ";

         if(count_L > 0)
            createButton(BtnCloseSymbol, strLblTP, 5, chart_heigh-25, 200, 20,
                         total_profit > 0 ? clrBlue:clrBlack,
                         total_profit > 0 ? clrWhite:clrLightGray, 7);

        }

      // Send Message
      if(pass_count_cond_d10)
        {
         prefix_msg = symbol + " " + trend_stoc_21_d1 + " D(" + (string)count_d10 + ")";
         string msg = "";
         if(trend_stoc_21_d1 == temp_array_H4[0].trend_heiken && trend_stoc_21_d1 == temp_array_H1[0].trend_heiken)
           {
            if(temp_array_H4[0].count_ma10 <= 3)
               msg += " MaH4(" + (string)temp_array_H4[0].count_ma10 + ")";

            if(temp_array_H4[0].count_heiken <= 3)
               msg += " HeiH4(" + (string)temp_array_H4[0].count_heiken + ")";
           }

         if(msg != "")
            master_msg += prefix_msg + "\n" +  msg;
        }
     }

   if(master_msg != "")
      SendTelegramMessage("D10", "OPEN_TRADE", master_msg, false);
//------------------------------------------------------------------
   for(int index = 0; index < size; index++)
      ObjectDelete(0, BtnNoticeH4 + getSymbolAtIndex(index));

   int row_index = 0;
   for(int index = 0; index < ArraySize(arrNoticeSymbols_H4); index++)
     {
      string strLable = arrNoticeSymbols_H4[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, "$+") ? clrBlue : is_same_symbol(strLable, "$-") ? clrFireBrick : clrBlack;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen : is_same_symbol(strLable, " 0L ") ? clrWhite : clrLightGray;

      createButton(BtnNoticeH4 + symbol, strLable, 150, 50+row_index*25, 300, 20, clrText, clrBg, 7);
      row_index += 1;
     }
//------------------------------------------------------------------
   for(int index = 0; index < size; index++)
      ObjectDelete(0, BtnNoticeH1 + getSymbolAtIndex(index));

   for(int index = 0; index < ArraySize(arrNoticeSymbols_H1); index++)
     {
      string strLable = arrNoticeSymbols_H1[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, "$+") ? clrBlue : is_same_symbol(strLable, "$-") ? clrFireBrick : clrBlack;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen : is_same_symbol(strLable, " 0L ") ? clrWhite : clrLightGray;

      createButton(BtnNoticeH1 + symbol, strLable, 460, 50+index*25, 300, 20, clrText, clrBg, 7);
     }
//------------------------------------------------------------------
   int count_row = 0;
   int count_col = 0;
   for(int index = 0; index < size; index++)
      ObjectDelete(0, BtnNoticeD1 + getSymbolAtIndex(index));

   for(int index = 0; index < ArraySize(arrNoticeSymbols_D); index++)
     {
      string strLable = arrNoticeSymbols_D[index];
      string symbol = RemoveCharsBeforeTilde(strLable);
      color clrText = is_same_symbol(strLable, "$+") ? clrBlue : clrBlack;
      color clrBg = is_same_symbol(symbol, Symbol()) ? clrLightGreen :
                    is_same_symbol(strLable, MASK_DANGER) ? clrLightGray :
                    is_same_symbol(strLable, "$") ? clrLightGray : clrWhite;

      createButton(BtnNoticeD1 + symbol, strLable, (btn_width+5)*count_col + 5, count_row*25+10, btn_width, 20, clrText, clrBg, 7, 4);
      count_col+=1;
      if(index == 7 || index == 15)
        { count_row+=1; count_col = 0; }
     }

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void draw_trend_macd(string symbol, ENUM_TIMEFRAMES TIMEFRAME, color clrColor)
  {
   int sub_window = 1;
   double min_value=0, max_value=0;
   string TF = get_timeframe_name(TIMEFRAME);

   for(int i = 0; i < 250; i++)
     {
      datetime time_i = (i == 0) ? TimeCurrent() : iTime(symbol, TIMEFRAME, i);
      datetime time_pre_i = iTime(symbol, TIMEFRAME,i+1);

      double hist_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_MAIN, i);
      double sign_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i);

      double hist_pre_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_MAIN, i+1);
      double sign_pre_i = iMACD(symbol, TIMEFRAME,12,26,9,PRICE_CLOSE,MODE_SIGNAL,i+1);

      if(i==0 || min_value < hist_i)
         min_value = hist_i;
      if(i==0 || max_value > hist_i)
         max_value = hist_i;

      string trend_di = (hist_i > sign_i ? TREND_BUY : TREND_SEL);
      color  color_di = trend_di == TREND_BUY ? clrBlue : clrRed;
      if(i == 0)
        {
         int x, y;
         int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS)-1;

         int y_start = (int)(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, sub_window));

         if(TIMEFRAME == PERIOD_D1)
            y_start = 10;
         if(TIMEFRAME == PERIOD_H4)
            y_start = (int)(y_start/2) - 10;
         if(TIMEFRAME == PERIOD_H1)
            y_start = (int)(y_start) - 30;

         if(ChartTimePriceToXY(0, 0, TimeCurrent()+TIME_OF_ONE_H4_CANDLE, SymbolInfoDouble(symbol, SYMBOL_BID), x, y))
            createButton("Macd " + TF + "0", "" + TF + ": " + trend_di
                         + " (" + DoubleToStr(hist_i, digits) + ", " + DoubleToStr(sign_i, digits) + ")"
                         , x, y_start, 220, 20, color_di, clrWhite, 7, sub_window);
        }

      create_trend_line("macd_zero_d_" + TF + (string)i, time_i, 0, time_pre_i, 0, clrBlack, STYLE_SOLID, 2, false, false, true, false, sub_window);
      create_trend_line("macd_main_d_" + TF + (string)i, time_i, hist_i, time_pre_i, hist_pre_i, color_di, STYLE_SOLID, 2, false, false, true, false, sub_window);
      create_trend_line("macd_sign_d_" + TF + (string)i, time_i, sign_i, time_pre_i, sign_pre_i, clrColor, STYLE_SOLID, 3, false, false, true, false, sub_window);
     }
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Fibo(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   string TF = "_" + get_timeframe_name(timeframe);

   if(Period() > PERIOD_D1)
     {
      ObjectDelete(0, "TimeZone");
      ObjectDelete(0, "_Fibo_Fan");

      ObjectDelete(0, "date1");
      ObjectDelete(0, "date2");
      ObjectDelete(0, "date3");

      ObjectDelete(0, "count_range1");
      ObjectDelete(0, "count_range2");
      ObjectDelete(0, "count_range3");

      return;
     }

   bool is_draw_h4 = timeframe == PERIOD_H4;

   int itemIdx1 = 0, itemIdx2 = 0, itemIdx3 = 0, itemIdx4 = 0, itemIdx5 = 0;
   int count_item1 = 0, count_item2 = 0, count_item3 = 0, count_item4 = 0, count_item5 = 0;
   string trendIdx1 = "", trendIdx2 = "", trendIdx3 = "", trendIdx4 = "", trendIdx5 = "";
   double maxmin_hist1 = 0, maxmin_hist2 = 0, maxmin_hist3 = 0, maxmin_hist4 = 0, maxmin_hist5 = 0;
   bool found_item1 = false, found_item2 = false, found_item3 = false, found_item4 = false, found_item5 = false;

   int min_candle_count = 3;
   int limit = MathMin(LIMIT_D, iBars(symbol, timeframe)-10);
   for(int i = 1; i < limit; i++)
     {
      double macdHistCurr = iMACD(symbol, timeframe,12,26,9, PRICE_CLOSE, MODE_MAIN, i);
      double macdHistPrev = iMACD(symbol, timeframe,12,26,9, PRICE_CLOSE, MODE_MAIN, i+1);

      string trendHistCurr = macdHistCurr > 0 ? TREND_BUY : TREND_SEL;
      string trendHistPrev = macdHistPrev > 0 ? TREND_BUY : TREND_SEL;

      if(i == 1)
        {
         trendIdx1 = macdHistCurr > 0 ? TREND_BUY : TREND_SEL;
         trendIdx2 = trendIdx1 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx3 = trendIdx2 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx4 = trendIdx3 == TREND_BUY ? TREND_SEL : TREND_BUY;
         trendIdx5 = trendIdx4 == TREND_BUY ? TREND_SEL : TREND_BUY;
        }

      if(!found_item1)
        {
         if(trendIdx1 == trendHistPrev)
           {
            count_item1 += 1;
            if((trendIdx1 == TREND_BUY) && (maxmin_hist1 == 0 || macdHistCurr > maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }

            if((trendIdx1 == TREND_SEL) && (maxmin_hist1 == 0 || macdHistCurr < maxmin_hist1))
              {
               itemIdx1 = i;
               maxmin_hist1 = macdHistCurr;
              }
           }
         else
           {
            found_item1 = true;
           }
        }

      if(found_item1 && !found_item2)
        {
         if(trendIdx2 == trendHistPrev)
           {
            count_item2 += 1;
            if((trendIdx2 == TREND_BUY) && (maxmin_hist2 == 0 || macdHistCurr > maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }

            if((trendIdx2 == TREND_SEL) && (maxmin_hist2 == 0 || macdHistCurr < maxmin_hist2))
              {
               itemIdx2 = i;
               maxmin_hist2 = macdHistCurr;
              }
           }
         else
           {
            if(count_item2 > min_candle_count)
               found_item2 = true;
           }

         if(i == limit-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && !found_item3 && (i<limit-2))
        {
         if(trendIdx3 == trendHistPrev)
           {
            count_item3 += 1;
            if((trendIdx3 == TREND_BUY) && (maxmin_hist3 == 0 || macdHistCurr > maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }

            if((trendIdx3 == TREND_SEL) && (maxmin_hist3 == 0 || macdHistCurr < maxmin_hist3))
              {
               itemIdx3 = i;
               maxmin_hist3 = macdHistCurr;
              }
           }
         else
           {
            if(count_item3 > min_candle_count)
               found_item3 = true;
           }

         if(i == limit-1)
            found_item3 = true;
        }

      if(found_item1 && found_item2 && found_item3 && !found_item4)
        {
         if(trendIdx4 == trendHistPrev)
           {
            count_item4 += 1;
            if((trendIdx4 == TREND_BUY) && (maxmin_hist4 == 0 || macdHistCurr > maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }

            if((trendIdx4 == TREND_SEL) && (maxmin_hist4 == 0 || macdHistCurr < maxmin_hist4))
              {
               itemIdx4 = i;
               maxmin_hist4 = macdHistCurr;
              }
           }
         else
           {
            if(count_item4 > min_candle_count)
               found_item4 = true;
           }

         if(i == limit-1)
            found_item4 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && !found_item5)
        {
         if(trendIdx5 == trendHistPrev)
           {
            count_item5 += 1;
            if((trendIdx5 == TREND_BUY) && (maxmin_hist5 == 0 || macdHistCurr > maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }

            if((trendIdx5 == TREND_SEL) && (maxmin_hist5 == 0 || macdHistCurr < maxmin_hist5))
              {
               itemIdx5 = i;
               maxmin_hist5 = macdHistCurr;
              }
           }
         else
           {
            if(count_item5 > min_candle_count)
               found_item5 = true;
           }

         if(i == limit-1)
            found_item5 = true;
        }

      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5)
         break;
     }

   if(is_draw_h4)
     {
      if(found_item1 && found_item2 && found_item3 && found_item4 && found_item5)
        {
         datetime date1 = iTime(symbol, timeframe, itemIdx1);
         datetime date2 = iTime(symbol, timeframe, itemIdx2);
         datetime date3 = iTime(symbol, timeframe, itemIdx3);
         datetime date4 = iTime(symbol, timeframe, itemIdx4);
         datetime date5 = iTime(symbol, timeframe, itemIdx5);

         double price1 = trendIdx1 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx1) : iLow(symbol, timeframe, itemIdx1);
         double price2 = trendIdx2 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx2) : iLow(symbol, timeframe, itemIdx2);
         double price3 = trendIdx3 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx3) : iLow(symbol, timeframe, itemIdx3);
         double price4 = trendIdx4 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx4) : iLow(symbol, timeframe, itemIdx4);
         double price5 = trendIdx5 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx5) : iLow(symbol, timeframe, itemIdx5);

         datetime date0 = TimeCurrent();
         bool is_draw_date4 = date4 < date3;
         bool is_draw_date5 = date5 < date3;

         create_trend_line("LINE_24" + TF, date4, price4, date2, price2, clrBlueViolet, STYLE_SOLID, 3, false, false);
         create_trend_line("LINE_35" + TF, date5, price5, date3, price3, clrBlueViolet, STYLE_SOLID, 3, false, false);

         double cur_line_24_price = GetTrendlineValueAtCurrentTime("LINE_24" + TF, date0);
         create_trend_line("LINE_24_CUR" + TF, date2, price2, date0, cur_line_24_price, clrBlueViolet, STYLE_SOLID, 3, false, false);

         double cur_line_35_price = GetTrendlineValueAtCurrentTime("LINE_35" + TF, date0);
         create_trend_line("LINE_35_CUR" + TF, date3, price3, date0, cur_line_35_price, clrBlueViolet, STYLE_SOLID, 3, false, false);
        }

      return;
     }

   if(found_item1 && found_item2 && found_item3)
     {
      datetime date1 = iTime(symbol, timeframe, itemIdx1);
      datetime date2 = iTime(symbol, timeframe, itemIdx2);
      datetime date3 = iTime(symbol, timeframe, itemIdx3);

      double price1 = trendIdx1 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx1) : iLow(symbol, timeframe, itemIdx1);
      double price2 = trendIdx2 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx2) : iLow(symbol, timeframe, itemIdx2);
      double price3 = trendIdx3 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx3) : iLow(symbol, timeframe, itemIdx3);

      create_vertical_line("date1", date1, trendIdx1 == TREND_BUY ? clrRed : clrBlue, STYLE_DASHDOTDOT, 1);
      create_vertical_line("date2", date2, trendIdx2 == TREND_BUY ? clrRed : clrBlue, STYLE_DASHDOTDOT, 1);
      create_vertical_line("date3", date3, trendIdx3 == TREND_BUY ? clrRed : clrBlue, STYLE_DASHDOTDOT, 1);

      int count1 = CountD1Candles(symbol, date1, TimeCurrent());
      int count2 = CountD1Candles(symbol, date2, date1);
      int count3 = CountD1Candles(symbol, date3, date2);

      int y_start = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS)) - 25;
      datetime date0 = TimeCurrent();
      int count0 = (int)(count2*0.618);
      if(count0 > count1)
        {
         date0 = AddCandlesToDate(date1, count0);
         //create_vertical_line("date0", date0, clrBlack, STYLE_DASHDOTDOT, 1);

         int x0, y0;
         if(ChartTimePriceToXY(0, 0, date0, Bid, x0, y0))
            createButton("count_range0", (string) count0 + "c " + format_date(date0), x0+5, 5, 120, 20, clrBlack, clrWhite);
        }

      if(count2 > count1)
        {
         date0 = AddCandlesToDate(date1, count2);
         //create_vertical_line("date_cycle_1", date0, clrBlack, STYLE_DASHDOTDOT, 1);

         string count_range0 = ObjectGetString(0, "count_range0", OBJPROP_TEXT);
         count_range0 += " ~ " + (string)count2 + "c " + format_date(date0);
         ObjectSetString(0, "count_range0", OBJPROP_TEXT, count_range0);
         ObjectSetInteger(0, "count_range0", OBJPROP_XSIZE, 240);
        }

      int x1, y1;
      if(ChartTimePriceToXY(0, 0, date1, Bid, x1, y1))
         createButton("count_range1", "[1] " + (string) count1 + "c", x1, y_start, 60, 20, clrBlack, clrWhite);

      int x2, y2;
      if(ChartTimePriceToXY(0, 0, date2, Bid, x2, y2))
         createButton("count_range2", "[2] " + (string) count2 + "c", x2, y_start, 60, 20, clrBlack, clrWhite);

      int x3, y3;
      if(ChartTimePriceToXY(0, 0, date3, Bid, x3, y3))
         createButton("count_range3", "[3] " + (string) count3 + "c", x3, y_start, 60, 20, clrBlack, clrWhite);


      if(found_item4 && found_item5)
        {
         datetime date4 = iTime(symbol, timeframe, itemIdx4);
         datetime date5 = iTime(symbol, timeframe, itemIdx5);
         bool is_draw_date4 = date4 < date3;
         bool is_draw_date5 = date5 < date3;

         double price4 = trendIdx4 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx4) : iLow(symbol, timeframe, itemIdx4);
         double price5 = trendIdx5 == TREND_BUY ? iHigh(symbol, timeframe, itemIdx5) : iLow(symbol, timeframe, itemIdx5);

         int count4 = CountD1Candles(symbol, date4, date3) - 1;
         int count5 = CountD1Candles(symbol, date5, date4) - 1;

         if(is_draw_date4)
            create_vertical_line("date4", date4, trendIdx4 == TREND_BUY ? clrRed : clrBlue, STYLE_DASHDOTDOT, 1);

         if(is_draw_date5)
            create_vertical_line("date5", date5, trendIdx5 == TREND_BUY ? clrRed : clrBlue, STYLE_DASHDOTDOT, 1);

         if(is_draw_date4 && count4 > 7 && count2 > 7)
            create_trend_line("LINE_24", date4, price4, date2, price2, clrBlack, STYLE_SOLID, 3, false, false, true, false);

         if(is_draw_date5 && count3 > 7 && count5 > 7)
            create_trend_line("LINE_35", date5, price5, date3, price3, clrBlack, STYLE_SOLID, 3, false, false, true, false);

         double cur_line_24_price = GetTrendlineValueAtCurrentTime("LINE_24", date0);
         double cur_line_35_price = GetTrendlineValueAtCurrentTime("LINE_35", date0);

         if(is_draw_date4 && cur_line_24_price > 0 && count4 > 7 && count2 > 7)
           {
            create_lable("cur_line_24_price", date0, cur_line_24_price, format_double_to_string(cur_line_24_price, Digits-1));
            create_trend_line("LINE_24_CUR", date2, price2, date0, cur_line_24_price, clrGray, STYLE_SOLID, 3, false, false, true, false);
           }

         if(is_draw_date5 && cur_line_35_price > 0 && count3 > 7 && count5 > 7)
           {
            create_lable("cur_line_35_price", date0, cur_line_35_price, format_double_to_string(cur_line_35_price, Digits-1));
            create_trend_line("LINE_35_CUR", date3, price3, date0, cur_line_35_price, clrGray, STYLE_SOLID, 3, false, false, true, false);
           }

         int x4, y4;
         if(is_draw_date4)
            if(ChartTimePriceToXY(0, 0, date4, Bid, x4, y4))
               createButton("count_range4", "[4] " + (string) count4 + "c", x4, y_start, 60, 20, clrBlack, clrWhite);

         int x5, y5;
         if(is_draw_date5)
            if(ChartTimePriceToXY(0, 0, date5, Bid, x5, y5))
               createButton("count_range5", "[5] " + (string) count5 + "c", x5, y_start, 60, 20, clrBlack, clrWhite);
        }


      if(trendIdx2 == TREND_SEL)
         DrawManualFibonacciRetracement("_Fibo_2", date2, price3, date1, price2);
      if(trendIdx2 == TREND_BUY)
         DrawManualFibonacciRetracement("_Fibo_2", date1, price2, date2, price3);

      if(trendIdx1 == TREND_SEL)
         DrawFibonacciRetracement("_Fibo_1", date1, price2, date2, price1);
      if(trendIdx1 == TREND_BUY)
         DrawFibonacciRetracement("_Fibo_1", date1, price1, date2, price2);


      double price_min = MathMin(price1, price2);
      double price_max = MathMax(price1, price2);
      datetime draw_time = AddCandlesToDate(TimeCurrent(), MathMin(21, count2));
      create_trend_line("LINE_AMP_FIBO", draw_time, price_min, draw_time, price_max, clrDimGray, STYLE_SOLID, 10);
      ObjectSetInteger(0, "LINE_AMP_FIBO", OBJPROP_STATE, true);
      ObjectSetInteger(0, "LINE_AMP_FIBO", OBJPROP_SELECTED, true);
      ObjectSetInteger(0, "LINE_AMP_FIBO", OBJPROP_SELECTABLE, true);

      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);
      draw_time += TIME_OF_ONE_W1_CANDLE;
      double mid = (price_min + price_max)/2;
      price_min = mid - amp_w1/2;
      price_max = mid + amp_w1/2;
      create_trend_line("LINE_AMP_W", draw_time, price_min, draw_time, price_max, clrDimGray, STYLE_SOLID, 10);
      ObjectSetInteger(0, "LINE_AMP_W", OBJPROP_STATE, true);
      ObjectSetInteger(0, "LINE_AMP_W", OBJPROP_SELECTED, true);
      ObjectSetInteger(0, "LINE_AMP_W", OBJPROP_SELECTABLE, true);

      ObjectDelete(0, "_Fibo_Fan");
      if(Period() == PERIOD_D1)
        {
         DrawFibonacciTimeZones("TimeZone", date2, date1, price1);

         if(trendIdx1 == TREND_SEL)
            DrawFibonacciFan("_Fibo_Fan", date2, MathMin(price1, price2), date1, MathMax(price1, price2), clrDimGray);

         if(trendIdx1 == TREND_BUY)
            DrawFibonacciFan("_Fibo_Fan", date2, MathMax(price1, price2), date1, MathMin(price1, price2), clrDimGray);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckSendTeleSeqToday(string symbol, ENUM_TIMEFRAMES TF, string strLable)
  {
   string key = SendTeleSeqMsg_ + symbol;
   string value = get_vn_date() + (string)(is_same_symbol(strLable, TREND_BUY) ? OP_BUY : OP_SELL)
                  + (TF == PERIOD_D1 ? "999" : "")
                  + (TF == PERIOD_H4 ? "240" : "")
                  + (TF == PERIOD_H1 ? "060" : "");

   double sended_value = 0;
   if(GlobalVariableCheck(key))
      sended_value = GlobalVariableGet(key);

   if(sended_value <= 0)
     {
      GlobalVariableSet(key, (double)value);
      SendTelegramMessage(symbol, "SEQ", strLable, true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getMsgSendTeleSeqToday(string symbol)
  {
   string key = SendTeleSeqMsg_ + symbol;
   if(GlobalVariableCheck(key))
     {
      double value = GlobalVariableGet(key);
      string strToday = get_vn_date();
      if(value > 0)
        {
         string strValue = (string)value;
         if(is_same_symbol(strValue, strToday))
           {
            string value_buy_h4 = strToday + (string)OP_BUY  + "240";
            string value_sel_h4 = strToday + (string)OP_SELL + "240";

            if(is_same_symbol(strValue, value_buy_h4))
               return "H4.Seq." + TREND_BUY + "~" + symbol;
            if(is_same_symbol(strValue, value_sel_h4))
               return "H4.Seq." + TREND_SEL + "~" + symbol;

            string value_buy_h1 = strToday + (string)OP_BUY  + "060";
            string value_sel_h1 = strToday + (string)OP_SELL + "060";

            if(is_same_symbol(strValue, value_buy_h1))
               return "H1.Seq." + TREND_BUY + "~" + symbol;
            if(is_same_symbol(strValue, value_sel_h1))
               return "H1.Seq." + TREND_SEL + "~" + symbol;
           }
        }
     }

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Auto_SL_TP()
  {
   double risk_1p = risk_1_Percent_Account_Balance();

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
        {
         string symbol = OrderSymbol();
         string comment = OrderComment();
         double temp_profit = OrderProfit() + OrderSwap() + OrderCommission();


         if(is_same_symbol(comment, MASK_TP1D))
           {

            continue;
           }


         bool is_01_percent_loss = (risk_1p   + temp_profit < 0);
         bool is_03_percent_loss = (risk_1p*3 + temp_profit < 0);

         string msg = symbol + "    " + comment + "    Profit: " + format_double_to_string(temp_profit, 1) + "$";

         if(is_01_percent_loss)
           {
            triple_order(symbol, OrderType());

            if(ClosePositionByTicket(OrderTicket(), symbol))
               SendTelegramMessage(symbol, "SL_BY_AMP", "(TRIPLE_ORDER) SL_BY_AMP: " + msg, true);
           }

         if(is_03_percent_loss)
           {
            if((OrderType() == OP_BUY))
               if(ClosePositionByTicket(OrderTicket(), symbol))
                  SendTelegramMessage(symbol, "STOP_LOSS", (is_03_percent_loss ? "STOP_LOSS" : "TAKE_PROFIT") + " " + msg, true);

            if(OrderType() == OP_SELL)
               if(ClosePositionByTicket(OrderTicket(), symbol))
                  SendTelegramMessage(symbol, "STOP_LOSS", (is_03_percent_loss ? "STOP_LOSS" : "TAKE_PROFIT") + " " + msg, true);
           }
        }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool triple_order(string symbol, int OP_TYPE)
  {
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   int digits = MathMin(5, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

   double risk_1p = risk_1_Percent_Account_Balance();
   double amp_tp = NormalizeDouble(amp_w1*2/3, digits);
   double volume_1p = calc_volume_by_amp(symbol, amp_w1, risk_1p);

   string find_trend = OP_TYPE == OP_BUY ? TREND_BUY : OP_TYPE == OP_SELL ? TREND_SEL : "";
   double TP_1 = OP_TYPE == OP_BUY ? cur_price + amp_tp : OP_TYPE == OP_SELL ? cur_price - amp_tp : 0;
   double TP_2 = OP_TYPE == OP_BUY ? cur_price + amp_tp : OP_TYPE == OP_SELL ? cur_price - amp_tp : 0;
   double TP_3 = 0;

   if(OP_TYPE != -1)
     {
      string comment_1 = MASK_TRIPLE + create_comment(MASK_MARKET, find_trend, 1);
      string comment_2 = MASK_TRIPLE + create_comment(MASK_MARKET, find_trend, 2);
      string comment_3 = MASK_TRIPLE + create_comment(MASK_MARKET, find_trend, 3);

      bool market_ok = Open_Position(symbol, OP_TYPE, volume_1p, 0.0, NormalizeDouble(TP_3, digits), comment_3);

      if(market_ok)
         market_ok   = Open_Position(symbol, OP_TYPE, volume_1p, 0.0, NormalizeDouble(TP_2, digits), comment_2);

      if(market_ok)
         market_ok   = Open_Position(symbol, OP_TYPE, volume_1p, 0.0, NormalizeDouble(TP_1, digits), comment_1);

      if(market_ok)
         return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetGlobalVariable(string varName)
  {
   if(GlobalVariableCheck(varName))
      return GlobalVariableGet(varName);
   return -1;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_day_stop_trade(string symbol, bool hasOpenOrder)
  {
   string result = "";

   if(GetGlobalVariable(BtnTpDay_06_07 + "_" + symbol) > 0)
      result += "_6_7_";
   if(GetGlobalVariable(BtnTpDay_13_14 + "_" + symbol) > 0)
      result += "_13_14_";
   if(GetGlobalVariable(BtnTpDay_20_21 + "_" + symbol) > 0)
      result += "_20_21_";
   if(GetGlobalVariable(BtnTpDay_27_28 + "_" + symbol) > 0)
      result += "_27_28_";
   if(GetGlobalVariable(BtnTpDay_34_35 + "_" + symbol) > 0)
      result += "_34_35_";

   if(result == "" && hasOpenOrder)
     {
      GlobalVariableSet(BtnTpDay_20_21 + "_" + symbol, 1);
      return "_13_14_";
     }

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void do_hedging(string symbol)
  {
   double global_bot_count_hedg_buy = 0;
   double global_bot_count_hedg_sel = 0;
   double total_vol_buy = 0, total_vol_sel = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
           {
            if(OrderType() == OP_BUY)
              {
               total_vol_buy += OrderLots();
               if(is_same_symbol(OrderComment(), MASK_HEDG))
                  global_bot_count_hedg_buy += 1;
              }

            if(OrderType() == OP_SELL)
              {
               total_vol_sel += OrderLots();
               if(is_same_symbol(OrderComment(), MASK_HEDG))
                  global_bot_count_hedg_sel += 1;
              }
           }

   if(MathAbs(total_vol_buy - total_vol_sel) > 0.01)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int OP_TYPE = total_vol_buy > total_vol_sel ? OP_SELL : OP_BUY;
      int count = (int)(total_vol_buy > total_vol_sel ? global_bot_count_hedg_sel : global_bot_count_hedg_buy) + 1;
      string TREND_TYPE = total_vol_buy > total_vol_sel ? TREND_SEL : TREND_BUY;

      double hedg_volume = MathAbs(total_vol_buy - total_vol_sel) - 0.01;
      string hedg_comment = create_comment(MASK_HEDG, TREND_TYPE, count);
      bool hedging_ok = Open_Position(symbol, OP_TYPE, hedg_volume, 0.0, 0.0, hedg_comment);
      if(hedging_ok)
        {
         hedg_comment = create_comment(MASK_HEDG, TREND_TYPE, 0);
         hedging_ok = Open_Position(symbol, OP_TYPE, 0.01, 0.0, 0.0, hedg_comment);

         SendTelegramMessage(symbol, MASK_HEDG, "hedging_ok: " + symbol + "    " + (string)hedg_volume + "lot.", false);
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Open_Position(string symbol, int OP_TYPE, double volume, double sl, double tp, string comment, double priceLimit=0)
  {
//StringToLower(symbol);

   printf("Open_Position symbol: " + symbol + " OP_TYPE:" + (string) OP_TYPE + " volume:"
          + (string) volume + " sl:" + (string) sl + " tp:" + (string) tp + " comment:" + (string) comment);

   ResetLastError();
   int nextticket= 0, demm = 1;
   while(nextticket<=0 && demm < 5)
     {
      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      int slippage = (int)MathAbs(ask-bid)*2;
      double price = NormalizeDouble((bid + ask)/2, Digits);

      if(OP_TYPE == OP_BUY)
         price = ask;
      if(OP_TYPE == OP_SELL)
         price = bid;
      if((OP_TYPE == OP_BUYLIMIT || OP_TYPE == OP_SELLLIMIT) && priceLimit > 0)
         price = priceLimit;

      nextticket = OrderSend(symbol, OP_TYPE, volume, price, slippage, sl, tp, comment, 0, 0, clrBlue);
      if(nextticket > 0)
         return true;
      else
         printf("Open_Position Error:" + (string)GetLastError());
      demm++;
      Sleep(500); //milliseconds
     }

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_main_control_screen()
  {
   int screen_width = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   bool draw_common_btn = screen_width < (140 + 215 + 375) ? false : true; // 1646, 1216 > 800
   return draw_common_btn;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime AddCandlesToDate(datetime date1, int candles)
  {
   int added_days = 0;
   datetime new_date = date1;

   while(candles > 0)
     {
      new_date += 24 * 3600; // Thêm một ngày
      int day_of_week = TimeDayOfWeek(new_date);

      // Kiểm tra nếu ngày mới là ngày trong tuần (không phải thứ Bảy hoặc Chủ Nhật)
      //if(day_of_week != 0 && day_of_week != 6)
        {
         candles--;
        }
     }

   return new_date;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CountD1Candles(string symbol, datetime date_start, datetime date_end)
  {
   int timeframe = PERIOD_D1; // D1 timeframe
   int candle_count = 0;
   int limit = MathMin(LIMIT_D, iBars(symbol, timeframe)-10); // Limit the number of bars to check

   for(int i = 1; i < limit; i++)
     {
      datetime candle_time = iTime(symbol, timeframe, i);

      if(candle_time >= date_start && candle_time <= date_end)
        {
         int day_of_week = TimeDayOfWeek(candle_time);
         candle_count++;

        }
     }

   return candle_count;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciRetracement(string name, datetime time1, double price1, datetime time2, double price2)
  {
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_FIBO, 0, time1, price1, time1, price2);

   ObjectSetInteger(0, name, OBJPROP_COLOR, clrBlack);              // Màu của Fibonacci
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);              // Kiểu đường kẻ (nét đứt)
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);                     // Độ dày của đường kẻ

   double levels[26] = {0.0, 0.118, 0.236, 0.382, 0.5, 0.618, 0.764, 0.882,
                        1.0, 1.236, 1.382, 1.5, 1.618, 2.0, 3.0, 4.0,
                        -0.118, -0.236, -0.382, -0.5, -0.618, -0.764, -0.882, -1.0, -2.0, -3.0
                       };

   int size = ArraySize(levels);
   ObjectSetInteger(0,name,OBJPROP_LEVELS,size);
   for(int i=0; i<size; i++)
     {
      ObjectSetDouble(0, name, OBJPROP_LEVELVALUE,i,levels[i]);
      ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR,i,clrDimGray);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_SOLID);
      ObjectSetString(0,name, OBJPROP_LEVELTEXT,i,DoubleToString(100*levels[i],1) + "% ");

      int width = 1;
      if(levels[i] == 0.0 || levels[i] == 1.0)
         width = 2;
      ObjectSetInteger(0,name,OBJPROP_LEVELWIDTH,i,width);
     }

   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true);


   double amp_fibo = MathAbs(price2 - price1);
   datetime time_max = time1 > time2 ? time1 : time2;
   datetime time_min = time1 > time2 ? time2 : time1;
   create_trend_line(name+"_0", time_min, MathMin(price1, price2) - amp_fibo*0, TimeCurrent(), MathMin(price1, price2) - amp_fibo*0, clrBlack, STYLE_SOLID, 2, false, true);
   create_trend_line(name+"_1", time_min, MathMax(price1, price2) + amp_fibo*0, TimeCurrent(), MathMax(price1, price2) + amp_fibo*0, clrBlack, STYLE_SOLID, 2, false, true);
   create_trend_line(name+"-1", time_max, MathMin(price1, price2) - amp_fibo*1, TimeCurrent(), MathMin(price1, price2) - amp_fibo*1, clrBlack, STYLE_SOLID, 2, false, true);
   create_trend_line(name+"+1", time_max, MathMax(price1, price2) + amp_fibo*1, TimeCurrent(), MathMax(price1, price2) + amp_fibo*1, clrBlack, STYLE_SOLID, 2, false, true);
   create_trend_line(name+"-2", time_max, MathMin(price1, price2) - amp_fibo*2, TimeCurrent(), MathMin(price1, price2) - amp_fibo*2, clrBlack, STYLE_SOLID, 2, false, true);
   create_trend_line(name+"+2", time_max, MathMax(price1, price2) + amp_fibo*2, TimeCurrent(), MathMax(price1, price2) + amp_fibo*2, clrBlack, STYLE_SOLID, 2, false, true);
   create_trend_line(name+"-3", time_max, MathMin(price1, price2) - amp_fibo*3, TimeCurrent(), MathMin(price1, price2) - amp_fibo*3, clrBlack, STYLE_SOLID, 2, false, true);
   create_trend_line(name+"+3", time_max, MathMax(price1, price2) + amp_fibo*3, TimeCurrent(), MathMax(price1, price2) + amp_fibo*3, clrBlack, STYLE_SOLID, 2, false, true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciFan(string name, datetime time1, double price1, datetime time2, double price2, color clrColor)
  {
// Xóa Fibonacci Fan nếu đã tồn tại
   ObjectDelete(0, name);

// Tạo Fibonacci Fan mới
   ObjectCreate(0, name, OBJ_FIBOFAN, 0, time1, price1, time2, price2);

   create_trend_line(name + "0.0", time1, price1, time2, price1, clrBlack, STYLE_SOLID, 2, false, false);

// Đặt các thuộc tính cho Fibonacci Fan
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrNONE);        // Màu của Fibonacci Fan
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);    // Kiểu đường kẻ
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);              // Độ dày của đường kẻ

   double levels[] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.764, 0.882, 1.0, 1.118, 1.236, 1.382, 1.5, 1.618};
   int size = ArraySize(levels);

   ObjectSetInteger(0, name,OBJPROP_LEVELS, 13);
   for(int i = 0; i < size; i++)
     {
      ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, i, levels[i]);
      ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, i, clrColor);
      ObjectSetInteger(0, name, OBJPROP_LEVELSTYLE, i, STYLE_DOT);
      ObjectSetInteger(0, name, OBJPROP_LEVELWIDTH, i, 1);
      //ObjectSetString(0, name, OBJPROP_LEVELTEXT,i, (string)levels[i]); // DoubleToString(levels[i], 1)
     }

   ObjectSetInteger(0, name, OBJPROP_BACK, false);           // Hiển thị ở phía sau
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);      // Không được chọn mặc định
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, false);    // Có thể chọn được
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, true);         // Không ẩn
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawManualFibonacciRetracement(string name, datetime time1, double price1, datetime time2, double price2)
  {
   double values[20] = {0.0, 0.236, 0.382, 0.5, 0.618, 0.764, 1.0, 1.236, 1.382, 1.5, 1.618, 2.0, 3.0, 4.0, -0.236, -0.382, -0.5, -0.618, -1.0, -2.0};

   for(int i = 0; i < 20; i++)
     {
      string line_name = name + "_Level_" + DoubleToString(100*values[i],1)+"%";
      ObjectDelete(0, line_name);
     }

   for(int i = 0; i < 20; i++)
     {
      double level_price = price1 + (price2 - price1) * values[i];
      string line_name = name + "_Level_" + DoubleToString(100*values[i],1)+"%";

      bool ray = false;
      int width = 1;
      int style = STYLE_DOT;

      if(values[i] == 0.0 || values[i] == 1.0 || values[i] == 2.0 || values[i] == 3.0 || values[i] == 4.0 || values[i] == -1.0 || values[i] == -2.0)
         style = STYLE_SOLID;

      create_trend_line(line_name, time1, level_price, time2, level_price, clrBlack, style, width, ray, ray, true);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
datetime GetDateFromFiboTimeLevel(string name, double level)
  {
   datetime date_at_level = ObjectGetTimeByValue(0, name, level);
   return date_at_level;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawFibonacciTimeZones(string name, datetime time1, datetime time2, double price2)
  {
   int x0, y0;
   if(!ChartTimePriceToXY(0, 0, time2, price2, x0, y0))
      return;

   int sub_window;
   datetime      time;
   double        price;
   int chart_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS))-55;

   ChartXYToTimePrice(
      0,            // Chart ID
      x0,           // The X coordinate on the chart
      chart_heigh,  // The Y coordinate on the chart
      sub_window,   // The number of the subwindow
      time,         // Time on the chart
      price         // Price on the chart
   );

   ObjectDelete(0, name);

   ObjectCreate(0, name, OBJ_FIBOTIMES, 0, time1, price, time2, price);

   ObjectSetInteger(0, name, OBJPROP_COLOR, clrNONE);       // Màu của Fibonacci
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);      // Kiểu đường kẻ (nét chấm)
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);              // Độ dày của đường kẻ

   double levels[] = {0.0, 0.236, 0.5, 0.764, 1.0, 1.236, 1.5, 1.764, 2.0, 2.382, 2.5, 2.618, 3.0};
   int levels_count = ArraySize(levels);
   ObjectSetInteger(0, name, OBJPROP_LEVELS, levels_count);

   for(int i = 0; i < levels_count; i++)
     {
      int style = STYLE_DOT;
      if(levels[i] == 0.0 || levels[i] == 1.0 || levels[i] == 2.0 || levels[i] == 3.0)
         style = STYLE_DOT;

      ObjectSetDouble(0, name, OBJPROP_LEVELVALUE, i, levels[i]);
      ObjectSetInteger(0, name, OBJPROP_LEVELCOLOR, i, clrGray);
      ObjectSetInteger(0, name, OBJPROP_LEVELSTYLE, i, style);
      ObjectSetString(0, name, OBJPROP_LEVELTEXT, i, DoubleToString(levels[i], 3));
     }

   ObjectSetInteger(0, name, OBJPROP_BACK, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTED, false);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);
   ObjectSetInteger(0, name, OBJPROP_RAY_RIGHT, true); // Kéo dài qua phải

  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Lines(string symbol)
  {
   if(is_main_control_screen() && is_same_symbol(symbol, Symbol()))
     {
      CandleData arrHeiken_d1[];
      get_arr_heiken(symbol, PERIOD_D1, arrHeiken_d1, 35, true);

      string prifix = "draw_";
      for(int col = 0; col < 91; col ++)
        {
         double low_di = iLow(symbol, PERIOD_D1, col);
         double close_di = iClose(symbol, PERIOD_D1, col);
         double hig_di = iHigh(symbol, PERIOD_D1, col);

         datetime time_di = iTime(symbol, PERIOD_D1, col);
         datetime time_di0 = col == 0 ? TimeCurrent() : iTime(symbol, PERIOD_D1, col-1);

         if(col < ArraySize(arrHeiken_d1))
            GetHighestLowestM5Times(symbol, time_di, time_di0, col);
        }
      //-------------------------------------------------------------------------------------------------
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Heiken(string symbol)
  {
   if(is_same_symbol(symbol, Symbol()) == false)
      return;

   int digits = MathMin(5, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

   datetime time_1w = iTime(symbol, PERIOD_W1, 1) - iTime(symbol, PERIOD_W1, 2);
   datetime time_1d = iTime(symbol, PERIOD_D1, 1) - iTime(symbol, PERIOD_D1, 2);
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_mn1[];
   get_arr_heiken(symbol, PERIOD_MN1, arrHeiken_mn1, 24, true);
   int size_mn1 = ArraySize(arrHeiken_mn1);

   double lowest = 0, highest = 0;
   get_lowest_highest(arrHeiken_mn1, size_mn1, lowest, highest);

   for(int i = -100; i < 100; i++)
      ObjectDelete(0, "support_resistance_" + appendZero100(i));

   if(lowest > 0 && highest > 0)
     {
      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

      int step = (int)((highest-lowest)/amp_w1)+1;
      double amp_draw = (highest-lowest)/step;

      datetime time_fr = TimeCurrent() - TIME_OF_ONE_W1_CANDLE;
      datetime time_to = TimeCurrent();
      for(int i = -10; i < step+10; i++)
        {
         double line = lowest + i*amp_draw;
         create_trend_line("support_resistance_" + appendZero100(i), time_fr, line, time_to, line, clrRed, STYLE_SOLID, 1, true, true, true, false);
        }
     }

   for(int i = 0; i <= 6; i++)
     {
      color clrColorW = clrLightGray;
      if(arrHeiken_mn1[i+1].ma10>0 && arrHeiken_mn1[i].ma10>0)
         create_trend_line("Ma10M_" + append1Zero(i+1) + "_" + append1Zero(i),
                           arrHeiken_mn1[i+1].time, arrHeiken_mn1[i+1].ma10,
                           (i==0?TimeCurrent():arrHeiken_mn1[i].time), arrHeiken_mn1[i].ma10, clrColorW, STYLE_SOLID, 25);

      if(i == 0)
         create_lable("Ma10M", TimeCurrent(), arrHeiken_mn1[0].ma10, "   M " + format_double_to_string(NormalizeDouble(arrHeiken_mn1[0].ma10, digits-1), digits-1));
     }
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_w1[];
   get_arr_heiken(symbol, PERIOD_W1, arrHeiken_w1, 30, true);
   int size_w1 = ArraySize(arrHeiken_w1);
   if(size_w1 > 10)
     {
      for(int i = 0; i < ArraySize(arrHeiken_w1)-5; i++)
        {
         color clrColorW = clrLightGray;
         if(arrHeiken_w1[i+1].ma10>0 && arrHeiken_w1[i].ma10>0)
            create_trend_line("Ma10W_" + append1Zero(i+1) + "_" + append1Zero(i),
                              arrHeiken_w1[i+1].time, arrHeiken_w1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_w1[i].time), arrHeiken_w1[i].ma10, clrColorW, STYLE_SOLID, 20);
         if(i == 0)
            create_lable("Ma10W", TimeCurrent(), arrHeiken_w1[0].ma10, "   W " + format_double_to_string(NormalizeDouble(arrHeiken_w1[0].ma10, digits-1), digits-1));

         string candle_name = "hei_w_" + append1Zero(i);
         datetime time_i2 = arrHeiken_w1[i].time;

         if(Period() > PERIOD_D1)
            continue;

         string trend_w = arrHeiken_w1[i].trend_heiken;

         //double mid = arrHeiken_w1[i].trend_heiken == TREND_BUY ? arrHeiken_w1[i].low : arrHeiken_w1[i].high;
         double mid = (arrHeiken_w1[i].open + arrHeiken_w1[i].close)/2;
         datetime time_i1 = (i == 0) ? time_i2 + time_1w - time_1d : arrHeiken_w1[i-1].time;
         color clrBody = trend_w == TREND_BUY ? clrBlue : trend_w == TREND_SEL ? clrRed : clrNONE;
         color clrColor = trend_w == TREND_BUY ? clrBlue : trend_w == TREND_SEL ? clrRed : clrNONE;

         bool is_fill_body = false;
         if((arrHeiken_w1[i].count_heiken == 7) || (arrHeiken_w1[i].count_heiken == 1))
           {
            clrBody = trend_w == TREND_BUY ? clrLightBlue : clrLightPink;
            //is_fill_body = true;

            create_lable(candle_name + ".No", arrHeiken_w1[i].time, mid, "" + (string)arrHeiken_w1[i].count_heiken, trend_w, true, 15, true);
           }
         else
            create_lable(candle_name + ".No",      arrHeiken_w1[i].time, mid, "   " + (string)arrHeiken_w1[i].count_heiken, trend_w, true, 10, false);

         datetime time_center = ((time_i2+time_i1)/2) - TIME_OF_ONE_H1_CANDLE;
         create_filled_rectangle(candle_name + "_body", time_i2, arrHeiken_w1[i].open, time_i1, arrHeiken_w1[i].close, clrBody, true, is_fill_body, trend_w, 1);
        }
     }
//------------------------------------------------------------------------------------
//------------------------------------------------------------------------------------
   CandleData arrHeiken_d1[];
   get_arr_heiken(symbol, PERIOD_D1, arrHeiken_d1, 180, true);
   if(ArraySize(arrHeiken_d1) > 50)
      for(int i = 0; i < ArraySize(arrHeiken_d1) - 2; i++)
        {
         color clrColorD = clrLightGray;
         if(arrHeiken_d1[i+1].ma10>0 && arrHeiken_d1[i].ma10>0)
            create_trend_line("Ma10D_" + append1Zero(i+1) + "_" + append1Zero(i),
                              arrHeiken_d1[i+1].time, arrHeiken_d1[i+1].ma10,
                              (i==0?TimeCurrent():arrHeiken_d1[i].time), arrHeiken_d1[i].ma10, clrColorD, STYLE_SOLID, 15);

         if(i == 0)
            create_lable("Ma10D", TimeCurrent(), arrHeiken_d1[0].ma10, "   D " + format_double_to_string(NormalizeDouble(arrHeiken_d1[0].ma10, digits-1), digits-1));

         if(Period() > PERIOD_H4)
            continue;

         string candle_name = "hei_d_" + appendZero100(i);

         CandleData candle_i = arrHeiken_d1[i];
         string sub_name = "_" + (string)(i+1) + "_" + (string)i;
         datetime time_i1;

         double realOpen = iOpen(symbol, PERIOD_D1, i);
         datetime time_i2 = iTime(symbol, PERIOD_D1, i);
         if(i == 0)
            time_i1 = time_i2 + time_1d;
         else
            time_i1 = iTime(symbol, PERIOD_D1, i-1);

         double low = NormalizeDouble(iLow(symbol, PERIOD_D1, i), digits-2);
         double hig = NormalizeDouble(iHigh(symbol, PERIOD_D1, i), digits-2);

         string trend_by_time = arrHeiken_d1[i].trend_heiken;

         color clrColor = trend_by_time == TREND_BUY ? clrAliceBlue : trend_by_time == TREND_SEL ? C'235,235,235' : clrNONE;

         create_filled_rectangle(candle_name, time_i2, low, time_i1, hig, clrColor, false);
        }
  }//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_time_zones(string symbol, string &date_fr, string &date_to)
  {
   date_fr = "2023.12.31"; //GetFirstWeekOfCurrentMonth();
   date_to = AddWeeksToDate(date_fr, 13);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string AddWeeksToDate(string date_fr, int weeks)
  {
// Chuyển đổi chuỗi ngày thành kiểu datetime
   datetime date_value = StringToTime(date_fr);

// Lấy thời gian hiện tại
   datetime current_time = TimeCurrent();

// Tính toán số giây trong một tuần
   int seconds_in_week = 7 * 24 * 3600; // 1 tuần có 7 ngày, mỗi ngày có 24 giờ, mỗi giờ có 3600 giây

   datetime new_date_value = date_value;

// Thêm tuần từng tuần một và kiểm tra nếu ngày mới lớn hơn ngày hiện tại
   for(int i = 0; i < weeks; i++)
     {
      new_date_value += seconds_in_week;
      if(new_date_value > current_time)
        {
         new_date_value -= seconds_in_week; // Bỏ tuần cuối cùng nếu nó vượt quá ngày hiện tại
         break;
        }
     }

// Chuyển đổi datetime mới thành chuỗi ngày
   string date_to = TimeToString(new_date_value, TIME_DATE);

   return date_to;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CalculateWeeksBetweenDates(string date_fr, string date_to)
  {
// Chuyển đổi chuỗi ngày thành kiểu datetime
   datetime datetime_fr = StringToTime(date_fr);
   datetime datetime_to = StringToTime(date_to);

// Tính toán chênh lệch thời gian giữa hai ngày dưới dạng số giây
   int seconds_difference = (int)(datetime_to - datetime_fr);

// Tính toán số giây trong một tuần
   int seconds_in_week = 7 * 24 * 3600; // 1 tuần có 7 ngày, mỗi ngày có 24 giờ, mỗi giờ có 3600 giây

// Tính toán số tuần
   int weeks_difference = (int)(seconds_difference / seconds_in_week);

   return weeks_difference;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_TimeZones(string symbol, string date_form, string date_to, int levels = 20)
  {
   string name = "FiboTimeZones_" + symbol;
   ObjectDelete(name);

   ObjectCreate(0, name, OBJ_FIBOTIMES, 0, StringToTime(date_form), 0, StringToTime(date_to), 0);

   ObjectSetInteger(0,name,OBJPROP_LEVELS,levels);
   for(int i = 0; i < levels; i++)
     {
      ObjectSetDouble(0,name,OBJPROP_LEVELVALUE,i,i);
      ObjectSetInteger(0,name,OBJPROP_LEVELCOLOR,i,clrBlack);
      ObjectSetInteger(0,name,OBJPROP_LEVELSTYLE,i,STYLE_DOT);
      ObjectSetString(0,name,OBJPROP_LEVELTEXT,i, i == 0 ? "0" : "");
     }

   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_PERIOD_W1); // OBJ_PERIOD_D1|
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReplaceStringAfter(string str_input, string match_string, string replacement)
  {
// Tìm vị trí của ký tự "$"
   int pos = StringFind(str_input, match_string);

// Nếu không tìm thấy ký tự "$", trả về chuỗi gốc
   if(pos == -1)
      return str_input;

// Tách phần trước và phần sau của ký tự "$"
   string beforeDollar = StringSubstr(str_input, 0, pos + 1);

// Kết hợp phần trước và phần thay thế
   string newString = beforeDollar + replacement;

   return newString;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_max_sel_price(string symbol)
  {
   double max_sel_price = 0;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderType() == OP_SELL))
            if(max_sel_price < OrderOpenPrice())
               max_sel_price = OrderOpenPrice();

   return max_sel_price;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_min_buy_price(string symbol)
  {
   double min_buy_price = MAXIMUM_DOUBLE;

   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderType() == OP_BUY))
            if(min_buy_price > OrderOpenPrice())
               min_buy_price = OrderOpenPrice();

   return min_buy_price;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_CurPrice_Line()
  {
   string symbol = Symbol();
   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;
   create_trend_line("cur_price", TimeCurrent()-TIME_OF_ONE_W1_CANDLE, cur_price, TimeCurrent()+TIME_OF_ONE_W1_CANDLE, cur_price, clrFireBrick, STYLE_DOT, 1, true, true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string RemoveCharsBeforeTilde(string str_input)
  {
   int tilde_pos = StringFind(str_input, "~");
   if(tilde_pos != -1)
      return StringSubstr(str_input, tilde_pos + 1);

   return str_input;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendFiltering(string symbol)
  {
   if(is_same_symbol(symbol, Symbol()) == false)
      return "";

   CandleData arrHeiken_d1[];
   CandleData arrHeiken_h4[];
   CandleData arrHeiken_h1[];

   get_arr_heiken(symbol, PERIOD_D1, arrHeiken_d1, 35, true);
   get_arr_heiken(symbol, PERIOD_H4, arrHeiken_h4, 20, true);
   get_arr_heiken(symbol, PERIOD_H1, arrHeiken_h1, 20, true);

   string result = "";
   result += " Heiken_D1[0]: " + arrHeiken_d1[0].trend_heiken;
   result += "    Ma10[0]: " + arrHeiken_d1[0].trend_by_ma10;
   result += "\n";

   result += " Heiken_H4[0]: " + arrHeiken_h4[0].trend_heiken;
   result += "    Ma10[0]: " + arrHeiken_h4[0].trend_by_ma10;
   result += "\n";

   result += " Heiken_H1[0]: " + arrHeiken_h1[0].trend_heiken;
   result += "    Ma10[0]: " + arrHeiken_h1[0].trend_by_ma10;
   result += "\n";

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ResetStartPrice(bool show_mesage=true)
  {
//   double min_close_heiken_h4 = 0;
//   double max_close_heiken_h4 = 0;
//
//   for(int i = 0; i < ArraySize(arrHeiken_h4); i++)
//     {
//      double close = arrHeiken_h4[i].close;
//      if(i==0 || min_close_heiken_h4 > close)
//         min_close_heiken_h4 = close;
//
//      if(i==0 || max_close_heiken_h4 < close)
//         max_close_heiken_h4 = close;
//     }
//
//   if(trend_by_ma10_d1 == TREND_BUY)
//     {
//      INIT_START_PRICE = arrHeiken_d1[0].ma10; //min_close_heiken_h4;
//      GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
//      ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, INIT_START_PRICE);
//      saveAutoTrade();
//     }
//
//   if(trend_by_ma10_d1 == TREND_SEL)
//     {
//      INIT_START_PRICE = arrHeiken_d1[0].ma10; //max_close_heiken_h4;
//      GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
//      ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, INIT_START_PRICE);
//      saveAutoTrade();
//     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OpenChartWindow(string buttonLabel, ENUM_TIMEFRAMES TIMEFRAME = PERIOD_W1)
  {
   long chartID = 0;
   int size = getArraySymbolsSize();
   for(int index = 0; index < size; index++)
     {
      string cur_symbol = getSymbolAtIndex(index);

      if(is_same_symbol(buttonLabel, cur_symbol))
        {
         chartID=ChartFirst();
         while(chartID >= 0)
           {
            ChartClose(chartID);
            chartID = ChartNext(chartID);
           }

         ChartOpen(cur_symbol, TIMEFRAME);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void execBtnTradeBySeqH4(string buttonLabel, bool isTradeNow)
  {
   string symbol = Symbol();
   if(is_same_symbol(buttonLabel, symbol) == false)
      return;

   string find_trend = is_same_symbol(buttonLabel, TREND_BUY) ? TREND_BUY : is_same_symbol(buttonLabel, TREND_SEL) ? TREND_SEL : "";
   if(find_trend == "")
      return;

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

   CandleData temp_array_D1[];
   get_arr_heiken(symbol, PERIOD_D1, temp_array_D1, 10, true);

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;

   double SL = calc_SL_7d_for_trade_arr(symbol, temp_array_D1, find_trend, amp_w1);
   double amp_sl = MathMax(amp_w1, MathAbs(cur_price - SL));

   double risk_1p = risk_1_Percent_Account_Balance();
   double volume_1p = calc_volume_by_amp(symbol, amp_sl, risk_1p);

   double TP_1 = find_trend == TREND_BUY ? cur_price + amp_d1*1 : find_trend == TREND_SEL ? cur_price - amp_d1*1 : 0;
   double TP_2 = find_trend == TREND_BUY ? cur_price + amp_d1*2 : find_trend == TREND_SEL ? cur_price - amp_d1*2 : 0;
   double TP_3 = find_trend == TREND_BUY ? cur_price + amp_d1*3 : find_trend == TREND_SEL ? cur_price - amp_d1*3 : 0;
   int OP_TYPE = find_trend == TREND_BUY ? OP_BUY : find_trend == TREND_SEL ? OP_SELL : -1;

   if(OP_TYPE != -1)
     {
      create_trend_line("TP_BY_SEQ_L1", TimeCurrent() - TIME_OF_ONE_D1_CANDLE, TP_1, TimeCurrent() + TIME_OF_ONE_D1_CANDLE, TP_1, clrBlue, STYLE_DOT);
      create_trend_line("TP_BY_SEQ_L2", TimeCurrent() - TIME_OF_ONE_D1_CANDLE, TP_2, TimeCurrent() + TIME_OF_ONE_D1_CANDLE, TP_2, clrBlue, STYLE_DOT);
      create_trend_line("TP_BY_SEQ_L3", TimeCurrent() - TIME_OF_ONE_D1_CANDLE, TP_3, TimeCurrent() + TIME_OF_ONE_D1_CANDLE, TP_3, clrBlue, STYLE_DASHDOTDOT);

      if(isTradeNow)
        {
         string msg = buttonLabel + "   VOL 1%: " + (string)volume_1p + "    RISK 1%: " + (string)(int)risk_1p + "$ 1L ?\n";
         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            string comment_1 = MASK_SEQ_H4 + create_comment(MASK_MARKET, find_trend, 1);
            string comment_2 = MASK_SEQ_H4 + create_comment(MASK_MARKET, find_trend, 2);
            string comment_3 = MASK_SEQ_H4 + create_comment(MASK_MARKET, find_trend, 3);

            bool market_ok = Open_Position(symbol, OP_TYPE, volume_1p, 0.0, NormalizeDouble(TP_3, Digits), comment_3);

            if(market_ok)
               market_ok   = Open_Position(symbol, OP_TYPE, volume_1p, 0.0, NormalizeDouble(TP_2, Digits), comment_2);

            if(market_ok)
               market_ok   = Open_Position(symbol, OP_TYPE, volume_1p, 0.0, NormalizeDouble(TP_1, Digits), comment_1);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void execBtnTradeByH1(string buttonLabel, bool isTradeNow)
  {
   string symbol = Symbol();
   if(is_same_symbol(buttonLabel, symbol) == false)
      return;

   string find_trend = is_same_symbol(buttonLabel, TREND_BUY) ? TREND_BUY : is_same_symbol(buttonLabel, TREND_SEL) ? TREND_SEL : "";
   if(find_trend == "")
      return;

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

   CandleData temp_array_h1[];
   get_arr_heiken(symbol, PERIOD_H1, temp_array_h1, 20, true);

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;

   double SL = calc_SL_7d_for_trade_arr(symbol, temp_array_h1, find_trend, amp_d1);
   double amp_sl =MathAbs(cur_price - SL);
   double TP = find_trend == TREND_BUY ? cur_price + amp_sl : find_trend == TREND_SEL ? cur_price - amp_sl : 0;
   int OP_TYPE = find_trend == TREND_BUY ? OP_BUY : find_trend == TREND_SEL ? OP_SELL : -1;

   double risk_1p = risk_250Usc();
   double volume_1p = calc_volume_by_amp(symbol, amp_sl, risk_1p);

   if(OP_TYPE != -1)
     {
      create_lable("SL_H1", TimeCurrent(), SL, "--------------------------------SL(H1)", TREND_SEL);
      create_lable("TP_H1", TimeCurrent(), TP, "--------------------------------TP(H1)", TREND_BUY);

      if(isTradeNow)
        {
         string msg = buttonLabel + "   VOL 1p: " + (string)volume_1p + " lot.    RISK 1p: " + (string)(int)risk_1p + "$?\n";
         int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
         if(result == IDYES)
           {
            string comment_1 = MASK_TP1D + create_comment(MASK_MARKET, find_trend, 1);
            bool market_ok = Open_Position(symbol, OP_TYPE, volume_1p, SL, NormalizeDouble(TP, Digits), comment_1);
           }
        }
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnChartEvent(const int     id,       // event ID
                  const long&   lparam,   // long type event parameter
                  const double& dparam,   // double type event parameter
                  const string& sparam    // string type event parameter
                 )
  {
   string symbol = Symbol();

   switch(id)
     {
      case CHARTEVENT_OBJECT_CLICK:
         if(sparam == START_TRADE_LINE)
           {
            isDragging = true;
            INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
            Print("CHARTEVENT_OBJECT_CLICK " + (string) INIT_START_PRICE);
            GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
           }
         else
            isDragging = false;

         break;

      case CHARTEVENT_OBJECT_DRAG:
         if(sparam == START_TRADE_LINE)
           {
            isDragging = false;
            INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
            Print("CHARTEVENT_OBJECT_DRAG " + (string) INIT_START_PRICE);
            GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
           }
         break;

      case CHARTEVENT_MOUSE_MOVE:
         if(isDragging)
           {
            double newPrice = NormalizeDouble(WindowPriceOnDropped(), Digits);
            if(newPrice > 0)
              {
               ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, newPrice);
               INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
               Print("CHARTEVENT_MOUSE_MOVE "  + (string) INIT_START_PRICE);
               GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
              }
           }
         break;
     }
//-------------------------------------------------------------------------------------------------------
   if(is_same_symbol(sparam, BtnD10))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel, PERIOD_D1);
     }

   if(is_same_symbol(sparam, BtnNoticeDH21) || is_same_symbol(sparam, BtnNoticeD1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel, PERIOD_D1);
     }

   if(is_same_symbol(sparam, BtnTrend))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");
      ENUM_TIMEFRAMES TF = PERIOD_D1;

      if(is_same_symbol(sparam, "W1"))
         TF = PERIOD_W1;
      if(is_same_symbol(sparam, "H4"))
         TF = PERIOD_H4;
      if(is_same_symbol(sparam, "H1"))
         TF = PERIOD_H1;

      OpenChartWindow(sparam + "." + symbol, TF);
     }

   if(is_same_symbol(sparam, BtnNoticeH4) || is_same_symbol(sparam, BtnTradeD10H4) || is_same_symbol(sparam, BtnTradeWma10))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(sparam, BtnTradeWma10))
         OpenChartWindow(buttonLabel, PERIOD_D1);
      else
         OpenChartWindow(buttonLabel, PERIOD_D1);
     }

   if(is_same_symbol(sparam, BtnNoticeH1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      OpenChartWindow(buttonLabel, PERIOD_H1);
     }

   if(is_same_symbol(sparam, BtnSendNotice_D1) ||
      is_same_symbol(sparam, BtnSendNotice_H4) ||
      is_same_symbol(sparam, BtnSendNotice_H1))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);

      if(is_same_symbol(buttonLabel, TREND_BUY) == false && is_same_symbol(buttonLabel, TREND_SEL) == false)
         buttonLabel += TREND_BUY;
      else
         if(is_same_symbol(buttonLabel, TREND_BUY))
            StringReplace(buttonLabel, TREND_BUY, TREND_SEL);
         else
            if(is_same_symbol(buttonLabel, TREND_SEL))
               StringReplace(buttonLabel, TREND_SEL, "");

      ObjectSetString(0, sparam, OBJPROP_TEXT, buttonLabel);

      saveAutoTrade();

      Draw_Buttons_Trend(symbol);
     }

   if(is_same_symbol(sparam, BtnCloseSymbol))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(buttonLabel, symbol) == false)
         return;

      string msg = buttonLabel + "?\n";
      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         ClosePositivePosition(symbol, "");
         Draw_Notice_Ma10D();
        }
     }

   if(is_same_symbol(sparam, BtnCloseAllLimit))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      string msg = buttonLabel + "?\n";
      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);

            ClosePosition(temp_symbol, OP_BUYLIMIT, TREND_BUY);
            ClosePosition(temp_symbol, OP_SELLLIMIT, TREND_SEL);
           }
        }
     }

   if(is_same_symbol(sparam, BtnCloseLimit))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      string msg = symbol + "    " + buttonLabel + "?\n";
      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         ClosePosition(symbol, OP_BUYLIMIT, TREND_BUY);
         ClosePosition(symbol, OP_SELLLIMIT, TREND_SEL);
         Draw_Notice_Ma10D();
        }
     }
   if(is_same_symbol(sparam, BtnCloseAllTicket))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      string msg = "  BtnCloseAllTicket?\n";
      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         int size = getArraySymbolsSize();
         for(int index = 0; index < size; index++)
           {
            string temp_symbol = getSymbolAtIndex(index);
            ClosePosition(temp_symbol, OP_BUY, TREND_BUY);
            ClosePosition(temp_symbol, OP_SELL, TREND_SEL);
            ClosePosition(temp_symbol, OP_BUYLIMIT, TREND_BUY);
            ClosePosition(temp_symbol, OP_SELLLIMIT, TREND_SEL);
           }
         Draw_Notice_Ma10D();
        }
     }
//----------------------------------------------------------------------------------------------------------------
   if(is_same_symbol(sparam, BtnTradeBySeqH4))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      execBtnTradeBySeqH4(buttonLabel, true);
     }
//----------------------------------------------------------------------------------------------------------------

   if(is_same_symbol(sparam, BtnTradeByWaitH4))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      double value = GetGlobalVariable(BtnTradeByWaitH4 + symbol);
      if(value != -1)
         value = -1;
      else
        {
         string trend_stoc_21_d1 = get_trend_by_stoc2(symbol, PERIOD_D1, 21, 7, 7, 0);
         if(trend_stoc_21_d1 == TREND_BUY)
            value = OP_BUY;
         if(trend_stoc_21_d1 == TREND_SEL)
            value = OP_SELL;
        }

      GlobalVariableSet(BtnTradeByWaitH4 + symbol, value);
      Draw_Notice_Ma10D();
     }

   if(is_same_symbol(sparam, BtnTradeNowTp1D))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      execBtnTradeByH1(buttonLabel, true);
     }

   if(is_same_symbol(sparam, BtnTradeByStoD21) || is_same_symbol(sparam, BtnTradeRev10D))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      Print("The lparam=", sparam," dparam=", dparam, " sparam=", sparam, " buttonLabel=", buttonLabel, " was clicked");

      if(is_same_symbol(buttonLabel, Symbol()) == false)
         return;

      string trading_trend = is_same_symbol(buttonLabel, TREND_BUY) ? TREND_BUY : is_same_symbol(buttonLabel, TREND_SEL) ? TREND_SEL : "";
      if(trading_trend == "")
         return;

      double amp_w1, amp_d1, amp_h4, amp_grid_L100;
      GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
      double cur_price = (bid+ask)/2;

      double sl = calc_SL_7d_for_trade_init(symbol, trading_trend, amp_w1);

      double amp_sl = MathMax(amp_w1, MathAbs(cur_price - sl));
      double risk_1p = risk_1_Percent_Account_Balance();
      double vol_1percent = calc_volume_by_amp(symbol, amp_sl, risk_1p);
      double vol_limit = NormalizeDouble(vol_1percent, 2);
      double vol_market = NormalizeDouble(vol_1percent, 2);

      int count_total = 1, count_limit = 0, count_opening = 0;
      for(int i = OrdersTotal() - 1; i >= 0; i--)
         if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
            if(is_same_symbol(OrderSymbol(), symbol))
              {
               count_total += 1;

               if((trading_trend == TREND_BUY && OrderType() == OP_BUYLIMIT) ||
                  (trading_trend == TREND_SEL && OrderType() == OP_SELLLIMIT))
                  count_limit += 1;

               if((trading_trend == TREND_BUY && OrderType() == OP_BUY) ||
                  (trading_trend == TREND_SEL && OrderType() == OP_SELL))
                  count_opening += 1;
              }
      count_limit += 1;
      count_opening += 1;

      double tp_now   = trading_trend == TREND_BUY ? cur_price + amp_w1*count_opening : cur_price - amp_w1*count_opening;
      double tp_limit = trading_trend == TREND_BUY ? cur_price + amp_w1*count_limit   : cur_price - amp_w1*count_limit;

      string mask = "";
      if(is_same_symbol(sparam, BtnTradeByStoD21))
         mask = MASK_D10;
      if(is_same_symbol(sparam, BtnTradeRev10D))
         mask = MASK_REV_D10;

      string comment_market = mask + create_comment(MASK_MARKET, trading_trend, count_total);
      string comment_limit  = mask + create_comment(MASK_LIMIT,  trading_trend, count_total);

      int OP_TYPE = trading_trend == TREND_BUY ? OP_BUY : trading_trend == TREND_SEL ? OP_SELL : -1;
      int OP_LIMIT = trading_trend == TREND_BUY ? OP_BUYLIMIT : trading_trend == TREND_SEL ? OP_SELLLIMIT : -1;
      double price_limit = trading_trend == TREND_BUY ? cur_price-(amp_d1*count_limit) : trading_trend == TREND_SEL ? cur_price+(amp_d1*count_limit) : 0;
      price_limit = NormalizeDouble(price_limit, Digits);

      string strLable = trading_trend + " " + symbol + " Vol 1% = " + format_double_to_string(vol_1percent, 2) + " lot ("+(string)(int)risk_1p+")";
      string msg = strLable + "?\n";
      msg += "(YES) " + comment_market + "    " + format_double_to_string(vol_market, 2) + " lot. Market " "\n";
      msg += "(NO)  " + comment_limit  + "   " + format_double_to_string(vol_limit, 2) + " lot. Limit: " + DoubleToString(price_limit, Digits) + "\n";

      int result = MessageBox(msg, "Confirm", MB_YESNOCANCEL);
      if(result == IDYES)
        {
         if(count_opening > 3)
           {
            Alert("There are 3 open orders so cannot open more.");
            return;
           }

         if(OP_TYPE != -1 && trading_trend != "" && price_limit > 0)
           {
            bool market_ok = Open_Position(Symbol(), OP_TYPE, vol_market, NormalizeDouble(0.0, Digits), NormalizeDouble(tp_now, Digits), comment_market);
            if(market_ok)
               GlobalVariableSet(BtnTpDay_20_21 + "_" + symbol, 1);
            Draw_Notice_Ma10D();
           }
        }

      if(result == IDNO)
        {
         if(count_limit > 3)
           {
            Alert("There are 3 open limit orders so cannot open more.");
            return;
           }

         if(OP_TYPE != -1 && trading_trend != "" && price_limit > 0)
           {
            bool limit_ok = Open_Position(Symbol(), OP_LIMIT, vol_limit, NormalizeDouble(0.0, Digits), NormalizeDouble(0.0, Digits), comment_limit, NormalizeDouble(price_limit, Digits));
            if(limit_ok)
              {
               Draw_Notice_Ma10D();
              }
           }
        }
     }
//-----------------------------------------------------------------------------------------
   if(is_same_symbol(sparam, BtnTpDay_06_07) || is_same_symbol(sparam, BtnTpDay_13_14) ||
      is_same_symbol(sparam, BtnTpDay_20_21) ||
      is_same_symbol(sparam, BtnTpDay_27_28) || is_same_symbol(sparam, BtnTpDay_34_35))
     {
      string key = sparam + "_" + Symbol();
      if(GetGlobalVariable(key) > 0)
         GlobalVariableSet(key, -1);
      else
         GlobalVariableSet(key, 1);

      Draw_Notice_Ma10D();
     }
//-----------------------------------------------------------------------------------------
   if(is_same_symbol(sparam, BtnTelegramMessage))
     {
      string buttonLabel = ObjectGetString(0, sparam, OBJPROP_TEXT);
      OpenChartWindow(buttonLabel);
     }
//-------------------------------------------------------------------------------------------------------
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
      double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

      //-----------------------------------------------------------------------

      //-----------------------------------------------------------------------
      ObjectSetInteger(0, sparam, OBJPROP_STATE, false);
      ChartRedraw();
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_tp_by_fixed_sl_amp(string symbol, string TREND)
  {
   if(TREND == TREND_BUY)
      return iLow(symbol, PERIOD_D1, 0)  + FIXED_SL_AMP*3;
   if(TREND == TREND_SEL)
      return iHigh(symbol, PERIOD_D1, 0) - FIXED_SL_AMP*3;

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_And_ProgressiveProfits(string symbol, string TRADING_TREND, double tp_price, string TRADER)
  {
   double old_tp = 0;
   double old_potential_profit = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
              {
               old_tp = OrderTakeProfit();
               if(TRADING_TREND == TREND_BUY)
                  old_potential_profit += calcPotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
               if(TRADING_TREND == TREND_SEL)
                  old_potential_profit += calcPotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), OrderTakeProfit(), OrderLots());
              }


   double new_tp = tp_price;
   if(old_tp != tp_price)
     {
      int count = 0;
      while(true)
        {
         double new_potential_profit = 0;
         for(int i = OrdersTotal() - 1; i >= 0; i--)
            if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
               if(toLower(symbol) == toLower(OrderSymbol()))
                  if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
                    {
                     if(TRADING_TREND == TREND_BUY)
                        new_potential_profit += calcPotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), new_tp, OrderLots());
                     if(TRADING_TREND == TREND_SEL)
                        new_potential_profit += calcPotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), new_tp, OrderLots());
                    }

         if(new_potential_profit > old_potential_profit)
            break;

         if(TRADING_TREND == TREND_BUY)
            new_tp += AMP_DC;
         if(TRADING_TREND == TREND_SEL)
            new_tp -= AMP_DC;

         count += 1;
         if(count> 100)
            return;
        }
     }

   double BID = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ASK = SymbolInfoDouble(symbol, SYMBOL_ASK);
   int slippage = (int)MathAbs(ASK-BID);

   datetime time_draw = iTime(symbol, PERIOD_H4, 0);
   color lineColor = TRADING_TREND == TREND_BUY ? clrBlue : clrFireBrick;
   create_trend_line(TRADER + TRADING_TREND + "_TP", time_draw, new_tp, time_draw + TIME_OF_ONE_H4_CANDLE, new_tp, lineColor, STYLE_SOLID, 3);

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(toLower(symbol) == toLower(OrderSymbol()))
            if(is_same_symbol(OrderComment(), TRADER) && is_same_symbol(OrderComment(), TRADING_TREND))
              {
               double cur_tp = OrderTakeProfit();
               double opend_price = OrderOpenPrice();

               if(cur_tp != tp_price)
                 {
                  double price = (OrderType() == OP_BUY) ? ASK : (OrderType() == OP_SELL) ? BID : NormalizeDouble((ASK+BID/2), Digits);

                  int ross=0, demm = 1;
                  while(ross<=0 && demm<20)
                    {
                     ross=OrderModify(OrderTicket(),price,OrderStopLoss(),new_tp,0,clrBlue);
                     demm++;
                     Sleep(500);
                    }
                 }

              }

     } //for
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ExceptLock(string symbol, string TRADING_TREND, double tp_price, string TRADER)
  {
   double potential_profit = 0;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol))
            if(StringFind(toLower(OrderComment()), toLower(TRADER)) >= 0)
               if(StringFind(toLower(TRADING_TREND), toLower(TRADING_TREND)) >= 0)
                  if(OrderTakeProfit() != tp_price)
                     if(is_same_symbol(OrderComment(), LOCK) == false &&
                        is_same_symbol(OrderComment(), MASK_HEDG) == false &&
                        is_same_symbol(OrderComment(), "B2S") == false &&
                        is_same_symbol(OrderComment(), "S2B") == false)
                       {
                        double price = SymbolInfoDouble(symbol, SYMBOL_BID);
                        if(OrderType() == OP_BUY)
                          {
                           price = SymbolInfoDouble(symbol, SYMBOL_ASK);
                           potential_profit += calcPotentialTradeProfit(symbol, OP_BUY, OrderOpenPrice(), tp_price, OrderLots());
                          }
                        if(OrderType() == OP_SELL)
                          {
                           price = SymbolInfoDouble(symbol, SYMBOL_BID);
                           potential_profit += calcPotentialTradeProfit(symbol, OP_SELL, OrderOpenPrice(), tp_price, OrderLots());
                          }

                        int ross=0, demm = 1;
                        while(ross<=0 && demm<20)
                          {
                           ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0,clrBlue);
                           demm++;
                           Sleep(500);
                          }
                       }
     } //for

   if(potential_profit < risk_1_Percent_Account_Balance())
     {
        {
         if(TRADING_TREND == TREND_BUY)
            tp_price += AMP_DC;
         if(TRADING_TREND == TREND_SEL)
            tp_price -= AMP_DC;

         ModifyTp_ExceptLock(symbol, TRADING_TREND, tp_price, TRADER);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ModifyTp_ToTPPrice(string symbol, double best_tpprice, string KEY_TO_CLOSE)
  {
   bool has_modify = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && is_same_symbol(OrderComment(), KEY_TO_CLOSE))
           {
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

            double price = bid;
            double close_now_price = bid;
            bool close_now = false;
            if(OrderType() == OP_BUY)
              {
               price = ask;
               close_now_price = bid;
               if(price > best_tpprice && best_tpprice > 0)
                  close_now = true;
              }
            if(OrderType() == OP_SELL)
              {
               price = bid;
               close_now_price = ask;
               if(price < best_tpprice && best_tpprice > 0)
                  close_now = true;
              }

            int ross=0, demm = 1;
            while(ross<=0 && demm<20)
              {
               if(close_now)
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), close_now_price, (int)MathAbs(ask-bid));
                  if(successful)
                    {
                     ross = 1;
                     has_modify = true;
                    }
                 }
               else
                  ross=OrderModify(OrderTicket(),price,OrderStopLoss(),best_tpprice,0);

               demm++;
               Sleep(500);
              }
           }
     } //for
   if(has_modify)
      SendAlert(symbol, KEY_TO_CLOSE, "ModifyTp_ToTPPrice Ok");
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ModifyTp_ToEntry(string symbol, double added_amp_tp, string KEY_TO_CLOSE)
  {
   bool has_modify = false;
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && is_same_symbol(OrderComment(), KEY_TO_CLOSE))
           {
            double tp_price = OrderOpenPrice();
            double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
            double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);

            double price = bid;
            double close_now_price = bid;
            bool close_now = false;
            if(OrderType() == OP_BUY)
              {
               tp_price += added_amp_tp;
               price = ask;
               close_now_price = bid;
               if(price > tp_price)
                  close_now = true;
              }
            if(OrderType() == OP_SELL)
              {
               tp_price -= added_amp_tp;
               price = bid;
               close_now_price = ask;
               if(price < tp_price)
                  close_now = true;
              }

            int ross=0, demm = 1;
            while(ross<=0 && demm<20)
              {
               if(close_now)
                 {
                  bool successful=OrderClose(OrderTicket(),OrderLots(), close_now_price, (int)MathAbs(ask-bid));
                  if(successful)
                    {
                     ross = 1;
                     has_modify = true;
                     Alert("(CLOSE_NOW) ModifyTp_ToEntry " + (string)OrderTicket() + "   "  + symbol + "   Profit: " + (string)(int) OrderProfit() + "$");
                    }
                 }
               else
                  if((int)tp_price != (int)OrderTakeProfit())
                    {
                     ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0);

                     double potentialProfit = calcPotentialTradeProfit(symbol, OrderType(), OrderOpenPrice(), tp_price, OrderLots());

                     Alert("ModifyTp_ToEntry " + (string)OrderTicket()
                           + "   "  + symbol + "   "  + OrderComment()
                           + "   Profit: " + (string)(int) OrderProfit() + "$"
                           + "   Est: " + (string)(int)potentialProfit + "$");
                    }

               demm++;
               Sleep(500);
              }

           }
     } //for

   if(has_modify)
      SendAlert(symbol, KEY_TO_CLOSE, "ModifyTp_ToEntry Ok");

   return has_modify;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void ModifyTp_ForPotentialProfit(string symbol, int order_type, double added_amp_tp, string KEY_TO_CLOSE, double old_tp_price)
//  {
//   for(int i = OrdersTotal() - 1; i >= 0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//         if(is_same_symbol(OrderSymbol(), symbol))
//            if(is_same_symbol(OrderComment(), KEY_TO_CLOSE))
//               if(OrderType() == order_type)
//                  if(OrderTakeProfit() != old_tp_price)
//                     if(is_same_symbol(OrderComment(), LOCK) == false &&
//                        is_same_symbol(OrderComment(), "B2S") == false &&
//                        is_same_symbol(OrderComment(), "S2B") == false)
//                       {
//                        double tp_price = OrderTakeProfit();
//                        double price = SymbolInfoDouble(symbol, SYMBOL_BID);
//
//                        if(OrderType() == OP_BUY)
//                          {
//                           tp_price += added_amp_tp;
//                           price = SymbolInfoDouble(symbol, SYMBOL_ASK);
//                          }
//                        if(OrderType() == OP_SELL)
//                          {
//                           tp_price -= added_amp_tp;
//                           price = SymbolInfoDouble(symbol, SYMBOL_BID);
//                          }
//
//                        int ross=0, demm = 1;
//                        while(ross<=0 && demm<20)
//                          {
//                           ross=OrderModify(OrderTicket(),price,OrderStopLoss(),tp_price,0,clrBlue);
//                           demm++;
//                           Sleep(500);
//                          }
//                       }
//     } //for
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//void ModifySL(string symbol, string TRADING_TREND, double sl_price, string KEY_TO_CLOSE)
//  {
//   for(int i = OrdersTotal() - 1; i >= 0; i--)
//     {
//      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
//         if(is_same_symbol(OrderSymbol(), symbol))
//            if(StringFind(toLower(OrderComment()), toLower(KEY_TO_CLOSE)) >= 0)
//               if(OrderStopLoss() != sl_price)
//                  if(is_same_symbol(OrderComment(), LOCK) == false &&
//                     is_same_symbol(OrderComment(), "B2S") == false &&
//                     is_same_symbol(OrderComment(), "S2B") == false)
//                    {
//                     double price = 0.0;
//                     if(OrderType() == OP_SELL)
//                       {
//                        price = SymbolInfoDouble(symbol, SYMBOL_ASK);
//                        if(price >= OrderOpenPrice())
//                           price = 0.0;
//                       }
//
//                     if(OrderType() == OP_BUY)
//                       {
//                        price = SymbolInfoDouble(symbol, SYMBOL_BID);
//                        if(price <= OrderOpenPrice())
//                           price = 0.0;
//                       }
//
//                     int ross=0, demm = 1;
//                     while(ross<=0 && demm<20)
//                       {
//                        ross=OrderModify(OrderTicket(),price,sl_price,OrderTakeProfit(),0,clrBlue);
//                        demm++;
//                        Sleep(500);
//                       }
//                    }
//     } //for
//  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePositionByTicket(int ticket_number, string symbol)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(OrderTicket() == ticket_number)
           {
            int demm = 1;
            while(demm<5)
              {
               double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
               double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
               int slippage = (int)MathAbs(ask-bid);

               if((OrderType() == OP_BUY))
                 {
                  bool successful=OrderClose(ticket_number, OrderLots(), bid, slippage, clrViolet);
                  if(successful)
                     return true;
                 }

               if((OrderType() == OP_SELL))
                 {
                  bool successful=OrderClose(ticket_number, OrderLots(), ask, slippage, clrViolet);
                  if(successful)
                     return true;
                 }

               if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                 {
                  bool successful=OrderDelete(ticket_number);
                  if(successful)
                     return true;
                 }

               demm++;
               Sleep(500);
              }
           }
     } //for

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePosition(string symbol, int ordertype, string TRADER)
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && OrderType() == ordertype)
            if((TRADER == "") || is_same_symbol(OrderComment(), TRADER))
              {
               //Alert("ClosePosition ", symbol, ordertype, TRADER);

               int demm = 1;
               while(demm<5)
                 {
                  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if((OrderType() == OP_BUY) && (is_same_symbol(OrderComment(), TREND_BUY) || (OrderComment() == "" && TRADER == "")))
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                     if(successful)
                        break;
                    }

                  if((OrderType() == OP_SELL) && (is_same_symbol(OrderComment(), TREND_SEL) || (OrderComment() == "" && TRADER == "")))
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet);
                     if(successful)
                        break;
                    }

                  if(OrderType() == OP_BUYLIMIT || OrderType() == OP_SELLLIMIT)
                    {
                     bool successful=OrderDelete(OrderTicket());
                     if(successful)
                        break;
                    }

                  demm++;
                  Sleep(500);
                 }
              }
     } //for

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool ClosePositivePosition(string symbol, string TRADING_TREND)
  {
   bool result = false;
   double min_profit = minProfit();
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_TRADES))
         if(is_same_symbol(OrderSymbol(), symbol) && (OrderProfit() > 0))
            if((TRADING_TREND == "") || (OrderComment() == "") || is_same_symbol(OrderComment(), TRADING_TREND))
              {
               int demm = 1;
               while(demm<5)
                 {
                  double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
                  double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
                  int slippage = (int)MathAbs(ask-bid);

                  if(OrderType() == OP_BUY)
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), bid, slippage, clrViolet);
                     if(successful)
                       {
                        result = true;
                        break;
                       }
                    }

                  if(OrderType() == OP_SELL)
                    {
                     bool successful=OrderClose(OrderTicket(),OrderLots(), ask, slippage, clrViolet);
                     if(successful)
                       {
                        result = true;
                        break;
                       }
                    }

                  demm++;
                  Sleep(500);
                 }
              }
     } //for

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendAlert(string symbol, string trend, string message)
  {
   return;

   if(is_main_control_screen() == false)
      return;

   if(ALERT_MSG_TIME == iTime(symbol, PERIOD_H4, 0))
      return;
   ALERT_MSG_TIME = iTime(symbol, PERIOD_H4, 0);

   Alert(get_vntime(), message);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void SendTelegramMessage(string symbol, string trend, string message, bool is_send_now)
  {
   if(allowSendMsgByAccount() == false)
      return;

   if(is_send_now == false)
     {
      string date_time = time2string(iTime(symbol, PERIOD_H4, 0));
      string key = symbol + "_" + trend + "_" + date_time;

      string send_telegram_today = ReadFileContent(FILE_NAME_SEND_MSG);
      if(StringFind(send_telegram_today, key) >= 0)
         return;
      WriteFileContent(FILE_NAME_SEND_MSG, "Telegram: " + key + " " + symbol + " " + trend + " " + message + "; " + send_telegram_today);
     }

   string botToken = "5349894943:AAE_0-ZnbikN9m1aRoyCI2nkT2vgLnFBA-8";
   string chatId_duydk = "5099224587";

   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   string str_cur_price = " price:" + (string) price;

   Alert(get_vntime(), message + str_cur_price);

   if(IsTesting())
      return;

   string new_message = AccountInfoString(ACCOUNT_NAME) + get_vntime() + message + str_cur_price;

   StringReplace(new_message, " ", "_");
   StringReplace(new_message, "SendTeleMsg", "");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "__", "_");
   StringReplace(new_message, "_", "%20");
   StringReplace(new_message, " ", "%20");

   string url = StringFormat("%s/bot%s/sendMessage?chat_id=%s&text=%s", telegram_url, botToken, chatId_duydk, new_message);

   string cookie=NULL,headers;
   char   data[],result[];

   ResetLastError();

   int timeout = 60000; // 60 seconds
   int res=WebRequest("GET",url,cookie,NULL,timeout,data,0,result,headers);
   if(res==-1)
      Alert("WebRequest Error:", GetLastError(), ", URL: ", url, ", Headers: ", headers, "   ", MB_ICONERROR);

   OpenChartWindow(symbol);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_acc_profit_percent()
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double ACC_PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);

   string percent = AppendSpaces(format_double_to_string(ACC_PROFIT, 2), 7, false) + "$ (" + AppendSpaces(format_double_to_string(ACC_PROFIT/BALANCE * 100, 1), 5, false) + "%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_has_memo_in_file(string filename, string symbol, string TRADING_TREND_KEY)
  {
   string open_trade_today = ReadFileContent(filename);

   string key = create_key(symbol, TRADING_TREND_KEY);
   if(StringFind(open_trade_today, key) >= 0)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void add_memo_to_file(string filename, string symbol, string TRADING_TREND_KEY, string note_stoploss = "", ulong ticket = 0, string note = "")
  {
   string open_trade_today = ReadFileContent(filename);
   string key = create_key(symbol, TRADING_TREND_KEY);

   WriteFileContent(filename, key);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string ReadFileContent(string file_name)
  {
   string fileContent = "";
   int fileHandle = FileOpen(file_name, FILE_READ);

   if(fileHandle != INVALID_HANDLE)
     {
      ulong fileSize = FileSize(fileHandle);
      if(fileSize > 0)
        {
         fileContent = FileReadString(fileHandle);
        }

      FileClose(fileHandle);
     }

   return fileContent;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteFileContent(string file_name, string content)
  {
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);

   if(fileHandle != INVALID_HANDLE)
     {
      //string file_contents = CutString(content);

      FileWriteString(fileHandle, content);
      FileClose(fileHandle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void saveAutoTrade()
  {
   string symbol = Symbol();
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_BUY", IS_CONTINUE_TRADING_CYCLE_BUY);
   GlobalVariableSet("IS_CONTINUE_TRADING_CYCLE_SEL", IS_CONTINUE_TRADING_CYCLE_SEL);

   string content = (string) iTime(symbol, PERIOD_D1, 0) + "~";
   content += "AUTO_BUY:" + (string) IS_CONTINUE_TRADING_CYCLE_BUY + "~";
   content += "AUTO_SEL:" + (string) IS_CONTINUE_TRADING_CYCLE_SEL + "~";
   content += "WAIT_BUY_10:" + (string) IS_WAITTING_10PER_BUY + "~";
   content += "WAIT_SEL_10:" + (string) IS_WAITTING_10PER_SEL + "~";

   WriteFileContent(FILE_NAME_AUTO_TRADE, content);

   string buttonLabelD1 = ObjectGetString(0, BtnSendNotice_D1, OBJPROP_TEXT);
   string buttonLabelH4 = ObjectGetString(0, BtnSendNotice_H4, OBJPROP_TEXT);
   string buttonLabelH1 = ObjectGetString(0, BtnSendNotice_H1, OBJPROP_TEXT);

   string Notice_Symbol = "";

   string key_d1_buy = (string)PERIOD_D1 + (string)OP_BUY;
   string key_d1_sel = (string)PERIOD_D1 + (string)OP_SELL;
   if(is_same_symbol(buttonLabelD1, TREND_BUY))
      Notice_Symbol += key_d1_buy;
   if(is_same_symbol(buttonLabelD1, TREND_SEL))
      Notice_Symbol += key_d1_sel;


   string key_h4_buy = (string)PERIOD_H4 + (string)OP_BUY;
   string key_h4_sel = (string)PERIOD_H4 + (string)OP_SELL;
   if(is_same_symbol(buttonLabelH4, TREND_BUY))
      Notice_Symbol += key_h4_buy;
   if(is_same_symbol(buttonLabelH4, TREND_SEL))
      Notice_Symbol += key_h4_sel;


   string key_h1_buy = (string)PERIOD_H1 + (string)OP_BUY;
   string key_h1_sel = (string)PERIOD_H1 + (string)OP_SELL;
   if(is_same_symbol(buttonLabelH1, TREND_BUY))
      Notice_Symbol += key_h1_buy;
   if(is_same_symbol(buttonLabelH1, TREND_SEL))
      Notice_Symbol += key_h1_sel;


   if(Notice_Symbol == "")
      Notice_Symbol = "-1";

   GlobalVariableSet(SendTeleMsg_ + symbol, (double) Notice_Symbol);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void loadAutoTrade()
  {
   string content = ReadFileContent(FILE_NAME_AUTO_TRADE);
   string cur_time = (string) iTime(Symbol(), PERIOD_D1, 0) + "~";
   string str_auto_buy = "AUTO_BUY:" + (string) true + "~";
   string str_auto_sel = "AUTO_SEL:" + (string) true + "~";
   string str_wait_buy10 = "WAIT_BUY_10:" + (string) true + "~";
   string str_wait_sel10 = "WAIT_SEL_10:" + (string) true + "~";

   if(is_same_symbol(content, cur_time))
     {
      IS_CONTINUE_TRADING_CYCLE_BUY = is_same_symbol(content, str_auto_buy);
      IS_CONTINUE_TRADING_CYCLE_SEL = is_same_symbol(content, str_auto_sel);

      IS_WAITTING_10PER_BUY = is_same_symbol(content, str_wait_buy10);
      IS_WAITTING_10PER_SEL = is_same_symbol(content, str_wait_sel10);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string CutString(string originalString)
  {
   int max_lengh = 10000;
   int originalLength = StringLen(originalString);
   if(originalLength > max_lengh)
     {
      int startIndex = originalLength - max_lengh;
      return StringSubstr(originalString, startIndex, max_lengh);
     }
   return originalString;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_key(string symbol, string TRADING_TREND_KEY)
  {
   string date_time = time2string(iTime(symbol, PERIOD_H4, 0));
   string key = date_time + ":PERIOD_H4:" + TRADING_TREND_KEY + ":" + symbol +";";
   return key;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_volume_by_fibo_vol(double cur_max_vol, double fibo)
  {
   double vol = 0.01;
   return NormalizeDouble(vol, 2);

   for(int i = 2; i <= 15; i++)
     {
      vol = NormalizeDouble(vol*fibo, 2);
      if(vol >= cur_max_vol + 0.01)
         return NormalizeDouble(vol, 2);
     }

   if(vol < INIT_VOLUME)
      return INIT_VOLUME;

   return NormalizeDouble(vol, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double get_volume_by_fibo_dca(int trade_no)
  {
   double vol = 0.01;
   return NormalizeDouble(vol, 2);

   for(int i = 2; i <= trade_no; i++)
     {
      vol = vol*FIBO_1618;
      if(trade_no >= 15)
         break;
     }

   if(vol < INIT_VOLUME)
      return INIT_VOLUME;

   return NormalizeDouble(vol, 2);
  }

// Function to get the highest and lowest M5 candle times in the current day
void GetHighestLowestM5Times(string symbol, datetime timeStart, datetime timeEnd, int dIndex)
  {
   double   highestPrice = -1;
   double   lowestPrice = -1;
   datetime highestTime = 0;
   datetime lowestTime = 0;

   string vnhig_d1 = "hig_" + time2string(timeStart);
   string vnlow_d1 = "low_" + time2string(timeStart);

   if(Period() <= PERIOD_H4 && !is_sunday(timeStart))
     {
      int i = 0;
      while(true)
        {
         datetime candleTime = iTime(symbol, PERIOD_H1, i);
         if(candleTime < timeStart)
            break;

         if(candleTime >= timeEnd)
           {
            i++;
            continue;
           }

         double high = iHigh(symbol, PERIOD_H1, i);
         double low = iLow(symbol, PERIOD_H1, i);

         if(highestPrice == -1 || high > highestPrice)
           {
            highestPrice = high;
            highestTime = candleTime;
           }

         if(lowestPrice == -1 || low < lowestPrice)
           {
            lowestPrice = low;
            lowestTime = candleTime;
           }

         i++;
        }

      bool is_up = lowestTime < highestTime;
      create_lable(vnhig_d1, dIndex==0 ? iTime(symbol, PERIOD_D1, 0) : timeStart, highestPrice,(is_up==true ? "" + format_double_to_string(highestPrice-lowestPrice, Digits - 2) + "" : ""), is_up==true ? TREND_BUY:"", true, 6);   // convert2vntime(highestTime)
      create_lable(vnlow_d1, dIndex==0 ? iTime(symbol, PERIOD_D1, 0) : timeStart, lowestPrice, (is_up==false? "" + format_double_to_string(lowestPrice-highestPrice, Digits - 2) + "" : ""),  is_up==false? TREND_SEL:"", true, 6);  // convert2vntime(lowestTime)
     }
   else
     {
      ObjectDelete(0, vnhig_d1);
      ObjectDelete(0, vnlow_d1);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getTrendByLowHigTimes(string symbol, datetime timeStart, datetime timeEnd, ENUM_TIMEFRAMES TIMEFRAME)
  {
   double   highestPrice = -1;
   double   lowestPrice = -1;
   datetime highestTime = 0;
   datetime lowestTime = 0;

   int i = 0;
   while(true)
     {
      datetime candleTime = iTime(symbol, TIMEFRAME, i);
      if(candleTime < timeStart)
         break;

      if(candleTime >= timeEnd)
        {
         i++;
         continue;
        }

      double high = iHigh(symbol, TIMEFRAME, i);
      double low = iLow(symbol, TIMEFRAME, i);

      if(highestPrice == -1 || high > highestPrice)
        {
         highestPrice = high;
         highestTime = candleTime;
        }

      if(lowestPrice == -1 || low < lowestPrice)
        {
         lowestPrice = low;
         lowestTime = candleTime;
        }

      i++;
     }

   if(lowestTime == 0 && highestTime == 0)
      return "";

   bool is_up = lowestTime < highestTime;

   if(is_up)
      return TREND_BUY;

   return TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_macd_and_signal_vs_zero(string symbol, ENUM_TIMEFRAMES timeframe,
      string &trend_by_macd, string &trend_mac_vs_signal, string &trend_mac_vs_zero
      , string &trend_vector_histogram, string &trend_vector_signal, string &trend_macd_note)
  {
   trend_by_macd = "";
   trend_mac_vs_signal = "";
   trend_mac_vs_zero = "";
   trend_vector_histogram = "";
   trend_vector_signal = "";
   trend_macd_note = "";

   double macd_0=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,  0);
   double sign_0=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,0);

   double macd_1=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,  1);
   double sign_1=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);

   double macd_2=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,  2);
   double sign_2=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2);

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_by_macd = TREND_BUY;
   if(macd_0 <= 0 && sign_0 <= 0)
      trend_by_macd = TREND_SEL;

   if(macd_0 >= sign_0)
      trend_mac_vs_signal = TREND_BUY;
   if(macd_0 <= sign_0)
      trend_mac_vs_signal = TREND_SEL;

   if(macd_0 >= 0 && sign_0 >= 0)
      trend_mac_vs_zero = TREND_BUY;
   if(macd_0 <= 0 && sign_0 <= 0)
      trend_mac_vs_zero = TREND_SEL;

   if(macd_0 > macd_1)
      trend_vector_histogram = TREND_BUY;
   if(macd_0 >= macd_1 && macd_2 > macd_1)
      trend_macd_note += SWITCH_TREND_BY_HISTOGRAM + TREND_BUY;


   if(macd_0 < macd_1)
      trend_vector_histogram = TREND_SEL;
   if(macd_2 < macd_1)
      trend_macd_note += SWITCH_TREND_BY_HISTOGRAM + TREND_SEL;


   if(sign_0 >= sign_1)
      trend_vector_signal = TREND_BUY;
   if(sign_0 <= sign_1)
      trend_vector_signal = TREND_SEL;

   if(macd_1 <= 0 && macd_0 >= 0)
      trend_macd_note += "_st2"+ TREND_BUY;
   if(macd_1 >= 0 && macd_0 <= 0)
      trend_macd_note += "_st2"+ TREND_SEL;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_switch_trend_by_macd(string symbol, ENUM_TIMEFRAMES timeframe)
  {
   double macd_1=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,1);
   double macd_2=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_MAIN,2);

   double sign_1=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,1);
   double sign_2=iMACD(symbol, timeframe,12,26,9,PRICE_CLOSE,MODE_SIGNAL,2);

   if(macd_1 > 0 && 0 > macd_2 && macd_1 > sign_1 && sign_1 > sign_2)
      return TREND_BUY;

   if(macd_1 < 0 && 0 < macd_2 && macd_1 < sign_1 && sign_1 < sign_2)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_order_opened_today(string symbol)
  {
// Lấy thời gian hiện tại
   datetime current_time = TimeCurrent();

// Lấy thời gian bắt đầu của ngày hôm nay
   datetime start_of_today = StringToTime(TimeToString(current_time, TIME_DATE));

// Duyệt qua tất cả các lệnh trong lịch sử và đang hoạt động
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
         if(is_same_symbol(OrderSymbol(), symbol))
            // Kiểm tra nếu lệnh được mở từ thời gian bắt đầu của ngày hôm nay trở đi
            if(OrderOpenTime() >= start_of_today)
               return true;
     }

   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_TRADES))
        {
         // Kiểm tra nếu lệnh được mở từ thời gian bắt đầu của ngày hôm nay trở đi
         if(OrderOpenTime() >= start_of_today)
            return true;
        }
     }

// Nếu không có lệnh nào được mở trong ngày hôm nay
   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trend_shift(string symbol, string NEW_TREND)
  {
   double price = SymbolInfoDouble(symbol, SYMBOL_BID);
   double lowest = 0.0, higest = 0.0;
   for(int idx = 1; idx <= 55; idx++)
     {
      double close = iClose(symbol, PERIOD_H4, idx);
      if((idx == 0) || (lowest > close))
         lowest = close;
      if((idx == 0) || (higest < close))
         higest = close;
     }

   if((NEW_TREND == TREND_BUY) && (higest - AMP_TP*2 < price))
      return false;

   if((NEW_TREND == TREND_SEL) && (lowest + AMP_TP*2 > price))
      return false;

   double PROFIT  = AccountInfoDouble(ACCOUNT_PROFIT);
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   if(EQUITY < BALANCE/2)
      return false;

   if(PROFIT < 0 && MathAbs(PROFIT) < EQUITY/3)
      return false;

// Cần chờ tối thiểu 1 giờ sau mỗi lần chuyển đổi để tránh tạo GAP sụt giảm tài khoản.
//bool pass_time_check = false;
//datetime currentTime = TimeCurrent();
//datetime timeGap = currentTime - last_trend_shift_time;
//if(timeGap < 1 * 60 * 60)
//   return false;

   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H4, NEW_TREND, 3, 2, 3))
      return true;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_H1, NEW_TREND, 3, 2, 3))
      return true;
   if(is_allow_trade_now_by_stoc(symbol, PERIOD_M15, NEW_TREND, 3, 2, 3))
      return true;

   return false;
  }


//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester()
  {
//---
   double ret=0.0;
//---

//---
   return(ret);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool passes_waiting_time_dca(datetime last_open_trade_time, int count_possion)
  {
   return true;

   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS + MINUTES_BETWEEN_ORDER*count_possion;

   bool pass_time_check = false;
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_open_trade_time;
   if(timeGap >= waiting_minus * 60)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int remaining_time_to_dca(datetime last_open_trade_time, int waiting_minus)
  {
   datetime currentTime = TimeCurrent();
   datetime timeGap = currentTime - last_open_trade_time;
   return (int)(waiting_minus - timeGap/60);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string str_remaining_time(datetime last_open_trade_time, int count_possion)
  {
   int waiting_minus = DEFAULT_WAITING_DCA_IN_MINUS + MINUTES_BETWEEN_ORDER*count_possion;

   int remain = remaining_time_to_dca(last_open_trade_time, waiting_minus);
   datetime currentTime = TimeCurrent();
   datetime newTime = currentTime + remain * 60;

   if(remain < 0)
      remain = 0;

   string value = "  " + (string)remain  + "p";

   return value;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_by_ma7_10_20_50(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend)
  {
   string trend_m5_ma0710 = "";
   string trend_m5_ma1020 = "";
   string trend_m5_ma2050 = "";
   string trend_m5_C1ma10 = "";
   string trend_m5_ma50d1 = "";
   bool is_insign_m5 = false;
   get_trend_by_ma_seq71020_steadily(symbol, timeframe, trend_m5_ma0710, trend_m5_ma1020, trend_m5_ma2050, trend_m5_C1ma10, trend_m5_ma50d1, is_insign_m5);

   string trend_reverse = get_trend_reverse(find_trend);

   if(trend_reverse == trend_m5_ma2050)
      if(trend_m5_ma0710 == trend_m5_ma1020 && trend_m5_ma1020 == trend_m5_ma2050)
         return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_stoc2(string symbol, ENUM_TIMEFRAMES timeframe, int inK = 21, int inD = 7, int inS = 7, int candle_no = 0)
  {
   double M_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double M_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  1);// 1st bar
   double S_0 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar
   double S_1 = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,1);// 1st bar

   double black_K = M_0;
   double red_D = S_0;

   if(black_K > red_D)
      return TREND_BUY;

   if(black_K < red_D)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

   if(find_trend == TREND_BUY && black_K >= red_D && (red_D <= 20 || black_K <= 20))
      return true;

   if(find_trend == TREND_SEL && black_K <= red_D && (red_D >= 80 || black_K >= 80))
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_allow_take_profit_now_by_stoc(string symbol, ENUM_TIMEFRAMES timeframe, string find_trend, int inK, int inD, int inS)
  {
   double black_K = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);// 0 bar
   double red_D   = iStochastic(symbol,timeframe,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);// 0 bar

   if(find_trend == TREND_BUY && red_D <= 20 && black_K <= 20)
      return true;

   if(find_trend == TREND_SEL && red_D >= 80 && black_K >= 80)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string check_stoch_before_trade(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string find_trend)
  {
   string msg = "";

   double h4_bla_K_5_3_2 = iStochastic(symbol,TIMEFRAME,5,3,2,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_5_3_2 = iStochastic(symbol,TIMEFRAME,5,3,2,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double h4_bla_K_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double h4_red_D_13_5_5 = iStochastic(symbol,TIMEFRAME,13,5,5,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   if(find_trend == TREND_BUY)
      if(h4_bla_K_5_3_2 >= 80 || h4_red_D_5_3_2 >= 80 || h4_bla_K_13_5_5 >= 80 || h4_red_D_13_5_5 >= 80)
         msg = "BUY is not allowed. Stoch " + get_timeframe_name(TIMEFRAME) + " is in overbought.";

   if(find_trend == TREND_SEL)
      if(h4_bla_K_5_3_2 <= 20 || h4_red_D_5_3_2 <= 20 || h4_bla_K_13_5_5 <= 20 || h4_red_D_13_5_5 <= 20)
         msg = "SELL is not allowed. Stoch " + get_timeframe_name(TIMEFRAME) + " is in oversold.";

   return msg;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_allow_trade_now_by_stoc(string symbol, ENUM_TIMEFRAMES TIMEFRAME, bool auto_init = false)
  {
   double bla_K__5_3_2 = iStochastic(symbol,TIMEFRAME, 7,5,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D__5_3_2 = iStochastic(symbol,TIMEFRAME, 7,5,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double bla_K_13_5_5 = iStochastic(symbol,TIMEFRAME,12,7,3,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D_13_5_5 = iStochastic(symbol,TIMEFRAME,12,7,3,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);
   double bla_K_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D_21_7_7 = iStochastic(symbol,TIMEFRAME,21,7,7,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   string result = "";

   if(
      (bla_K__5_3_2 <= 20 || red_D__5_3_2 <= 20) ||
      (bla_K_13_5_5 <= 20 || red_D_13_5_5 <= 20) ||
      (bla_K_21_7_7 <= 20 || red_D_21_7_7 <= 20)
   )
      result += TREND_BUY + " ";

   if(
      (bla_K__5_3_2 >= 80 || red_D__5_3_2 >= 80) ||
      (bla_K_13_5_5 >= 80 || red_D_13_5_5 >= 80) ||
      (bla_K_21_7_7 >= 80 || red_D_21_7_7 >= 80)
   )
      result += TREND_SEL + " ";

   if(auto_init && result == "")
      result += " " + TREND_BUY + " " + TREND_SEL + " ";

   return result;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Count_Stoc_Candles(string symbol, int TIMEFRAME, string &trend_stoc_21_h4, int &count_stoc_21_h4, int inK, int inD, int inS, bool is_draw_time_trend_d1 = false)
  {
   int limit = MathMin(100, iBars(symbol, TIMEFRAME)-10);

   double bla_K = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  0);
   double red_D = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,0);

   int idx_0   = 0, idx_1   = 0, idx_2   = 0;
   int count_0 = 1, count_1 = 1, count_2 = 1;
   string trend_0 = bla_K > red_D ? TREND_BUY : TREND_SEL;
   string trend_1 = bla_K > red_D ? TREND_SEL : TREND_BUY;
   string trend_2 = trend_0;

   bool found_0 = false, found_1 = false, found_2 = false;
   for(int i = 1; i < limit; i++)
     {
      bla_K = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_MAIN,  i);
      red_D = iStochastic(symbol,TIMEFRAME,inK,inD,inS,MODE_SMA,STO_LOWHIGH,MODE_SIGNAL,i);
      string trend_i = bla_K > red_D ? TREND_BUY : TREND_SEL;

      if(!found_0)
        {
         if(trend_0 == trend_i)
           {
            idx_0 = i;
            count_0 += 1;
           }
         else
            found_0 = true;
        }

      if(found_0 && !found_1)
        {
         if(trend_1 == trend_i)
           {
            idx_1 = i;
            count_1 += 1;
           }
         else
            found_1 = true;
        }

      if(found_0 && found_1 && !found_2)
        {
         if(trend_2 == trend_i)
           {
            idx_2 = i;
            count_2 += 1;
           }
         else
            found_2 = true;
        }
      if(found_0 && found_1 && found_2)
         break;
     }

   bool cur_symbol = is_same_symbol(symbol, Symbol());

   if(cur_symbol && is_draw_time_trend_d1)
     {
      ObjectDelete(0, "h_time_trend_0");
      ObjectDelete(0, "h_time_trend_1");
      ObjectDelete(0, "h_time_trend_2");

      if(found_0 && found_1 && found_2)
        {
         datetime time_0 = iTime(symbol, TIMEFRAME, idx_0);
         datetime time_1 = iTime(symbol, TIMEFRAME, idx_1);
         datetime time_2 = iTime(symbol, TIMEFRAME, idx_2);

         color clrLineColor_0 = trend_0==TREND_BUY?clrTeal:clrFireBrick;
         color clrLineColor_1 = trend_1==TREND_BUY?clrTeal:clrFireBrick;
         color clrLineColor_2 = trend_2==TREND_BUY?clrTeal:clrFireBrick;

         int chart_width = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 0));
         int chart_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 0));

         int sub_window;
         datetime time;
         double price;
         if(ChartXYToTimePrice(0, chart_width/2, chart_heigh-10, sub_window, time, price))
           {
            double amp_w1, amp_d1, amp_h4, amp_grid_L100;
            GetAmpAvgL15(Symbol(), amp_w1, amp_d1, amp_h4, amp_grid_L100);

            create_filled_rectangle("h_time_trend_2", time_2, price, time_1, price - amp_d1, clrLineColor_2, true, true, trend_2, 1);
            create_filled_rectangle("h_time_trend_1", time_1, price, time_0, price - amp_d1, clrLineColor_1, true, true, trend_1, 1);
            create_filled_rectangle("h_time_trend_0", time_0, price, TimeCurrent()+ TIME_OF_ONE_D1_CANDLE, price - amp_d1, clrLineColor_0, true, true, trend_0, 1);
           }
        }
     }


   if(cur_symbol && is_draw_time_trend_d1 && (TIMEFRAME == Period()))
     {
      ObjectDelete(0, "Stoc.0");
      ObjectDelete(0, "Stoc.1");
      ObjectDelete(0, "Stoc.2");
      ObjectDelete(0, "V.Stoc.0");
      ObjectDelete(0, "V.Stoc.1");
      ObjectDelete(0, "V.Stoc.2");

      double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
      int chart_width = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS, 2));
      int chart_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 2)) - 18;

      if(found_0)
        {
         int x, y;
         datetime time_0 = iTime(symbol, TIMEFRAME, idx_0);
         color clrLineColor = trend_0==TREND_BUY?clrBlue:clrRed;
         create_vertical_line("V.Stoc.0", time_0, clrBlack, STYLE_SOLID, 1, true, false, false, true, 2);

         if(ChartTimePriceToXY(0, 0, time_0, bid, x, y))
            createButton("Stoc.0", "(0) " + getShortName(trend_0) + "." + (string)count_0, x+3, chart_heigh, 60, 15, clrLineColor, clrWhite, 6, 2);
        }

      if(found_1 && count_1 > 5)
        {
         int x, y;
         datetime time_1 = iTime(symbol, TIMEFRAME, idx_1);
         color clrLineColor = trend_1==TREND_BUY?clrBlue:clrRed;
         create_vertical_line("V.Stoc.1", time_1, clrBlack, STYLE_SOLID, 1, true, false, false, true, 2);

         if(ChartTimePriceToXY(0, 0, time_1, bid, x, y))
            createButton("Stoc.1", "(0) " + getShortName(trend_1) + "." + (string)count_1, x+3, chart_heigh, 60, 15, clrLineColor, clrWhite, 6, 2);
        }

      if(found_2 && count_2 > 5)
        {
         int x, y;
         datetime time_2 = iTime(symbol, TIMEFRAME, idx_2);
         color clrLineColor = trend_2==TREND_BUY?clrBlue:clrRed;
         create_vertical_line("V.Stoc.2", time_2, clrBlack, STYLE_SOLID, 1, true, false, false, true, 2);

         if(ChartTimePriceToXY(0, 0, time_2, bid, x, y))
            createButton("Stoc.2", "(0) " + getShortName(trend_2) + "." + (string)count_2, x+3, chart_heigh, 60, 15, clrLineColor, clrWhite, 6, 2);
        }
     }

   trend_stoc_21_h4 = trend_0;
   count_stoc_21_h4 = count_0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_manual_trade(string comment)
  {
   if(is_same_symbol(comment, MASK_MANUAL))
      return true;

   if(comment == "")
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_same_symbol(string symbol_og, string symbol_tg)
  {
   if(symbol_og == "" || symbol_og == "")
      return false;

   if(StringFind(toLower(symbol_og), toLower(symbol_tg)) >= 0)
      return true;

   if(StringFind(toLower(symbol_tg), toLower(symbol_og)) >= 0)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string toLower(string text)
  {
   StringToLower(text);
   return text;
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string appendZero100(int trade_no)
  {
   if(trade_no < 10)
      return "00" + (string) trade_no;

   if(trade_no < 100)
      return "0" + (string) trade_no;

   return (string) trade_no;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string append1Zero(int trade_no)
  {
   if(trade_no < 10)
      return "0" + (string) trade_no;

   return (string) trade_no;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_ma(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index,int candle_no = 1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double close_1 = closePrices[candle_no];
   double ma = cal_MA(closePrices, ma_index, candle_no);

   if(close_1 > ma)
      return TREND_BUY;

   if(close_1 < ma)
      return TREND_SEL;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_maX_maY(string symbol,ENUM_TIMEFRAMES timeframe, int ma_index_6, int ma_index_9)
  {
   int maLength = MathMax(ma_index_6, ma_index_9) + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_6 = cal_MA(closePrices, ma_index_6, 1);
   double ma_9 = cal_MA(closePrices, ma_index_9, 1);

   if(ma_6 > ma_9)
      return TREND_BUY;

   if(ma_6 < ma_9)
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA(double& closePrices[], int ma_index, int candle_no = 1)
  {
   int count = 0;
   double ma = 0.0;
   for(int i = candle_no; i <= candle_no + ma_index; i++)
     {
      count += 1;
      ma += closePrices[i];
     }
   ma /= count;

   return ma;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_group_value(string comment, string str_start = "[G", string str_end = "]")
  {
   int startPos = StringFind(comment, str_start);
   int endPos = StringFind(comment, str_end, startPos);
   string result = "";

   if(startPos != -1 && endPos != -1)
      result = StringSubstr(comment, startPos, endPos - startPos + 1);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_group_name()
  {
   datetime VnTime = TimeGMT() + 7 * 3600;
   MqlDateTime time_struct;
   TimeToStruct(VnTime, time_struct);

   return "[G"
          + (string)time_struct.day
          + (string)time_struct.hour
          + (string)time_struct.min
          + "]";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_ticket_key(ulong ticket)
  {
   string key = "";

   if(ticket > 0)
     {
      key = "000" + (string)(ticket);
      int length = StringLen(key);

      string lastThree = StringSubstr(key, length - 3, 3);

      key = "[K" + lastThree+ "]";
     }

   return key;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string time2string(datetime time)
  {
   string today = (string)time;
   StringReplace(today, " ", "");
   StringReplace(today, "000000", "");
   StringReplace(today, "0000", "");
   StringReplace(today, "00:00:00", "");
   StringReplace(today, "00:00", "");

   return today;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double dblLotsRisk(string symbol, double dbAmp, double dbRiskByUsd)
  {
   double dbLotsMinimum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MIN);
   double dbLotsMaximum  = SymbolInfoDouble(symbol, SYMBOL_VOLUME_MAX);
   double dbLotsStep     = SymbolInfoDouble(symbol, SYMBOL_VOLUME_STEP);
   double dbTickSize     = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_SIZE);
   double dbTickValue    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);
   if(dbTickSize == 0)
      return 0.01;
   double dbLossOrder    = dbAmp * dbTickValue / dbTickSize;
   if(dbLossOrder == 0 || dbLotsStep == 0)
      return 0.01;

   double dbLotReal      = (dbRiskByUsd / dbLossOrder / dbLotsStep) * dbLotsStep;
   double dbCalcLot      = (fmin(dbLotsMaximum, fmax(dbLotsMinimum, round(dbLotReal))));
   double roundedLotSize = MathRound(dbLotReal / dbLotsStep) * dbLotsStep;

   if(roundedLotSize < 0.01)
      roundedLotSize = 0.01;

   return NormalizeDouble(roundedLotSize, 2);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_volume_by_amp(string symbol, double amp_trade, double risk)
  {
   return dblLotsRisk(symbol, amp_trade, risk);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_SL_7d_for_trade_arr(string symbol, CandleData &temp_array_D1[], string trend_ma10_d1, double amp_sl_min)
  {
   double min_10d = 0;
   double max_10d = 0;
   for(int i = 0; i < 7; i++)
     {
      if(i==0 || min_10d > temp_array_D1[i].low)
         min_10d = temp_array_D1[i].low;

      if(i==0 || max_10d < temp_array_D1[i].high)
         max_10d = temp_array_D1[i].high;
     }
   double sl_buy = min_10d;
   double sl_sel = max_10d;

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double cur_price = (bid+ask)/2;

   double amp_sl = trend_ma10_d1 == TREND_BUY ? MathAbs(cur_price - sl_buy) : trend_ma10_d1 == TREND_SEL? MathAbs(cur_price - sl_sel) : 0;
   if(amp_sl < amp_sl_min)
     {
      sl_buy = cur_price - amp_sl_min;
      sl_sel = cur_price + amp_sl_min;
     }
   int digits = MathMin(5, (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS));

   return NormalizeDouble(trend_ma10_d1 == TREND_BUY ? sl_buy : trend_ma10_d1 == TREND_SEL? sl_sel : 0, digits);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_lowest_highest(CandleData &temp_array_heiken[], int size, double &lowest, double &highest)
  {
   double min_x = 0;
   double max_x = 0;
   for(int i = 0; i < size; i++)
     {
      if(i==0 || min_x > temp_array_heiken[i].low)
         min_x = temp_array_heiken[i].low;

      if(i==0 || max_x < temp_array_heiken[i].high)
         max_x = temp_array_heiken[i].high;
     }

   lowest = min_x;
   highest = max_x;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_SL_7d_for_trade_init(string symbol, string trend_ma10_d1, double amp_sl_min)
  {
   CandleData temp_array_D1[];
   get_arr_heiken(symbol, PERIOD_D1, temp_array_D1, 10, true);

   return calc_SL_7d_for_trade_arr(symbol, temp_array_D1, trend_ma10_d1, amp_sl_min);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double calc_SL_7w_for_protect_account(string symbol, string trend_ma10_d1, double amp_w1)
//  {
//   CandleData temp_array_W1[];
//   get_arr_heiken(symbol, PERIOD_W1, temp_array_W1, 21, true);
//
//   return calc_SL_7d_for_trade_arr(symbol, temp_array_W1, trend_ma10_d1, amp_w1);
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double cal_MA_XX(string symbol, ENUM_TIMEFRAMES timeframe, int ma_index, int candle_no=1)
  {
   int maLength = ma_index + 5;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= candle_no; i--)
     {
      closePrices[i] = iClose(symbol, timeframe, i);
     }

   double ma_value = cal_MA(closePrices, ma_index);
   return ma_value;
  }
//+------------------------------------------------------------------+
string Append(double inputString, int totalLength = 6)
  {
   return AppendSpaces((string) inputString, totalLength);
  }
//+------------------------------------------------------------------+
string AppendSpaces(string inputString, int totalLength = 10, bool is_append_right = true)
  {
   int currentLength = StringLen(inputString);

   if(currentLength >= totalLength)
      return (inputString);

   int spacesToAdd = totalLength - currentLength;
   string spaces = "";
   for(int index = 1; index <= spacesToAdd; index++)
      spaces+= " ";

   if(is_append_right)
      return (inputString + spaces);
   else
      return (spaces + inputString);
  }

//+------------------------------------------------------------------+
string format_double_to_string(double number, int digits = 5)
  {
   string numberString = (string) number;
   int dotIndex = StringFind(numberString, ".");
   if(dotIndex >= 0)
     {
      string beforeDot = StringSubstr(numberString, 0, dotIndex);
      string afterDot = StringSubstr(numberString, dotIndex + 1);
      afterDot = StringSubstr(afterDot, 0, digits); // chỉ lấy digits chữ số đầu tiên sau dấu chấm

      numberString = beforeDot + "." + afterDot;
     }

   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "00000", "");
   StringReplace(numberString, "99999", "9");
   StringReplace(numberString, "99999", "9");
   StringReplace(numberString, "99999", "9");

   dotIndex = StringFind(numberString, ".");
   string afterDot = StringSubstr(numberString, dotIndex + 1);
   if(dotIndex > 0 && StringLen(afterDot) < digits)
      numberString += "0";

   return numberString;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double format_double(double number, int digits)
  {
   return NormalizeDouble(StringToDouble(format_double_to_string(number, digits)), digits);
  }

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
string get_current_timeframe_to_string()
  {
   if(Period() == PERIOD_M1)
      return "M1";

   if(Period() == PERIOD_M5)
      return "M5";

   if(Period() == PERIOD_M15)
      return "M15";

   if(Period() == PERIOD_M30)
      return "M30";

   if(Period() ==  PERIOD_H1)
      return "H1";

   if(Period() ==  PERIOD_H4)
      return "H4";

   if(Period() ==  PERIOD_D1)
      return "D1";

   if(Period() ==  PERIOD_W1)
      return "W1";

   return "??";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_current_timeframe()
  {
   if(Period() == PERIOD_M1)
      return "01";

   if(Period() == PERIOD_M5)
      return "05";

   if(Period() == PERIOD_M15)
      return "15";

   if(Period() == PERIOD_M30)
      return "30";

   if(Period() ==  PERIOD_H1)
      return "1";

   if(Period() ==  PERIOD_H4)
      return "4";

   if(Period() ==  PERIOD_D1)
      return "D";

   if(Period() ==  PERIOD_W1)
      return "W";

   return "??";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_timeframe_name(ENUM_TIMEFRAMES PERIOD_XX)
  {
   if(PERIOD_XX == PERIOD_M1)
      return "M1";

   if(PERIOD_XX == PERIOD_M5)
      return "M5";

   if(PERIOD_XX == PERIOD_M15)
      return "M15";

   if(PERIOD_XX ==  PERIOD_H1)
      return "H1";

   if(PERIOD_XX ==  PERIOD_H4)
      return "H4";

   if(PERIOD_XX ==  PERIOD_D1)
      return "D1";

   if(PERIOD_XX ==  PERIOD_W1)
      return "W1";

   return "??";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vntime()
  {
   string cpu = "";
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9) ? (string) gmt_time.hour : "0" + (string) gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string str_date_time = TimeToString(vietnamTime, TIME_DATE | TIME_MINUTES);
   string vntime = "(" + str_date_time + ")    ";
   return vntime;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string format_date(datetime date0)
  {
   MqlDateTime gmt_time;
   TimeToStruct(date0, gmt_time);

   return (string)gmt_time.year + "/" + (string)gmt_time.mon + "/" + (string)gmt_time.day;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vn_date()
  {
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);

   string str_date_time = (string)gmt_time.year + append1Zero(gmt_time.mon) + append1Zero(gmt_time.day);

   return str_date_time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_vnhour()
  {
   string cpu = "";
   MqlDateTime gmt_time;
   TimeToStruct(TimeGMT(), gmt_time);
   string current_gmt_hour = (gmt_time.hour > 9) ? (string) gmt_time.hour : "0" + (string) gmt_time.hour;

   datetime vietnamTime = TimeGMT() + 7 * 3600;
   string str_date_time = TimeToString(vietnamTime, TIME_MINUTES);
   string vntime = "(" + str_date_time + ")";
   return vntime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string convert2vntime(datetime time)
  {
// Time difference between UTC and Vietnam Time is +7 hours
   int timeOffset = 7 * 3600; // 7 hours in seconds

// Add the offset to the given time
   datetime vietnamTime = time + timeOffset;

   string str_date_time = TimeToString(vietnamTime, TIME_MINUTES);

   return str_date_time;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool must_exit_trade_today(string symbol, string TREND)
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime timeStruct;
   TimeToStruct(vietnamTime, timeStruct);

   if(timeStruct.hour > 23 || (timeStruct.hour == 23 && timeStruct.min >= 30))
     {
      if(is_allow_take_profit_now_by_stoc(symbol, PERIOD_M15, TREND, 3, 2, 3))
         return true;

      if(is_allow_take_profit_now_by_stoc(symbol, PERIOD_M5,  TREND, 3, 2, 3))
         return true;
     }

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_sunday(datetime timeEnd)
  {
   MqlDateTime vietnamDateTime;
   TimeToStruct(timeEnd, vietnamDateTime);

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week == SUNDAY)
      return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_time_enter_the_market()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   if(18 <= currentHour && currentHour <= 20)
      return false;

   const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
   if(day_of_week == SATURDAY || day_of_week == SUNDAY)
      return false;

   if(day_of_week == FRIDAY && currentHour > 22)
      return false;

   if(3 <= currentHour && currentHour <= 5)
      return false;

   return true;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_setting_reset_on_new_day()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

//const ENUM_DAY_OF_WEEK day_of_week = (ENUM_DAY_OF_WEEK)vietnamDateTime.day_of_week;
//if(day_of_week == SATURDAY || day_of_week == SUNDAY)
//   return false;

   int currentHour = vietnamDateTime.hour;
   int currentMinus = vietnamDateTime.min;
   if(currentHour == 7)
      if(0 <= currentMinus && currentMinus <= 15)
         return true;

   return false;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_hedging_time()
  {
   datetime vietnamTime = TimeGMT() + 7 * 3600;
   MqlDateTime vietnamDateTime;
   TimeToStruct(vietnamTime, vietnamDateTime);

   int currentHour = vietnamDateTime.hour;
   if(22 <= currentHour || currentHour <= 3)
      return true;

   return false;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetTrendlineValueAtCurrentTime(string trendlineName, datetime currentTime)
  {
   datetime time1 = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME1);
   double price1 = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE1);

   datetime time2 = (datetime)ObjectGetInteger(0, trendlineName, OBJPROP_TIME2);
   double price2 = ObjectGetDouble(0, trendlineName, OBJPROP_PRICE2);

   if((time2 - time1) == 0)
      return 0;

// Tính độ dốc của trendline
   double slope = (price2 - price1) / (time2 - time1);

// Tính giá trị của trendline tại thời gian hiện tại
   double priceAtCurrentTime = NormalizeDouble(price1 + slope * (currentTime - time1), Digits-1);

   return priceAtCurrentTime;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_trend_line(
   const string            name="Text",         // object name
   datetime                time_from=0,                   // anchor point time
   double                  price_from=0,                   // anchor point price
   datetime                time_to=0,                   // anchor point time
   double                  price_to=0,                   // anchor point price
   const color             clr_color=clrRed,              // color
   const int               STYLE_XX=STYLE_SOLID,
   const int               width = 1,
   const bool              ray_left = false,
   const bool              ray_right = false,
   const bool              is_hiden = true,
   const bool              is_back = true,
   const int               sub_window = 0
)
  {
   string name_new = name;
   ObjectDelete(0, name);
   if(ray_left)
      time_from = time_to - TIME_OF_ONE_W1_CANDLE * 350;
   ObjectCreate(0, name_new, OBJ_TREND, sub_window, time_from, price_from, time_to, price_to);
   ObjectSetInteger(0, name_new, OBJPROP_COLOR,       clr_color);
   ObjectSetInteger(0, name_new, OBJPROP_STYLE,       STYLE_XX);
   ObjectSetInteger(0, name_new, OBJPROP_WIDTH,       width);
   ObjectSetInteger(0, name_new, OBJPROP_HIDDEN,      true);
   ObjectSetInteger(0, name_new, OBJPROP_BACK,        is_back);
   ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE,  false);
   ObjectSetInteger(0, name_new, OBJPROP_RAY_RIGHT,   ray_right); // Bật tính năng "Rời qua phải"
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_filled_rectangle(
   const string            name="Rectangle",         // object name
   datetime                time_from=0,              // anchor point time (bottom-left corner)
   double                  price_from=0,             // anchor point price (bottom-left corner)
   datetime                time_to=0,                // anchor point time (top-right corner)
   double                  price_to=0,               // anchor point price (top-right corner)
   const color             clr_fill=clrGray,         // fill color
   const bool              is_draw_border=false,
   const bool              is_fill_color=true,
   const string            trend_rec="",
   const int               body_border_width=1
)
  {
   string name_new = name;
   if(is_fill_color)
     {
      ObjectDelete(0, name_new);  // Delete any existing object with the same name
      ObjectCreate(0, name_new, OBJ_RECTANGLE, 0, time_from, price_from, time_to, price_to);
      ObjectSetInteger(0, name_new, OBJPROP_COLOR, clrBlack);         // Set border color
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);      // Set border style to solid
      ObjectSetInteger(0, name_new, OBJPROP_HIDDEN, true);            // Set hidden property
      ObjectSetInteger(0, name_new, OBJPROP_BACK, true);              // Set background property
      ObjectSetInteger(0, name_new, OBJPROP_SELECTABLE, false);       // Set selectable property
      ObjectSetInteger(0, name_new, OBJPROP_STYLE, STYLE_SOLID);      // Set style to solid
      ObjectSetInteger(0, name_new, OBJPROP_COLOR, clr_fill);         // Set fill color (this may not work as intended for all objects)
      ObjectSetInteger(0, name_new, OBJPROP_WIDTH, 1);                // Setting this to 1 for consistency
     }

   if(is_draw_border)
     {
      color clr_border = trend_rec == TREND_BUY ? clrBlue : trend_rec == TREND_SEL ? clrRed : clrNONE; //C'215,215,215'

      create_trend_line(name_new + "_left",   time_from, price_from, time_from, price_to,   clr_border, STYLE_SOLID, body_border_width);
      create_trend_line(name_new + "_righ",   time_to,   price_from, time_to,   price_to,   clr_border, STYLE_SOLID, body_border_width);
      create_trend_line(name_new + "_top",    time_from, price_to,   time_to,   price_to,   clr_border, STYLE_SOLID, body_border_width);
      create_trend_line(name_new + "_bottom", time_from, price_from, time_to,   price_from, clr_border, STYLE_SOLID, body_border_width);
     }
  }

//+------------------------------------------------------------------+
//| Create the vertical line                                         |
//+------------------------------------------------------------------+
bool create_vertical_line(
   const string          name0="VLine",      // line name
   datetime              time=0,            // line time
   const color           clr=clrBlack,        // line color
   const ENUM_LINE_STYLE style=STYLE_DOT,   // line style
   const int             width=1,           // line width
   const bool            back=true,         // in the background
   const bool            selection=false,    // highlight to move
   const bool            ray=false,          // line's continuation down
   const bool            hidden=true,      // hidden in the object list
   const int             sub_window=0)         // priority for mouse click
  {
//string name = STR_RE_DRAW + name0;
   string name = name0;
   ObjectDelete(0, name);

   if(!time)
      time=TimeGMT();

   ResetLastError();

   if(!ObjectCreate(0,name,OBJ_VLINE,sub_window,time,0))
     {
      Print(__FUNCTION__, ": failed to create a vertical line! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetInteger(0,name,OBJPROP_COLOR,clr);
   ObjectSetInteger(0,name,OBJPROP_STYLE,style);
   ObjectSetInteger(0,name,OBJPROP_WIDTH,width);
   ObjectSetInteger(0,name,OBJPROP_BACK, selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE,false);
   ObjectSetInteger(0,name,OBJPROP_SELECTED, false);
   ObjectSetInteger(0,name,OBJPROP_RAY, false);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN,hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER,0);

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_seq102050(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int candle_index)
  {
   int count = 0;
   int maLength = 55+candle_index;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol, TIMEFRAME, i);
     }
   double ma10_0 = cal_MA(closePrices, 10, candle_index + 0);
   double ma10_1 = cal_MA(closePrices, 10, candle_index + 1);

   double ma20_0 = cal_MA(closePrices, 20, candle_index + 0);
   double ma20_1 = cal_MA(closePrices, 20, candle_index + 1);

   double ma50_0 = cal_MA(closePrices, 50, candle_index + 0);
   double ma50_1 = cal_MA(closePrices, 50, candle_index + 1);

   if((ma10_0 > ma10_1) && (ma20_0 > ma20_1 || ma50_0 > ma50_1) && (ma10_0 > ma20_0) && (ma20_0 > ma50_0))
      return TREND_BUY;

   if((ma10_0 < ma10_1) && (ma20_0 < ma20_1 || ma50_0 < ma50_1) && (ma10_0 < ma20_0) && (ma20_0 < ma50_0))
      return TREND_SEL;

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_trend_by_ma_seq71020_steadily(string symbol, ENUM_TIMEFRAMES TIMEFRAME, string &trend_ma0710, string &trend_ma1020, string &trend_ma02050, string &trend_C1ma10, string &trend_h4_ma50d1, bool &insign_h4)
  {
   trend_ma0710 = "";
   trend_ma1020 = "";
   trend_ma02050 = "";
   trend_C1ma10 = "";
   trend_h4_ma50d1 = "";

   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);


   int count = 0;
   int maLength = 55;
   double closePrices[];
   ArrayResize(closePrices, maLength);
   for(int i = maLength - 1; i >= 0; i--)
     {
      count += 1;
      closePrices[i] = iClose(symbol, TIMEFRAME, i);
     }

   double ma07[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   double ma10[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   double ma20[5] = {0.0, 0.0, 0.0, 0.0, 0.0};
   for(int i = 0; i < 5; i++)
     {
      ma07[i] = cal_MA(closePrices, 7, i);
      ma10[i] = cal_MA(closePrices, 10, i);
      ma20[i] = cal_MA(closePrices, 20, i);
     }
   double ma50_0 = cal_MA(closePrices, 50, 0);
   double ma50_1 = cal_MA(closePrices, 50, 1);
   trend_ma02050 = (ma20[0] > ma50_0) ? TREND_BUY : TREND_SEL;

   double price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   if(ma50_0+amp_d1 < price)
      trend_h4_ma50d1 = TREND_SEL;
   if(ma50_0-amp_d1 > price)
      trend_h4_ma50d1 = TREND_BUY;

   double ma_min = MathMin(MathMin(MathMin(ma07[0], ma10[0]), ma20[0]), ma50_0);
   double ma_max = MathMax(MathMax(MathMax(ma07[0], ma10[0]), ma20[0]), ma50_0);
   insign_h4 = false;
   if(MathAbs(ma_max - ma_min) < amp_h4*2)
      insign_h4 = true;

// Nếu có ít nhất một cặp giá trị không tăng dần, trả về ""
   string seq_buy_07 = TREND_BUY;
   string seq_buy_10 = TREND_BUY;
   string seq_buy_20 = TREND_BUY;
// Nếu có ít nhất một cặp giá trị không giảm dần, trả về ""
   string seq_sel_07 = TREND_SEL;
   string seq_sel_10 = TREND_SEL;
   string seq_sel_20 = TREND_SEL;

   for(int i = 0; i < 1; i++)
     {
      // BUY
      if(ma07[i] < ma07[i + 1])
         seq_buy_07 = "";
      if(ma10[i] < ma10[i + 1])
         seq_buy_10 = "";
      if(ma20[i] < ma20[i + 1])
         seq_buy_20 = "";

      //SEL
      if(ma07[i] > ma07[i + 1])
         seq_sel_07 = "";
      if(ma10[i] > ma10[i + 1])
         seq_sel_10 = "";
      if(ma20[i] > ma20[i + 1])
         seq_sel_20 = "";
     }
   string trend_ma07_vs10 = ma07[0] > ma10[0] ? TREND_BUY : TREND_SEL;
   string trend_ma10_vs20 = ma10[0] > ma20[0] ? TREND_BUY : TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10 == TREND_BUY && seq_buy_20 == TREND_BUY)
      trend_ma1020 = TREND_BUY;
   if(seq_buy_10 == TREND_BUY && trend_ma10_vs20 == TREND_BUY)
      trend_ma1020 = TREND_BUY;


   if(seq_sel_10 == TREND_SEL && seq_sel_20 == TREND_SEL)
      trend_ma1020 = TREND_SEL;

   if(seq_sel_10 == TREND_SEL && trend_ma10_vs20 == TREND_SEL)
      trend_ma1020 = TREND_SEL;
//----------------------------------------------------------------
   if(seq_buy_10 == TREND_BUY && seq_buy_07 == TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(seq_buy_07 == TREND_BUY && trend_ma07_vs10 == TREND_BUY)
      trend_ma0710 = TREND_BUY;
   if(closePrices[2] > ma07[2] && closePrices[1] > ma07[1] &&
      closePrices[2] > ma10[2] && closePrices[1] > ma10[1])
      trend_ma0710 = TREND_BUY;

   if(seq_sel_10 == TREND_SEL && seq_sel_07 == TREND_SEL)
      trend_ma0710 = TREND_SEL;
   if(seq_sel_07 == TREND_SEL && trend_ma07_vs10 == TREND_SEL)
      trend_ma0710 = TREND_SEL;
   if(closePrices[2] < ma07[2] && closePrices[1] < ma07[1] &&
      closePrices[2] < ma10[2] && closePrices[1] < ma10[1])
      trend_ma0710 = TREND_SEL;


   if(closePrices[1] > ma10[1])
      trend_C1ma10 = TREND_BUY;

   if(closePrices[1] < ma10[1])
      trend_C1ma10 = TREND_SEL;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_average_candle_height(ENUM_TIMEFRAMES timeframe, string symbol, int length)
  {
   int count = 0;
   double totalHeight = 0.0;

   for(int i = 0; i < length; i++)
     {
      double highPrice = iHigh(symbol, timeframe, i);
      double lowPrice = iLow(symbol, timeframe, i);
      double candleHeight = highPrice - lowPrice;

      count += 1;
      totalHeight += candleHeight;
     }

   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double averageHeight = NormalizeDouble(totalHeight / count, digits);

   return averageHeight;
  }
//+------------------------------------------------------------------+
string get_trend_reverse(string TREND)
  {
   if(is_same_symbol(TREND, TREND_BUY))
      return TREND_SEL;

   if(is_same_symbol(TREND, TREND_SEL))
      return TREND_BUY;

   return "";
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteArrowObjects()
  {
   int totalObjects = ObjectsTotal();
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i);
      if(ObjectType(objectName) == OBJ_ARROW)
         ObjectDelete(0, objectName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteObjectsFor_PERIOD_W1()
  {
   if(Period() == PERIOD_D1)
     {
      for(int row = 0; row < 10; row++)
        {
         int totalObjects = ObjectsTotal();
         for(int i = 0; i < totalObjects - 1; i++)
           {
            string objectName = ObjectName(0, i);
            if(is_same_symbol(objectName, "hei_d_"))
               ObjectDelete(0, objectName);
           }
        }
     }

   if(Period() < PERIOD_W1)
      return;

   for(int row = 0; row < 10; row++)
     {
      int totalObjects = ObjectsTotal();
      for(int i = 0; i < totalObjects - 1; i++)
        {
         string objectName = ObjectName(0, i);

         if(is_same_symbol(objectName, "Ma10W") ||
            is_same_symbol(objectName, "Ma10D") ||
            is_same_symbol(objectName, "Fibo_") ||
            is_same_symbol(objectName, "macd_main_d_") ||
            is_same_symbol(objectName, "macd_sign_d_") ||
            is_same_symbol(objectName, "hei_w_") ||
            is_same_symbol(objectName, "hei_d_")
           )
            ObjectDelete(0, objectName);
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DeleteAllObjects()
  {
   int totalObjects = ObjectsTotal();
   for(int i = 0; i < totalObjects - 1; i++)
     {
      string objectName = ObjectName(0, i);
      ObjectDelete(0, objectName);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable_simple(
   const string            name="Text",
   string                  label="Label",
   double                  price = 0,
   color                   clrColor = clrBlack
)
  {
   ObjectDelete(0, name);
   datetime time_to=TimeCurrent() + TIME_OF_ONE_H4_CANDLE;                   // anchor point time
   TextCreate(0,name, 0, time_to, price, label, clrColor);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void create_lable(
   const string            name="Text",         // object name
   datetime                time_to=0,                   // anchor point time
   double                  price=0,                   // anchor point price
   string                  label="label",                   // anchor point price
   const string            TRADING_TREND="",
   const bool              trim_text = true,
   const int               font_size=8,
   const bool              is_bold = false
)
  {
   ObjectDelete(0, name);
   color clr_color = TRADING_TREND==TREND_BUY ? clrBlue : TRADING_TREND==TREND_SEL ? clrRed : clrBlack;
   TextCreate(0,name, 0, time_to, price, trim_text ? " " + label : "        " + label, clr_color);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   if(is_bold)
      ObjectSetString(0, name, OBJPROP_FONT, "Arial Bold");
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool TextCreate(const long              chart_ID=0,               // chart's ID
                const string            name="Text",              // object name
                const int               sub_window=0,             // subwindow index
                datetime                time=0,                   // anchor point time
                double                  price=0,                  // anchor point price
                string                  text="Text",              // the text itself
                const color             clr=clrRed,               // color
                const string            font="Arial",             // font
                const int               font_size=8,              // font size
                const double            angle=0.0,                // text slope
                const ENUM_ANCHOR_POINT anchor=ANCHOR_LEFT,       // anchor type
                const bool              back=false,               // in the background
                const bool              selection=false,          // highlight to move
                const bool              hidden=true,              // hidden in the object list
                const long              z_order=0)                // priority for mouse click
  {
   ResetLastError();
   if(!ObjectCreate(chart_ID,name,OBJ_TEXT,sub_window,time,price))
     {
      Print(__FUNCTION__, ": failed to create \"Text\" object! Error code = ",GetLastError());
      return(false);
     }
   ObjectSetString(0,name,OBJPROP_TEXT, text);
   ObjectSetString(0,name,OBJPROP_FONT, font);
   ObjectSetInteger(0,name,OBJPROP_FONTSIZE,font_size);
   ObjectSetDouble(0,name,OBJPROP_ANGLE, angle);
   ObjectSetInteger(0,name,OBJPROP_ANCHOR, anchor);
   ObjectSetInteger(0,name,OBJPROP_COLOR, clr);
   ObjectSetInteger(0,name,OBJPROP_BACK, back);
   ObjectSetInteger(0,name,OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(0,name,OBJPROP_SELECTED, selection);
   ObjectSetInteger(0,name,OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(0,name,OBJPROP_ZORDER, z_order);
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_pivot(ENUM_TIMEFRAMES TIMEFRAME, string symbol, int size = 20)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_pivot(symbol, TIMEFRAME, index);
     }
   double tf_amp = total_amp / size;

   return NormalizeDouble(tf_amp, digits);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_pivot(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int tf_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double tf_hig = iHigh(symbol,  TIMEFRAME, tf_index);
   double tf_low = iLow(symbol,   TIMEFRAME, tf_index);
   double tf_clo = iClose(symbol, TIMEFRAME, tf_index);

   double w_pivot    = format_double((tf_hig + tf_low + tf_clo) / 3, digits);
   double tf_s1    = format_double((2 * w_pivot) - tf_hig, digits);
   double tf_s2    = format_double(w_pivot - (tf_hig - tf_low), digits);
   double tf_s3    = format_double(tf_low - 2 * (tf_hig - w_pivot), digits);
   double tf_r1    = format_double((2 * w_pivot) - tf_low, digits);
   double tf_r2    = format_double(w_pivot + (tf_hig - tf_low), digits);
   double tf_r3    = format_double(tf_hig + 2 * (w_pivot - tf_low), digits);

   double tf_amp = MathAbs(tf_s3 - tf_s2)
                   + MathAbs(tf_s2 - tf_s1)
                   + MathAbs(tf_s1 - w_pivot)
                   + MathAbs(w_pivot - tf_r1)
                   + MathAbs(tf_r1 - tf_r2)
                   + MathAbs(tf_r2 - tf_r3);

   tf_amp = format_double(tf_amp / 6, digits);

   return NormalizeDouble(tf_amp, digits);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectDelete(0, START_TRADE_LINE);
   EventKillTimer();
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   if(isDragging)
     {
      double newPrice = NormalizeDouble(WindowPriceOnDropped(), Digits);
      if(newPrice > 0)
        {
         ObjectSetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1, newPrice);

         INIT_START_PRICE = ObjectGetDouble(0, START_TRADE_LINE, OBJPROP_PRICE1);
         Print("OnTick START_TRADE_LINE "  + (string) INIT_START_PRICE);
         GlobalVariableSet("MyHorizontalLinePrice", INIT_START_PRICE);
        }
     }

   OnTimer();
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void WriteAvgAmpToFile()
  {
   string arr_symbol[] =
     {
      "XAUUSD"
      //, "XAGUSD", "USOIL", "BTCUSD",
      //"USTEC", "US30", "US500", "DE30", "UK100", "FR40", "AUS200",
      //"AUDCHF", "AUDNZD", "AUDUSD",
      //"AUDJPY", "CHFJPY", "EURJPY", "GBPJPY", "NZDJPY", "USDJPY",
      //"EURAUD", "EURCAD", "EURCHF", "EURGBP", "EURNZD", "EURUSD",
      //"GBPCHF", "GBPNZD", "GBPUSD",
      //"NZDCAD", "NZDUSD",
      //"USDCAD", "USDCHF"
     };

   /*
      (.*)(W1)(.*)(D1)(.*)(H4)(.*)(H1)(.*)
      if(is_same_symbol(symbol, "\1")){amp_w1 = \3;amp_d1 = \5;amp_h4 = \7;amp_h1 = \9;return;}
   */

//XAUUSD W1    57.145   D1    21.409   H4    9.345 H1    6.118 M15    4.136   M5    2.763;
//XAUUSD W1    57.145   D1    21.409   H4    8.216 H1    1.132 M15    0.187   M5    0.047;

   string file_name = "AvgAmp.txt";
   int fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
                                + "\t" + "W1: " + (string) calc_average_candle_height(PERIOD_W1, symbol, 20)
                                + "\t" + "D1: " + (string) calc_average_candle_height(PERIOD_D1, symbol, 60)
                                + "\t" + "H4: " + (string) calc_average_candle_height(PERIOD_H4, symbol, 360)
                                + "\t" + "H1: " + (string) calc_average_candle_height(PERIOD_H1, symbol, 720)
                                + "\t" + "M15: " + (string) calc_average_candle_height(PERIOD_M15, symbol, 720)
                                + "\t" + "M5: " + (string) calc_average_candle_height(PERIOD_M5, symbol, 720)
                                + ";\n";

         FileWriteString(fileHandle, file_contents);
        }
      FileClose(fileHandle);
     }

//XAUUSD W1    32.289   D1    10.591   H4    4.677 H1    3.061 M15    2.067   M5    1.382;
//XAUUSD W1    28.11    D1    10.591   H4    4.107 H1    0.566 M15    0.093   M5    0.024;

   file_name = "AvgPivot.txt";
   fileHandle = FileOpen(file_name, FILE_WRITE | FILE_TXT);
   if(fileHandle != INVALID_HANDLE)
     {
      int total_fx_size = ArraySize(arr_symbol);
      for(int index = 0; index < total_fx_size; index++)
        {
         string symbol = arr_symbol[index];
         string file_contents = symbol
                                + "\t" + "W1: " + (string) calc_avg_pivot(PERIOD_W1, symbol, 20)
                                + "\t" + "D1: " + (string) calc_avg_pivot(PERIOD_D1, symbol, 60)
                                + "\t" + "H4: " + (string) calc_avg_pivot(PERIOD_H4, symbol, 360)
                                + "\t" + "H1: " + (string) calc_avg_pivot(PERIOD_H1, symbol, 720)
                                + "\t" + "M15: " + (string) calc_avg_pivot(PERIOD_M15, symbol, 720)
                                + "\t" + "M5: " + (string) calc_avg_pivot(PERIOD_M5, symbol, 720)
                                + ";\n";

         FileWriteString(fileHandle, file_contents);
        }
      FileClose(fileHandle);
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void createChannel(string name, datetime time1, double price1, datetime time2, double price2, datetime time3, double price3)
  {
// Xóa kênh nếu đã tồn tại
   ObjectDelete(0, name);

// Tạo kênh mới
   ObjectCreate(0, name, OBJ_CHANNEL, 0, time1, price1, time2, price2, time3, price3);

// Đặt các thuộc tính cho kênh
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrRed);             // Màu của kênh
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 2);                  // Độ dày của kênh
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_SOLID);        // Kiểu đường nét của kênh
   ObjectSetInteger(0, name, OBJPROP_RAY, false);                // Không mở rộng đường kênh
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);          // Cho phép chọn kênh
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);             // Không ẩn kênh
   ObjectSetInteger(0, name, OBJPROP_BACK, false);               // Vẽ kênh phía trước các đối tượng khác
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void getGannGridProperties(string symbol, string &time1, string &time2, double &price1, double &scale)
  {
   time1 = "2020.04.05";
   time2 = "2020.10.04";
   if(is_same_symbol("AUDJPY", symbol))
     {
      price1 = 56.780251;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("NZDJPY", symbol))
     {
      price1 = 57.136103;
      scale = 120.00;
      return;
     }
   if(is_same_symbol("EURJPY", symbol))
     {
      price1 = 109.326526;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("GBPJPY", symbol))
     {
      price1 = 119.382734;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("USDJPY", symbol))
     {
      price1 = 104.781215;
      scale = 250.00;
      return;
     }
   if(is_same_symbol("AUDUSD", symbol))
     {
      price1 = 0.539664;
      scale = 100.00;
      return;
     }
   if(is_same_symbol("AUDNZD", symbol))
     {
      price1 = 0.999311;
      scale = 60;
      return;
     }
   if(is_same_symbol("EURNZD", symbol))
     {
      price1 = 1.5475;
      scale = 140;
      return;
     }
   if(is_same_symbol("GBPNZD", symbol))
     {
      price1 = 1.801365;
      scale = 120.00;
      return;
     }
   if(is_same_symbol("NZDUSD", symbol))
     {
      price1 = 0.541205;
      scale = 70;
      return;
     }
   if(is_same_symbol("EURAUD", symbol))
     {
      price1 = 1.393284;
      scale = 200;
      return;
     }
   if(is_same_symbol("AUDCHF", symbol))
     {
      price1 = 0.527752;
      scale = 90.00;
      return;
     }
   if(is_same_symbol("EURCHF", symbol))
     {
      price1 = 0.905838;
      scale = 150;
      return;
     }
   if(is_same_symbol("GBPCHF", symbol))
     {
      price1 = 1.022527;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("USDCHF", symbol))
     {
      price1 = 0.820282;
      scale = 100;
      return;
     }
   if(is_same_symbol("EURGBP", symbol))
     {
      price1 = 0.828975;
      scale = 60;
      return;
     }
   if(is_same_symbol("EURUSD", symbol))
     {
      price1 = 0.946562;
      scale = 100;
      return;
     }
   if(is_same_symbol("GBPUSD", symbol))
     {
      price1 = 1.008458;
      scale = 150.00;
      return;
     }
   if(is_same_symbol("EURCAD", symbol))
     {
      price1 = 1.268354;
      scale = 120;
      return;
     }
   if(is_same_symbol("USDCAD", symbol))
     {
      price1 = 1.196023;
      scale = 100.00;
      return;
     }
   if(is_same_symbol("XAUUSD", symbol))
     {
      price1 = 1094.10099;
      scale = 2931.52;
      return;
     }
   if(is_same_symbol("USOIL", symbol))
     {
      price1 = 7.418861;
      scale = 300.00;
      return;
     }
   if(is_same_symbol("BTCUSD", symbol))
     {
      price1 = 3635.108768;
      scale = 18992.5;
      return;
     }
   if(is_same_symbol("US30", symbol))
     {
      price1 = 18271.067371;
      scale = 800.00;
      return;
     }
   if(is_same_symbol("US500", symbol))
     {
      price1 = 2264.744749;
      scale = 1000.00;
      return;
     }
   if(is_same_symbol("USTEC", symbol))
     {
      price1 = 6185.376848;
      scale = 5555;
      return;
     }
   if(is_same_symbol("FR40", symbol))
     {
      price1 = 3247.2;
      scale = 2000.00;
      return;
     }
   if(is_same_symbol("JP225", symbol))
     {
      price1 = 14371.216374;
      scale = 1000;
      return;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createGannGrid(string name, datetime time1, datetime time2, double price1, double scale)
  {
// Xóa Gann Grid nếu đã tồn tại
   ObjectDelete(0, name);
   ResetLastError();
   if(!ObjectCreate(0,name,OBJ_GANNGRID,0,time1,price1,time2,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }

// Đặt các thuộc tính cho Gann Grid
   ObjectSetDouble(0, name, OBJPROP_SCALE, scale);
   ObjectSetInteger(0, name, OBJPROP_COLOR, clrDimGray); // Màu của Gann Grid
   ObjectSetInteger(0, name, OBJPROP_STYLE, STYLE_DOT);  // Kiểu đường nét của Gann Grid
   ObjectSetInteger(0, name, OBJPROP_WIDTH, 1);          // Độ dày của Gann Grid
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, true);  // Cho phép chọn Gann Grid
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, false);     // Không ẩn Gann Grid
   ObjectSetInteger(0, name, OBJPROP_BACK, true);        // Vẽ Gann Grid phía trước các đối tượng khác
   ObjectSetInteger(0, name, OBJPROP_SELECTED, true);
   ObjectSetInteger(0, name, OBJPROP_TIMEFRAMES, OBJ_PERIOD_W1); // OBJ_PERIOD_D1|

   return(true);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool createButton(string objName, string text, int x, int y, int width, int height, color clrTextColor, color clrBackground, int font_size=8, int sub_window = 0)
  {
   long chart_id=0;
   ObjectDelete(chart_id, objName);
   ResetLastError();
   if(!ObjectCreate(chart_id, objName, OBJ_BUTTON,sub_window,0,0))
     {
      Print(__FUNCTION__,": failed to create the button! Error code = ", GetLastError());
      return(false);
     }

   ObjectSetString(chart_id,  objName, OBJPROP_TEXT, text);
   ObjectSetInteger(chart_id, objName, OBJPROP_XDISTANCE, x);
   ObjectSetInteger(chart_id, objName, OBJPROP_YDISTANCE, y);
   ObjectSetInteger(chart_id, objName, OBJPROP_XSIZE, width);
   ObjectSetInteger(chart_id, objName, OBJPROP_YSIZE, height);
   ObjectSetInteger(chart_id, objName, OBJPROP_CORNER, CORNER_LEFT_UPPER);
   ObjectSetInteger(chart_id, objName, OBJPROP_FONTSIZE,font_size);
   ObjectSetInteger(chart_id, objName, OBJPROP_COLOR, clrTextColor);
   ObjectSetInteger(chart_id, objName, OBJPROP_BGCOLOR, clrBackground);
   ObjectSetInteger(chart_id, objName, OBJPROP_BORDER_COLOR, clrSilver);
   ObjectSetInteger(chart_id, objName, OBJPROP_BACK, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_STATE, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_SELECTABLE, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_SELECTED, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_HIDDEN, false);
   ObjectSetInteger(chart_id, objName, OBJPROP_ZORDER, 999);

   return(true);
  }
//+-----------------------------------------------------------------+
//| Creates Label object on the chart

//| int Yt[3]= {50, 350, 200}, Xt[3]= {110, 110, 110};
//| color textColor=White;
//| ObjectCreateEx("_Benefit_t1_body", Yt[0]-30, Xt[0]-5, 23, 0, true);
//| ObjectSetText("_Benefit_t1_body", "ggg", 110, "Webdings", C'62,62,62'); //Òåëî òàáëèöû áàåâ
//| ObjectCreateEx("_Benefit_t1_Header", Yt[0]-25, Xt[0]+110, 23, 0);
//| ObjectSetText("_Benefit_t1_Header", "BUY-SIDE", 16, "Dungeon", White); //Çàãîëîâîê Buy
//| ObjectCreateEx("_Benefit_t1_1_1", Yt[0], Xt[0], 23, 0);
//| ObjectSetText("_Benefit_t1_1_1", "Orders: "+DoubleToStr(buys, 0), 10, "Courier New", textColor);
//+-----------------------------------------------------------------+
void ObjectCreateEx(string objname,int YOffset, int XOffset=0, string lable="Text", color textColor=White,bool background=false)
  {
   int objType=23, corner=0;
   bool needNUL=false;
   if(ObjectFind(objname)==-1)
     {
      needNUL=true;
      ObjectCreate(objname,objType,0,0,0,0,0);
     }

   ObjectSet(objname,103,YOffset);
   ObjectSet(objname,102,XOffset);
   ObjectSet(objname,101,corner);
   ObjectSet(objname, OBJPROP_BACK, background);
   if(needNUL)
      ObjectSetText(objname,"",14,"Tahoma",Gray);

   ObjectSetText(objname, lable, 10, "Courier New", textColor);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calcPotentialTradeProfit(string symbol, int orderType, double orderOpenPrice, double orderTakeProfitPrice, double orderLots)
  {
   if(orderTakeProfitPrice == 0)
     {
      if(orderType == OP_BUY)
         orderTakeProfitPrice = get_tp_by_fixed_sl_amp(symbol, TREND_BUY);

      if(orderType == OP_SELL)
         orderTakeProfitPrice = get_tp_by_fixed_sl_amp(symbol, TREND_SEL);
     }

   double   tradeTickValuePerLot    = SymbolInfoDouble(symbol, SYMBOL_TRADE_TICK_VALUE);  //Loss/Gain for a 1 tick move with 1 lot
   double   tickValueBasedOnLots    = tradeTickValuePerLot * orderLots;
   double   priceDifference         = MathAbs(orderOpenPrice - orderTakeProfitPrice);
   int      pointsDifference        = (int)(priceDifference / Point);
   double   potentialProfit         = tickValueBasedOnLots * pointsDifference;

   if(orderType==OP_BUY)
      potentialProfit         = orderTakeProfitPrice > orderOpenPrice ? potentialProfit : -potentialProfit;

   if(orderType==OP_SELL)
      potentialProfit         = orderTakeProfitPrice > orderOpenPrice ? -potentialProfit : potentialProfit;

   return NormalizeDouble(potentialProfit, 2);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_trader_manually(string TREND)
  {
   string name = getShortName(TREND);
   string trader_name = "{^" + name + "^}_";
   return trader_name;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createLable(string header, string trend)
  {
   string str = getShortName(trend);
   if(str == "")
      return "";

   return header + " " + str;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string createLable2(string header, string lalbe)
  {
   if(lalbe == " " || lalbe == "")
      return "";

   return header + " " + lalbe;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortName(string trend)
  {
   if(is_same_symbol(trend, TREND_BUY))
      return "B";

   if(is_same_symbol(trend, TREND_SEL))
      return  "S";

   return "";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
color getColorByTrend(string trend, color clrDefault = clrNONE)
  {
   if(is_same_symbol(trend, TREND_BUY))
      return clrBlue;

   if(is_same_symbol(trend, TREND_SEL))
      return  clrRed;

   return clrDefault;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getShortStoc(string trend_over_bs_by_stoc)
  {
   string lblStoc = (is_same_symbol(trend_over_bs_by_stoc, TREND_BUY) ? "20" : "") + " " + (is_same_symbol(trend_over_bs_by_stoc, TREND_SEL) ? "80" : "");

   StringTrimLeft(lblStoc);
   StringTrimRight(lblStoc);

   if(lblStoc == " " || lblStoc == "" || lblStoc == "20 80")
      lblStoc = "";

   return lblStoc;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_candlestick(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15)
  {
   ArrayResize(candleArray, length+5);
   for(int index = length + 3; index >= 0; index--)
     {
      datetime          time  = iTime(symbol, TIME_FRAME, index);    // Thời gian
      double            open  = iOpen(symbol, TIME_FRAME, index);    // Giá mở
      double            high  = iHigh(symbol, TIME_FRAME, index);    // Giá cao
      double            low   = iLow(symbol, TIME_FRAME, index);      // Giá thấp
      double            close = iClose(symbol, TIME_FRAME, index);  // Giá đóng
      string            trend = "";
      if(open < close)
         trend = TREND_BUY;
      if(open > close)
         trend = TREND_SEL;

      CandleData candle(time, open, high, low, close, trend, 0, 0, "", 0, "", "", "", 0, "", 0, "", "");
      candleArray[index] = candle;
     }


   for(int index = length + 3; index >= 0; index--)
     {
      CandleData cancle_i = candleArray[index];

      int count_trend = 1;
      for(int j = index+1; j < length; j++)
        {
         if(cancle_i.trend_heiken == candleArray[j].trend_heiken)
            count_trend += 1;
         else
            break;
        }

      candleArray[index].count_heiken = count_trend;
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void get_arr_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, CandleData &candleArray[], int length = 15, bool is_calc_ma10 = true)
  {
   bool check_seq = false;
   if(TIME_FRAME == PERIOD_H4 || TIME_FRAME == PERIOD_H1)
     {
      length = 50;
      check_seq = true;
     }

   ArrayResize(candleArray, length+5);
     {
      datetime pre_HaTime = iTime(symbol, TIME_FRAME, length+4);
      double pre_HaOpen = iOpen(symbol, TIME_FRAME, length+4);
      double pre_HaHigh = iHigh(symbol, TIME_FRAME, length+4);
      double pre_HaLow = iLow(symbol, TIME_FRAME, length+4);
      double pre_HaClose = iClose(symbol, TIME_FRAME, length+4);
      string pre_candle_trend = pre_HaClose > pre_HaOpen ? TREND_BUY : TREND_SEL;

      CandleData candle(pre_HaTime, pre_HaOpen, pre_HaHigh, pre_HaLow, pre_HaClose, pre_candle_trend, 0, 0, "", 0, "", "", "", 0, "", 0, "", "");
      candleArray[length+4] = candle;
     }

   for(int index = length + 3; index >= 0; index--)
     {
      CandleData pre_cancle = candleArray[index + 1];

      datetime haTime = iTime(symbol, TIME_FRAME, index);
      double haClose = (iOpen(symbol, TIME_FRAME, index) + iClose(symbol, TIME_FRAME, index) + iHigh(symbol, TIME_FRAME, index) + iLow(symbol, TIME_FRAME, index)) / 4.0;
      double haOpen  = (pre_cancle.open + pre_cancle.close) / 2.0;
      double haHigh  = MathMax(MathMax(haOpen, haClose), iHigh(symbol, TIME_FRAME, index));
      double haLow   = MathMin(MathMin(haOpen, haClose),  iLow(symbol, TIME_FRAME, index));
      string haTrend = haClose >= haOpen ? TREND_BUY : TREND_SEL;

      int count_heiken = 1;
      for(int j = index+1; j < length; j++)
        {
         if(haTrend == candleArray[j].trend_heiken)
            count_heiken += 1;
         else
            break;
        }

      CandleData candle_x(haTime, haOpen, haHigh, haLow, haClose, haTrend, count_heiken, 0, "", 0, "", "", "", 0, "", 0, "", "");
      candleArray[index] = candle_x;
     }

   double lowest = 0.0, higest = 0.0;
   int range = 7;
   if(TIME_FRAME == PERIOD_H4)
      range = 6;
   if(TIME_FRAME == PERIOD_H1)
      range = 12;

   for(int idx = 0; idx <= range; idx++)
     {
      double low = candleArray[idx].low;
      double hig = candleArray[idx].high;
      if((idx == 0) || (lowest > low))
         lowest = low;
      if((idx == 0) || (higest < hig))
         higest = hig;
     }

   if(is_calc_ma10)
     {
      double closePrices[];
      int maLength = length+15;
      ArrayResize(closePrices, maLength);

      for(int i = maLength - 1; i >= 0; i--)
         closePrices[i] = iClose(symbol, TIME_FRAME, i);

      for(int index = ArraySize(candleArray)-2; index >= 0; index--)
        {
         CandleData pre_cancle = candleArray[index+1];
         CandleData cur_cancle = candleArray[index];

         double ma03 = cal_MA(closePrices,  3, index == 0 ? 1 : index);
         double ma05 = cal_MA(closePrices,  5, index == 0 ? 1 : index);
         double ma10 = cal_MA(closePrices, 10, index == 0 ? index : index);

         string trend_vector_ma10 = pre_cancle.ma10 < ma10 ? TREND_BUY : TREND_SEL;
         string trend_ma5vs10 = (ma05 > ma10) ? TREND_BUY : (ma05 < ma10) ? TREND_SEL : "";
         double mid = cur_cancle.close;
         string trend_by_ma05 = (mid > ma05) ? TREND_BUY : (mid < ma05) ? TREND_SEL : "";
         string trend_by_ma10 = (mid > ma10) ? TREND_BUY : (mid < ma10) ? TREND_SEL : "";
         int count_ma10 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_by_ma10 == candleArray[j].trend_by_ma10)
               count_ma10 += 1;
            else
               break;
           }

         string trend_ma3_vs_ma5 = (ma03 > ma05) ? TREND_BUY : (ma03 < ma05) ? TREND_SEL : "";
         int count_ma3_vs_ma5 = 1;
         for(int j = index+1; j < length+1; j++)
           {
            if(trend_ma3_vs_ma5 == candleArray[j].trend_ma3_vs_ma5)
               count_ma3_vs_ma5 += 1;
            else
               break;
           }

         double ma50 = 0;
         string trend_seq = "";
         if(check_seq && (index == 0))
           {
            ma50 = cal_MA(closePrices, 50, 1);

            string temp_seq = "";
            double ma20 = cal_MA(closePrices, 20, 1);

            if(0 < ma50 && lowest <= ma50 && ma50 <= higest)
              {
               string trend_ma03_vs_20 = (ma03 > ma20) ? TREND_BUY : (ma03 < ma20) ? TREND_SEL : "";
               string trend_ma10_vs_50 = (ma10 > ma50) ? TREND_BUY : (ma10 < ma50) ? TREND_SEL : "";
               if(trend_ma10_vs_50 == trend_ma03_vs_20 && trend_ma10_vs_50 == candleArray[0].trend_heiken)
                 {
                  temp_seq = trend_ma10_vs_50;
                 }
              }


            if(temp_seq != "")
              {
               double amp_w1, amp_d1, amp_h4, amp_grid_L100;
               GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

               double amp_seq = MathMax(MathAbs(ma03 - ma20),MathAbs(ma03 - ma50));
               if(amp_seq <= amp_d1)
                  trend_seq = temp_seq;
              }
           }

         string trend_ma10vs20 = "";
         if(TIME_FRAME == PERIOD_D1 && index == 0)
           {
            double ma20 = cal_MA(closePrices, 20, 1);
            trend_ma10vs20 = (ma10 > ma20) ? TREND_BUY : (ma10 < ma20) ? TREND_SEL : "";
           }

         CandleData candle_x(cur_cancle.time, cur_cancle.open, cur_cancle.high, cur_cancle.low, cur_cancle.close, cur_cancle.trend_heiken
                             , cur_cancle.count_heiken, ma10, trend_by_ma10, count_ma10, trend_vector_ma10
                             , trend_by_ma05, trend_ma3_vs_ma5, count_ma3_vs_ma5, trend_seq, ma50, trend_ma10vs20, trend_ma5vs10);

         candleArray[index] = candle_x;
        }

     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string get_trend_by_heiken(string symbol, ENUM_TIMEFRAMES TIME_FRAME, int candle_index = 0)
  {
   CandleData candleArray[];
   get_arr_heiken(symbol, TIME_FRAME, candleArray);

   return candleArray[candle_index].trend_heiken;
  }
//+------------------------------------------------------------------+
double get_largest_negative(string TRADER)
  {
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name, TRADER))
         return MathAbs(NormalizeDouble(arr_largest_negative_trader_amount[i], 2));
     }

   return 0;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void set_largest_negative(string TRADER, double profit)
  {
   if(profit > 0)
      return;

   double found_trader = false;
   for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
     {
      string name = arr_largest_negative_trader_name[i];
      if(is_same_symbol(name, TRADER))
        {
         found_trader = true;
         if(MathAbs(arr_largest_negative_trader_amount[i]) < MathAbs(profit))
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
        }
     }

   if(found_trader == false)
     {
      for(int i = 0; i < ArraySize(arr_largest_negative_trader_name); i++)
        {
         string name = arr_largest_negative_trader_name[i];
         if(name == "" || StringLen(name) < 1)
           {
            arr_largest_negative_trader_name[i] = TRADER;
            arr_largest_negative_trader_amount[i] = MathAbs(profit);
            return;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double risk_10_percent_by_init_equity()
//  {
//   double dbValueRisk = INIT_EQUITY * dbRiskRatio;
//   double max_risk = INIT_EQUITY*0.1;
//   if(dbValueRisk > max_risk)
//     {
//      Alert("(", INDI_NAME, ") Risk = ", (string) dbValueRisk,"$/trade is greater than " + (string) max_risk + " per order. Too dangerous.");
//      return max_risk;
//     }
//
//   return dbValueRisk;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double minProfit()
  {
   return risk_1_Percent_Account_Balance()*0.01;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double risk_10_Percent_Account_Balance()
//  {
//   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
//   return BALANCE*0.1;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//double risk_5p_Percent_Account_Equity()
//  {
//   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
//   return EQUITY*0.05;
//  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double risk_1_Percent_Account_Balance()
  {
//double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double BALANCE = INIT_EQUITY;
   return BALANCE*0.01;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double risk_250Usc()
  {
   return 250;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_comment(string TRADER, string TRADING_TREND, int L)
  {
   string result = TRADER + TRADING_TREND + "_" + appendZero100(L);

   return result;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int get_L(string TRADER, string trend, string last_comment)
  {
   for(int i = 1; i < 100; i++)
     {
      string comment = create_comment(TRADER, trend, i);
      if(is_same_symbol(last_comment, comment))
         return i;
     }

   return 0;
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetAmpAvgL15(string symbol, double &amp_w1, double &amp_d1, double &amp_h4, double &amp_grid_L100)
  {
   if(is_same_symbol(symbol, "XAUUSD"))
     {
      amp_w1 = 83.539;
      amp_d1 = 31.359;
      amp_h4 = 6.295;
      amp_grid_L100 = 5;
      return;
     }
   if(is_same_symbol(symbol, "XAGUSD"))
     {
      amp_w1 = 1.3;
      amp_d1 = 0.45;
      amp_h4 = 0.2;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USOIL"))
     {
      amp_w1 = 3.935;
      amp_d1 = 1.656;
      amp_h4 = 0.805;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      amp_w1 = 7010.38;
      amp_d1 = 2930.00;
      amp_h4 = 789.1;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USTEC"))
     {
      amp_w1 = 785.89;
      amp_d1 = 350.00;
      amp_h4 = 81.16;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US30"))
     {
      amp_w1 = 1037.8;
      amp_d1 = 427.0;
      amp_h4 = 119.5;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "US500"))
     {
      amp_w1 = 150.5;
      amp_d1 = 64.88;
      amp_h4 = 16.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "DE30"))
     {
      amp_w1 = 530.6;
      amp_d1 = 156.6;
      amp_h4 = 62.3;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "UK100"))
     {
      amp_w1 = 208.25;
      amp_d1 = 68.31;
      amp_h4 = 29.0;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "FR40"))
     {
      amp_w1 = 250.00;
      amp_d1 = 100.00;
      amp_h4 = 30.00;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "JP225"))
     {
      amp_w1 = 1955.00;
      amp_d1 = 898.00;
      amp_h4 = 700.00;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUS200"))
     {
      amp_w1 = 204.43;
      amp_d1 = 67.52;
      amp_h4 = 29.93;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDCHF"))
     {
      amp_w1 = 0.01242;
      amp_d1 = 0.00500;
      amp_h4 = 0.00158;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDNZD"))
     {
      amp_w1 = 0.01036;
      amp_d1 = 0.00495;
      amp_h4 = 0.00178;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDUSD"))
     {
      amp_w1 = 0.01267;
      amp_d1 = 0.00452;
      amp_h4 = 0.00218;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "AUDJPY"))
     {
      amp_w1 = 2.950;
      amp_d1 = 1.165;
      amp_h4 = 0.282;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "CHFJPY"))
     {
      amp_w1 = 2.911;
      amp_d1 = 1.107;
      amp_h4 = 0.458;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURJPY"))
     {
      amp_w1 = 3.700;
      amp_d1 = 1.642;
      amp_h4 = 0.434;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPJPY"))
     {
      amp_w1 = 4.600;
      amp_d1 = 2.115;
      amp_h4 = 0.53;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "NZDJPY"))
     {
      amp_w1 = 2.419;
      amp_d1 = 1.068;
      amp_h4 = 0.272;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDJPY"))
     {
      amp_w1 = 3.550;
      amp_d1 = 1.659;
      amp_h4 = 0.427;
      amp_grid_L100 = 1.5;
      return;
     }
   if(is_same_symbol(symbol, "EURAUD"))
     {
      amp_w1 = 0.02215;
      amp_d1 = 0.00954;
      amp_h4 = 0.00417;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCAD"))
     {
      amp_w1 = 0.01382;
      amp_d1 = 0.00562;
      amp_h4 = 0.00284;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURCHF"))
     {
      amp_w1 = 0.01309;
      amp_d1 = 0.00525;
      amp_h4 = 0.00180;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURGBP"))
     {
      amp_w1 = 0.00695;
      amp_d1 = 0.00283;
      amp_h4 = 0.00131;
      amp_grid_L100 = 0.00155;
      return;
     }
   if(is_same_symbol(symbol, "EURNZD"))
     {
      amp_w1 = 0.02402;
      amp_d1 = 0.01128;
      amp_h4 = 0.00478;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "EURUSD"))
     {
      amp_w1 = 0.01257;
      amp_d1 = 0.00456;
      amp_h4 = 0.00239;
      amp_grid_L100 = 0.0035;
      return;
     }
   if(is_same_symbol(symbol, "GBPCHF"))
     {
      amp_w1 = 0.01905;
      amp_d1 = 0.00752;
      amp_h4 = 0.00241;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPNZD"))
     {
      amp_w1 = 0.02912;
      amp_d1 = 0.01240;
      amp_h4 = 0.00531;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "GBPUSD"))
     {
      amp_w1 = 0.01652;
      amp_d1 = 0.00630;
      amp_h4 = 0.00317;
      amp_grid_L100 = 0.00335;
      return;
     }
   if(is_same_symbol(symbol, "NZDCAD"))
     {
      amp_w1 = 0.01459;
      amp_d1 = 0.0055;
      amp_h4 = 0.00216;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "NZDUSD"))
     {
      amp_w1 = 0.01106;
      amp_d1 = 0.00435;
      amp_h4 = 0.0021;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      amp_w1 = 0.01328;
      amp_d1 = 0.00462;
      amp_h4 = 0.00252;
      amp_grid_L100 = 0;
      return;
     }
   if(is_same_symbol(symbol, "USDCHF"))
     {
      amp_w1 = 0.01397;
      amp_d1 = 0.00569;
      amp_h4 = 0.00235;
      amp_grid_L100 = 0.006;
      return;
     }

   amp_w1 = calc_average_candle_height(PERIOD_W1, symbol, 20);
   amp_d1 = calc_average_candle_height(PERIOD_D1, symbol, 30);
   amp_h4 = calc_average_candle_height(PERIOD_H4, symbol, 60);
   amp_grid_L100 = amp_d1;
//SendAlert(INDI_NAME, "Get Amp Avg", " Get AmpAvg:" + (string)symbol + "   amp_w1: " + (string)amp_w1 + "   amp_d1: " + (string)amp_d1 + "   amp_h4: " + (string)amp_h4);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void GetSymbolData(string symbol, double &i_top_price, double &amp_w, double &dic_amp_init_h4, double &dic_amp_init_d1)
  {
   if(is_same_symbol(symbol, "BTCUSD"))
     {
      i_top_price = 36285;
      dic_amp_init_d1 = 0.05;
      amp_w = 1357.35;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USOIL"))
     {
      i_top_price = 120.000;
      dic_amp_init_d1 = 0.10;
      amp_w = 2.75;
      dic_amp_init_h4 = 0.05;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "XAGUSD"))
     {
      i_top_price = 25.7750;
      dic_amp_init_d1 = 0.06;
      amp_w = 0.63500;
      dic_amp_init_h4 = 0.03;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "XAUUSD"))
     {
      i_top_price = 2088;
      dic_amp_init_d1 = 0.03;
      amp_w = 27.83;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US500"))
     {
      i_top_price = 4785;
      dic_amp_init_d1 = 0.05;
      amp_w = 60.00;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US100.cash") || is_same_symbol(symbol, "USTEC"))
     {
      i_top_price = 16950;
      dic_amp_init_d1 = 0.05;
      amp_w = 274.5;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "US30"))
     {
      i_top_price = 38100;
      dic_amp_init_d1 = 0.05;
      amp_w = 438.76;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "UK100"))
     {
      i_top_price = 7755.65;
      dic_amp_init_d1 = 0.05;
      amp_w = 95.38;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GER40"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "DE30"))
     {
      i_top_price = 16585;
      dic_amp_init_d1 = 0.05;
      amp_w = 222.45;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "FRA40") || is_same_symbol(symbol, "FR40"))
     {
      i_top_price = 7150;
      dic_amp_init_d1 = 0.05;
      amp_w = 117.6866;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUS200"))
     {
      i_top_price = 7495;
      dic_amp_init_d1 = 0.05;
      amp_w = 93.59;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDJPY"))
     {
      i_top_price = 98.5000;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.100;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDUSD"))
     {
      i_top_price = 0.7210;
      dic_amp_init_d1 = 0.03;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.015;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURAUD"))
     {
      i_top_price = 1.71850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01365;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURGBP"))
     {
      i_top_price = 0.9010;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00497;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURUSD"))
     {
      i_top_price = 1.12465;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0080;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPUSD"))
     {
      i_top_price = 1.315250;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }
   if(is_same_symbol(symbol, "USDCAD"))
     {
      i_top_price = 1.38950;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00795;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USDCHF"))
     {
      i_top_price = 0.93865;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00750;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "USDJPY"))
     {
      i_top_price = 154.525;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.4250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CADCHF"))
     {
      i_top_price = 0.702850;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.02;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CADJPY"))
     {
      i_top_price = 111.635;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.0250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "CHFJPY"))
     {
      i_top_price = 171.450;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.365000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURJPY"))
     {
      i_top_price = 162.565;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.43500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPJPY"))
     {
      i_top_price = 188.405;
      dic_amp_init_d1 = 0.02;
      amp_w = 1.61500;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDJPY"))
     {
      i_top_price = 90.435;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.90000;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURCAD"))
     {
      i_top_price = 1.5225;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00945;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURCHF"))
     {
      i_top_price = 0.96800;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "EURNZD"))
     {
      i_top_price = 1.89655;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01585;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPAUD"))
     {
      i_top_price = 1.9905;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01575;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPCAD"))
     {
      i_top_price = 1.6885;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.01210;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPCHF"))
     {
      i_top_price = 1.11485;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0085;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "GBPNZD"))
     {
      i_top_price = 2.09325;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.016250;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDCAD"))
     {
      i_top_price = 0.90385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.0075;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDCHF"))
     {
      i_top_price = 0.654500;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.005805;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "AUDNZD"))
     {
      i_top_price = 1.09385;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00595;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDCAD"))
     {
      i_top_price = 0.84135;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.007200;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDCHF"))
     {
      i_top_price = 0.55;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00515;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "NZDUSD"))
     {
      i_top_price = 0.6275;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.00660;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   if(is_same_symbol(symbol, "DXY"))
     {
      i_top_price = 103.458;
      dic_amp_init_d1 = 0.02;
      amp_w = 0.6995;
      dic_amp_init_h4 = 0.01;
      i_top_price = iClose(symbol, PERIOD_W1, 1);
      return;
     }

   i_top_price = iClose(symbol, PERIOD_W1, 1);
   dic_amp_init_d1 = calc_avg_amp_week(symbol, PERIOD_D1, 50);
   amp_w = calc_avg_amp_week(symbol, PERIOD_W1, 50);
   dic_amp_init_h4 = calc_avg_amp_week(symbol, PERIOD_H4, 50);

   SendAlert(INDI_NAME, "SymbolData", " Get SymbolData:" + (string)symbol + "   i_top_price: " + (string)i_top_price + "   amp_w: " + (string)amp_w + "   dic_amp_init_h4: " + (string)dic_amp_init_h4);
   return;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_avg_amp_week(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int size = 20)
  {
   double total_amp = 0.0;
   for(int index = 1; index <= size; index ++)
     {
      total_amp = total_amp + calc_week_amp(symbol, TIMEFRAME, index);
     }
   double week_amp = total_amp / size;

   return week_amp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double calc_week_amp(string symbol, ENUM_TIMEFRAMES TIMEFRAME, int week_index)
  {
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);// number of decimal places

   double week_hig = iHigh(symbol,  TIMEFRAME, week_index);
   double week_low = iLow(symbol,   TIMEFRAME, week_index);
   double week_clo = iClose(symbol, TIMEFRAME, week_index);

   double w_pivot    = format_double((week_hig + week_low + week_clo) / 3, digits);
   double week_s1    = format_double((2 * w_pivot) - week_hig, digits);
   double week_s2    = format_double(w_pivot - (week_hig - week_low), digits);
   double week_s3    = format_double(week_low - 2 * (week_hig - w_pivot), digits);
   double week_r1    = format_double((2 * w_pivot) - week_low, digits);
   double week_r2    = format_double(w_pivot + (week_hig - week_low), digits);
   double week_r3    = format_double(week_hig + 2 * (w_pivot - week_low), digits);

   double week_amp = MathAbs(week_s3 - week_s2)
                     + MathAbs(week_s2 - week_s1)
                     + MathAbs(week_s1 - w_pivot)
                     + MathAbs(w_pivot - week_r1)
                     + MathAbs(week_r1 - week_r2)
                     + MathAbs(week_r2 - week_r3);

   week_amp = format_double(week_amp / 6, digits);

   return week_amp;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateTodayProfitLoss()
  {
   double totalProfitLoss = 0.0; // Variable to store total profit or loss

// Get the current date
   datetime today = StringToTime(TimeToStr(TimeCurrent(), TIME_DATE));

// Loop through closed orders in account history
   count_closed_today = 0;
   for(int i = OrdersHistoryTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS, MODE_HISTORY))
        {
         // Check if the order was closed today
         if(OrderCloseTime() >= today)
           {
            int type = OrderType();
            if(type == OP_BUY  || type == OP_BUYLIMIT  || type == OP_BUYSTOP ||
               type == OP_SELL || type == OP_SELLLIMIT || type == OP_SELLSTOP)
              {
               totalProfitLoss += OrderProfit();
               count_closed_today += 1;
              }
           }
        }
     }

   return totalProfitLoss; // Return the total profit or loss
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void deleteIndicatorsWindows()
  {
   long chart_id = ChartID();

   int windowCount = 100;  // Assumed maximum number of windows for safety
   for(int windowIndex = 1; windowIndex < windowCount; windowIndex++)
     {
      int indicatorCount = ChartIndicatorsTotal(chart_id, windowIndex);
      if(indicatorCount <= 0)
         continue;

      for(int i = indicatorCount - 1; i >= 0; i--)
        {
         string indicatorName = ChartIndicatorName(chart_id, windowIndex, i);

         if(!ChartIndicatorDelete(chart_id, windowIndex, indicatorName))
           {
           }
        }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateRemainder(double price, double AMP_DCA_MIN)
  {
   return NormalizeDouble(MathMod(price, AMP_DCA_MIN), Digits-1);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double CalculateQuotient(double price, double AMP_DCA_MIN)
  {
   return MathFloor(price / AMP_DCA_MIN);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string create_Cno()
  {
   return "";

   double bid = SymbolInfoDouble(Symbol(), SYMBOL_BID);
   double ask = SymbolInfoDouble(Symbol(), SYMBOL_ASK);
   double price = (bid+ask)/2;
   double step = NormalizeDouble(AMP_DC / (NUMBER_OF_TRADER), 2);
   double rm1 = CalculateRemainder(price, AMP_DC);
   double rm2 = CalculateQuotient(rm1, step); //0.25: 20 Traders, 0.5: 10 Traders

   return "(C" + (string) + rm2 + ")";
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool is_doji_heiken_ashi(CandleData &candleArray[], int candle_index)
  {
   double open = candleArray[candle_index].open;
   double high = candleArray[candle_index].high;
   double low = candleArray[candle_index].low;
   double close = candleArray[candle_index].close;

   double body = MathAbs(open - close) * 3;
   double shadow_hig = high - MathMax(open, close);
   double shadow_low = MathMin(open, close) - low;

   bool isDoji = (body <= shadow_hig) && (body <= shadow_low);

   return isDoji;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string to_percent(double profit, double decimal_part = 2)
  {
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   string percent = " (" + format_double_to_string(profit/BALANCE * 100, 1) + "%)";
   return percent;
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int getArraySymbolsSize()
  {
   if(is_same_symbol(REAL_ACCOUNT, (string)AccountNumber()))
      return ArraySize(ARR_SYMBOLS_CENT);

   return ArraySize(ARR_SYMBOLS_USD);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getSymbolAtIndex(int index)
  {
   if(is_same_symbol(REAL_ACCOUNT, (string)AccountNumber()))
      return ARR_SYMBOLS_CENT[index];
   else
      return ARR_SYMBOLS_USD[index];
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool allowSendMsgByAccount()
  {
   if(is_same_symbol(REAL_ACCOUNT, (string)AccountNumber()))
      return true;

   return false;
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void Draw_Buttons_Trend(string symbol)
  {
   if(is_same_symbol(symbol, Symbol()) == false)
      return;

   string trend_by_macd_w1 = "", trend_mac_vs_signal_w1 = "", trend_mac_vs_zero_w1 = "", trend_vector_histogram_w1 = "", trend_vector_signal_w1 = "", trend_macd_note_w1="";
   string trend_by_macd_d1 = "", trend_mac_vs_signal_d1 = "", trend_mac_vs_zero_d1 = "", trend_vector_histogram_d1 = "", trend_vector_signal_d1 = "", trend_macd_note_d1="";
   string trend_by_macd_h4 = "", trend_mac_vs_signal_h4 = "", trend_mac_vs_zero_h4 = "", trend_vector_histogram_h4 = "", trend_vector_signal_h4 = "", trend_macd_note_h4="";
   string trend_by_macd_h1 = "", trend_mac_vs_signal_h1 = "", trend_mac_vs_zero_h1 = "", trend_vector_histogram_h1 = "", trend_vector_signal_h1 = "", trend_macd_note_h1="";

   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_W1, trend_by_macd_w1, trend_mac_vs_signal_w1, trend_mac_vs_zero_w1, trend_vector_histogram_w1, trend_vector_signal_w1, trend_macd_note_w1);
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_D1, trend_by_macd_d1, trend_mac_vs_signal_d1, trend_mac_vs_zero_d1, trend_vector_histogram_d1, trend_vector_signal_d1, trend_macd_note_d1);
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H4, trend_by_macd_h4, trend_mac_vs_signal_h4, trend_mac_vs_zero_h4, trend_vector_histogram_h4, trend_vector_signal_h4, trend_macd_note_h4);
   get_trend_by_macd_and_signal_vs_zero(symbol, PERIOD_H1, trend_by_macd_h1, trend_mac_vs_signal_h1, trend_mac_vs_zero_h1, trend_vector_histogram_h1, trend_vector_signal_h1, trend_macd_note_h1);

   CandleData arrHeiken_w1[];
   CandleData arrHeiken_d1[];
   CandleData arrHeiken_h4[];
   CandleData arrHeiken_h1[];
   get_arr_heiken(symbol, PERIOD_W1, arrHeiken_w1, 15, true);
   get_arr_heiken(symbol, PERIOD_D1, arrHeiken_d1, 35, true);
   get_arr_heiken(symbol, PERIOD_H4, arrHeiken_h4, 20, true);
   get_arr_heiken(symbol, PERIOD_H1, arrHeiken_h1, 20, true);
   string trend_by_ma10_w1 = arrHeiken_w1[0].trend_by_ma10;
   string trend_by_ma10_d1 = arrHeiken_d1[0].trend_by_ma10;
   string trend_by_ma10_h4 = arrHeiken_h4[0].trend_by_ma10;
   string trend_by_ma10_h1 = arrHeiken_h1[0].trend_by_ma10;

   int chart_width = (int) MathRound(ChartGetInteger(0, CHART_WIDTH_IN_PIXELS));
   int chart_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS));
   int x_max = chart_width - 70;
   int y_start = 80;
   int y_row_m4 = y_start - 20*11 - 5*6;
   int y_row_m3 = y_start - 20*10 - 5*5;
   int y_row_m2 = y_start - 20*9  - 5*4;
   int y_row_m1 = y_start - 20*7 - 5*2;
   int y_row_0  = y_start - 20*6 - 5*1;
   int y_row_1  = y_start - 20*5 + 5*0;
   int y_row_2  = y_start - 20*4 + 5*1;
   int y_row_3  = y_start - 20*3 + 5*2;
   int y_row_4  = y_start - 20*2 + 5*3;
   int y_row_5  = y_start - 20*1 + 5*4;
   int y_row_6  = y_start - 20*0 + 5*5;

   string trend_over_bs_by_stoc_w1 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_W1);
   string trend_over_bs_by_stoc_d1 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_D1);
   string trend_over_bs_by_stoc_h4 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_H4);
   string trend_over_bs_by_stoc_h1 = get_trend_allow_trade_now_by_stoc(symbol, PERIOD_H1);

   string lblStocW1 = getShortStoc(trend_over_bs_by_stoc_w1);
   string lblStocD1 = getShortStoc(trend_over_bs_by_stoc_d1);
   string lblStocH4 = getShortStoc(trend_over_bs_by_stoc_h4);
   string lblStocH1 = getShortStoc(trend_over_bs_by_stoc_h1);

   string Notice_Symbol = (string) GetGlobalVariable(SendTeleMsg_ + symbol);
   string key_d1_buy = (string)PERIOD_D1 + (string)OP_BUY;
   string key_d1_sel = (string)PERIOD_D1 + (string)OP_SELL;
   string key_h4_buy = (string)PERIOD_H4 + (string)OP_BUY;
   string key_h4_sel = (string)PERIOD_H4 + (string)OP_SELL;
   string key_h1_buy = (string)PERIOD_H1 + (string)OP_BUY;
   string key_h1_sel = (string)PERIOD_H1 + (string)OP_SELL;

   string lblMsgD1 = "(D1) Msg " + (is_same_symbol(Notice_Symbol, key_d1_buy) ? TREND_BUY : "") + (is_same_symbol(Notice_Symbol, key_d1_sel) ? TREND_SEL : "");
   if(is_same_symbol(lblMsgD1, TREND_BUY) && is_same_symbol(lblMsgD1, TREND_SEL))
      lblMsgD1 = "(D1) Msg";
   color bgColorD1 = is_same_symbol(Notice_Symbol, key_d1_buy) ? clrActiveBtn : is_same_symbol(Notice_Symbol, key_d1_sel) ? clrMistyRose : clrLightGray;

   string lblMsgH4 = "(H4) Msg " + (is_same_symbol(Notice_Symbol, key_h4_buy) ? TREND_BUY : "") + (is_same_symbol(Notice_Symbol, key_h4_sel) ? TREND_SEL : "");
   if(is_same_symbol(lblMsgH4, TREND_BUY) && is_same_symbol(lblMsgH4, TREND_SEL))
      lblMsgH4 = "(H4) Msg";
   color bgColorH4 = is_same_symbol(Notice_Symbol, key_h4_buy) ? clrActiveBtn : is_same_symbol(Notice_Symbol, key_h4_sel) ? clrMistyRose : clrLightGray;

   string lblMsgH1 = "(H1) Msg " + (is_same_symbol(Notice_Symbol, key_h1_buy) ? TREND_BUY : "") + (is_same_symbol(Notice_Symbol, key_h1_sel) ? TREND_SEL : "");
   if(is_same_symbol(lblMsgH1, TREND_BUY) && is_same_symbol(lblMsgH1, TREND_SEL))
      lblMsgH1 = "(H1) Msg";
   color bgColorH1 = is_same_symbol(Notice_Symbol, key_h1_buy) ? clrActiveBtn : is_same_symbol(Notice_Symbol, key_h1_sel) ? clrMistyRose : clrLightGray;

   int chart_mid_heigh = (int)(chart_heigh/2 - 50 + 25*3);
   createButton(BtnSendNotice_D1, lblMsgD1, 10, chart_mid_heigh+25*4, 95, 20, clrBlack, bgColorD1, 7);
   createButton(BtnSendNotice_H4, lblMsgH4, 10, chart_mid_heigh+25*5, 95, 20, clrBlack, bgColorH4, 7);
   createButton(BtnSendNotice_H1, lblMsgH1, 10, chart_mid_heigh+25*6, 95, 20, clrBlack, bgColorH1, 7);

   string PROFIT = (string)(int)AccountInfoDouble(ACCOUNT_PROFIT);
   createButton(BtnCloseAllTicket, "CloseAll: " + PROFIT + "$", 10, 50, 95, 20, clrBlack, clrWhite, 7);


   int sub_window = 3;
   createButton("Ma10",  "Ma10", x_max - 65*4, y_row_2, 63, 20, clrBlack, clrWhite, 7, sub_window);
   createButton(BtnTrend + "Ma10W1",   "W1 " + getShortName(arrHeiken_w1[0].trend_by_ma10) + ":" + (string)arrHeiken_w1[0].count_ma10,  x_max - 65*3, y_row_2, 63, 20, trend_by_ma10_w1 == TREND_BUY ? clrBlue:clrRed, clrWhite, 7, sub_window);
   createButton(BtnTrend + "Ma10D1",   "D "  + getShortName(arrHeiken_d1[0].trend_by_ma10) + ""  + (string)arrHeiken_d1[0].count_ma10,  x_max - 65*2, y_row_2, 63, 20, trend_by_ma10_d1 == TREND_BUY ? clrBlue:clrRed, clrWhite,11, sub_window);
   createButton(BtnTrend + "Ma10H4",   "H4 " + getShortName(arrHeiken_h4[0].trend_by_ma10) + ":" + (string)arrHeiken_h4[0].count_ma10,  x_max - 65*1, y_row_2, 63, 20, trend_by_ma10_h4 == TREND_BUY ? clrBlue:clrRed, clrWhite, 7, sub_window);
   createButton(BtnTrend + "Ma10H1",   "H1 " + getShortName(arrHeiken_h1[0].trend_by_ma10) + ":" + (string)arrHeiken_h1[0].count_ma10,  x_max - 65*0, y_row_2, 63, 20, trend_by_ma10_h1 == TREND_BUY ? clrBlue:clrRed, clrWhite, 7, sub_window);

   createButton("Heiken", "Heiken",                                                                                          x_max - 65*4, y_row_3, 63, 20, clrBlack, clrWhite,                                                       7, sub_window);
   createButton(BtnTrend + "HeiW1[0]", "W1 " + getShortName(arrHeiken_w1[0].trend_heiken) + ":" + (string)arrHeiken_w1[0].count_heiken, x_max - 65*3, y_row_3, 63, 20, arrHeiken_w1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrWhite, 7, sub_window);
   createButton(BtnTrend + "HeiD1[0]", "D "  + getShortName(arrHeiken_d1[0].trend_heiken)       + (string)arrHeiken_d1[0].count_heiken, x_max - 65*2, y_row_3, 63, 20, arrHeiken_d1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrWhite,11, sub_window);
   createButton(BtnTrend + "HeiH4[0]", "H4 " + getShortName(arrHeiken_h4[0].trend_heiken) + ":" + (string)arrHeiken_h4[0].count_heiken, x_max - 65*1, y_row_3, 63, 20, arrHeiken_h4[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrWhite, 7, sub_window);
   createButton(BtnTrend + "HeiH1[0]", "H1 " + getShortName(arrHeiken_h1[0].trend_heiken) + ":" + (string)arrHeiken_h1[0].count_heiken, x_max - 65*0, y_row_3, 63, 20, arrHeiken_h1[0].trend_heiken == TREND_BUY ? clrBlue:clrRed, clrWhite, 7, sub_window);

   createButton("MacdH4",     "Macd", x_max - 65*4, y_row_4, 63, 20, clrBlack, clrWhite, 7, sub_window);
   createButton(BtnTrend + "Mac.Sig.W1", "W1 " + trend_vector_histogram_w1, x_max - 65*3, y_row_4, 63, 20, getColorByTrend(trend_vector_histogram_w1, clrBlack),  clrWhite, 7, sub_window);
   createButton(BtnTrend + "Mac.Sig.D1", "D1 " + trend_mac_vs_signal_d1,    x_max - 65*2, y_row_4, 63, 20, getColorByTrend(trend_mac_vs_signal_d1, clrBlack),     clrWhite, 7, sub_window);
   createButton(BtnTrend + "Mac.Sig.H4", "H4 " + trend_mac_vs_signal_h4,    x_max - 65*1, y_row_4, 63, 20, getColorByTrend(trend_mac_vs_signal_h4, clrBlack),     clrWhite, 7, sub_window);
   createButton(BtnTrend + "Mac.Sig.H1", "H1 " + trend_mac_vs_signal_h1,    x_max - 65*0, y_row_4, 63, 20, getColorByTrend(trend_mac_vs_signal_h1, clrBlack),     clrWhite, 7, sub_window);


   int    count_stoc_21_d1 = 0,  count_stoc_21_h4 = 0,  count_stoc_21_h1 = 0;
   string trend_stoc_21_d1 = "", trend_stoc_21_h4 = "", trend_stoc_21_h1 = "";
   Count_Stoc_Candles(symbol, PERIOD_D1, trend_stoc_21_d1, count_stoc_21_d1,21,7,7);
   Count_Stoc_Candles(symbol, PERIOD_H4, trend_stoc_21_h4, count_stoc_21_h4,21,7,7);
   Count_Stoc_Candles(symbol, PERIOD_H1, trend_stoc_21_h1, count_stoc_21_h1,21,7,7);

   createButton("Stoc",  "Stoc", x_max - 65*4, y_row_5, 63, 20, clrBlack, clrWhite, 7, sub_window);
   createButton(BtnTrend + "Sto.D1", "D." +  getShortName(trend_stoc_21_d1) + "." + (string)count_stoc_21_d1, x_max - 65*2, y_row_5, 63, 20, is_same_symbol(trend_stoc_21_d1, TREND_BUY) ? clrBlue:clrRed, clrWhite, 7, sub_window);
   createButton(BtnTrend + "Sto.H4", "H4." + getShortName(trend_stoc_21_h4) + "." + (string)count_stoc_21_h4, x_max - 65*1, y_row_5, 63, 20, is_same_symbol(trend_stoc_21_h4, TREND_BUY) ? clrBlue:clrRed, clrWhite, 7, sub_window);
   createButton(BtnTrend + "Sto.H1", "H1." + getShortName(trend_stoc_21_h1) + "." + (string)count_stoc_21_h1, x_max - 65*0, y_row_5, 63, 20, is_same_symbol(trend_stoc_21_h1, TREND_BUY) ? clrBlue:clrRed, clrWhite, 7, sub_window);

   createButton(BtnTrend + "TocW1", createLable2("W1", lblStocW1), x_max - 65*3, y_row_6, 63, 20, is_same_symbol(lblStocW1, "20") ? clrBlue: is_same_symbol(lblStocW1, "80") ? clrRed : clrBlack, clrWhite, 7, sub_window);
   createButton(BtnTrend + "TocD1", createLable2("D1", lblStocD1), x_max - 65*2, y_row_6, 63, 20, is_same_symbol(lblStocD1, "20") ? clrBlue: is_same_symbol(lblStocD1, "80") ? clrRed : clrBlack, clrWhite, 7, sub_window);
   createButton(BtnTrend + "TocH4", createLable2("H4", lblStocH4), x_max - 65*1, y_row_6, 63, 20, is_same_symbol(lblStocH4, "20") ? clrBlue: is_same_symbol(lblStocH4, "80") ? clrRed : clrBlack, clrWhite, 7, sub_window);
   createButton(BtnTrend + "TocH1", createLable2("H1", lblStocH1), x_max - 65*0, y_row_6, 63, 20, is_same_symbol(lblStocH1, "20") ? clrBlue: is_same_symbol(lblStocH1, "80") ? clrRed : clrBlack, clrWhite, 7, sub_window);


   int chart_stoc_heigh = (int) MathRound(ChartGetInteger(0, CHART_HEIGHT_IN_PIXELS, 2))/5;
   string lblStoc21D = "D." + trend_stoc_21_d1 + ".c" + (string)count_stoc_21_d1
                       + " H4." + trend_stoc_21_h4 + ".c" + (string)count_stoc_21_h4;

   createButton(BtnTrend + "Stoc21D", lblStoc21D, chart_width - 265, chart_stoc_heigh+5, 260, chart_stoc_heigh*3-7, clrBlack, trend_stoc_21_d1 == trend_stoc_21_h4 ? clrActiveBtn : clrLightGray, 8, 2);
   if(trend_stoc_21_d1 == trend_stoc_21_h4)
      ObjectSetString(0, BtnTrend + "Stoc21D", OBJPROP_FONT, "Arial Bold");

   string TF = get_current_timeframe_to_string();
   if(TF != "??")
     {
      ObjectSetString(0, BtnTrend + "Ma10" + TF, OBJPROP_FONT, "Arial Bold");
      ObjectSetString(0, BtnTrend + "Hei" + TF + "[0]", OBJPROP_FONT, "Arial Bold");
      ObjectSetString(0, BtnTrend + "Mac.Sig." + TF, OBJPROP_FONT, "Arial Bold");
      ObjectSetString(0, BtnTrend + "Toc" + TF, OBJPROP_FONT, "Arial Bold");
      ObjectSetString(0, BtnTrend + "Sto." + TF, OBJPROP_FONT, "Arial Bold");
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string GetComments()
  {
   if(is_main_control_screen() == false)
      return "";

   string symbol = Symbol();
   double profit_today = CalculateTodayProfitLoss();
   double EQUITY = AccountInfoDouble(ACCOUNT_EQUITY);
   double BALANCE = AccountInfoDouble(ACCOUNT_BALANCE);
   double PL=EQUITY - BALANCE;
   string percent = to_percent(profit_today);

   double bid = SymbolInfoDouble(symbol, SYMBOL_BID);
   double ask = SymbolInfoDouble(symbol, SYMBOL_ASK);
   double price = (bid+ask)/2;
   int digits = (int)SymbolInfoInteger(symbol, SYMBOL_DIGITS);

   CandleData arrHeiken[];
   get_arr_heiken(symbol, PERIOD_CURRENT, arrHeiken);

   color clrHeiken = arrHeiken[1].trend_heiken == TREND_BUY ? clrBlue : clrRed;
   create_trend_line("close_heiken_1", iTime(symbol, PERIOD_CURRENT, 0) - TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, TimeCurrent() + TIME_OF_ONE_H4_CANDLE, arrHeiken[1].close, clrHeiken, STYLE_DOT, 1, false, false);
   double amp_w1, amp_d1, amp_h4, amp_grid_L100;
   GetAmpAvgL15(symbol, amp_w1, amp_d1, amp_h4, amp_grid_L100);

   double import_price = (price*25500*(37.5/31.1035)/1000000);

   string cur_timeframe = get_current_timeframe_to_string();
   string str_comments = (string)AccountNumber() + " : " + AccountInfoString(ACCOUNT_NAME) + " " + get_vntime();// + "(" + cur_timeframe + ") ";
   str_comments += "    Closed(today): " + format_double_to_string(profit_today, 2) + "$"
                   + " (" + format_double_to_string(profit_today*25500/1000000, 2) + " tr)" + percent + "/" + (string) count_closed_today + "L";
   str_comments += "    Opening: " + (string)(int)PL + "$" + to_percent(PL)
                   + " (" + format_double_to_string(PL*25500/1000000, 2) + " tr)";

   str_comments += "    (Heiken "+get_current_timeframe_to_string()+"): " + (string) arrHeiken[0].trend_heiken + " (" + append1Zero(arrHeiken[0].count_heiken) + ")";
   str_comments += "    (Ma10 "+get_current_timeframe_to_string()+"): " + (string) arrHeiken[0].trend_by_ma10 + " (" + append1Zero(arrHeiken[0].count_ma10) + ")";
   str_comments += "    Init_Equity: " + format_double_to_string(INIT_EQUITY, 1) + "    Risk1%: " + format_double_to_string(risk_1_Percent_Account_Balance(), 1) + "$";

   if(is_same_symbol(Symbol(), "XAU"))
      str_comments += "    VND: " + format_double_to_string(import_price*1.09, 2) + "~" + format_double_to_string(import_price*1.119, 2) + " tr";

   str_comments += "    Amp(W1): " + format_double_to_string(amp_w1, Digits) + "$";
   str_comments += "    Amp(D1): " + format_double_to_string(amp_d1, Digits) + "$";

   if(Period() == PERIOD_W1)
     {
      double avg_candle_w1 = calc_average_candle_height(PERIOD_W1, symbol, 21);
      double avg_candle_d1 = calc_average_candle_height(PERIOD_D1, symbol, 50);

      string str_avg_21w = "    Avg21(W1): " + format_double_to_string(avg_candle_w1, Digits) + "    " + "(" + (string)(NormalizeDouble(avg_candle_w1/amp_w1, 2)*100) + "%)";
      string str_avg_50d = "    Avg50(D1): " + format_double_to_string(avg_candle_d1, Digits) + "    " + "(" + (string)(NormalizeDouble(avg_candle_d1/amp_d1, 2)*100) + "%)";

      str_comments += str_avg_21w + str_avg_50d;
      printf(symbol + "    " + str_avg_21w + "    " + str_avg_50d);
     }

   str_comments += "    Amp(H4): " + format_double_to_string(amp_h4, Digits) + "$";
   str_comments += "    CloseDay" + get_day_stop_trade(symbol, false);
   str_comments += "\n\n"; // + (string)get_vn_date()


   return str_comments;
  }
//+------------------------------------------------------------------+
