package bsc_scan_binance;

import java.util.Arrays;
import java.util.Calendar;
import java.util.Date;
import java.util.Hashtable;
import java.util.List;
import java.util.Objects;
import java.util.concurrent.TimeUnit;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.ApplicationContext;
import org.telegram.telegrambots.meta.TelegramBotsApi;
import org.telegram.telegrambots.meta.exceptions.TelegramApiException;
import org.telegram.telegrambots.updatesreceivers.DefaultBotSession;

import bsc_scan_binance.entity.CandidateCoin;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.service.CoinGeckoService;
import bsc_scan_binance.service.impl.WandaBot;
import bsc_scan_binance.utils.Utils;

@SpringBootApplication
public class BscScanBinanceApplication {
    public static int app_flag = Utils.const_app_flag_all_coin; // 1: msg_on; 2: msg_off; 3: web only; 4: all coin; 5:
                                                                // all_and_msg
    public static String callFormBinance = "";
    public static String TAKER_TOKENS = "_";
    public static int SLEEP_MINISECONDS = 6000;

    public static void main(String[] args) {
        try {
            System.out.println("Start "
                    + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime()) + " ---->");

            if (!Objects.equals(null, args) && args.length > 0) {
                if (Utils.isNotBlank(args[0])) {
                    app_flag = Utils.getIntValue(args[0]);
                }
            }
            if (app_flag == 0) {
                app_flag = Utils.const_app_flag_all_coin;
            }

            // Debug
            // app_flag = Utils.const_app_flag_msg_on;
            app_flag = Utils.const_app_flag_all_and_msg;
            // app_flag = Utils.const_app_flag_all_coin;

            System.out.println("app_flag:" + app_flag + " (1: msg_on; 2: msg_off; 3: web only; 4: all coin)");
            // --------------------Init--------------------
            ApplicationContext applicationContext = SpringApplication.run(BscScanBinanceApplication.class, args);
            CoinGeckoService gecko_service = applicationContext.getBean(CoinGeckoService.class);
            BinanceService binance_service = applicationContext.getBean(BinanceService.class);

            if (app_flag == Utils.const_app_flag_msg_on || app_flag == Utils.const_app_flag_all_and_msg) {
                WandaBot wandaBot = applicationContext.getBean(WandaBot.class);

                try {
                    TelegramBotsApi telegramBotsApi = new TelegramBotsApi(DefaultBotSession.class);
                    telegramBotsApi.registerBot(wandaBot);

                    binance_service.clearTrash();
                } catch (TelegramApiException e) {
                    e.printStackTrace();
                }
            }

            // --------------------Debug--------------------

            if (app_flag != Utils.const_app_flag_webonly) {
                List<CandidateCoin> list = gecko_service.getList(callFormBinance);
                Hashtable<String, String> keys_dict = new Hashtable<String, String>();

                int size = list.size();
                int idx = 0;
                int pre_blog15minute = -1;
                int cur_blog15minute = -1;

                Date start_time = Calendar.getInstance().getTime();
                while (idx < size) {
                    CandidateCoin coin = list.get(idx);

                    try {
                        cur_blog15minute = Utils.getCurrentMinute_Blog15minutes();
                        if (pre_blog15minute != cur_blog15minute) {
                            pre_blog15minute = cur_blog15minute;

                            if (Utils.isAllowSendMsgSetting()) {
                                //US30    US Wall Street 30 (USA 30, Dow Jones)
                                //US500   US 500 (S&P)
                                //HK50    Hong Kong 50
                                //UK100   UK 100
                                //FR40    France 40 (France)
                                //DXY     US Dollar Index
                                List<String> epics_index = Arrays.asList("GOLD", "OIL_CRUDE", "US30", "US500",
                                        "UK100", "HK50", "FR40");
                                for (String EPIC : epics_index) {
                                    binance_service.checkCapital(EPIC);
                                    wait(SLEEP_MINISECONDS);
                                }
                            }
                            //------------------------------------------

                            System.out.println(Utils.getTimeHHmm() + "BTC bitcoin");
                            binance_service.getChartWD("bitcoin", "BTC");
                            wait(SLEEP_MINISECONDS);

                            System.out.println(Utils.getTimeHHmm() + "ETH ethereum");
                            binance_service.getChartWD("ethereum", "ETH");
                            wait(SLEEP_MINISECONDS);

                            System.out.println(Utils.getTimeHHmm() + "BNB binancecoin");
                            binance_service.getChartWD("binancecoin", "BNB");
                            wait(SLEEP_MINISECONDS);

                            //------------------------------------------
                            if (Utils.isAllowSendMsgSetting()) {
                                //EURUSD  Euro / US Dollar
                                //USDJPY  US Dollar / Japanese Yen
                                //GBPUSD  British Pound / US Dollar
                                //AUDUSD  Australian Dollar / US Dollar
                                //GBPJPY  British Pound / Japanese Yen
                                //USDCAD  US Dollar / Canadian dollar
                                //EURJPY  Euro / Japanese Yen
                                //USDCHF  US Dollar / Swiss Franc
                                //AUDJPY  Australian Dollar / Japanese Yen
                                //EURGBP  Euro / British Pound
                                //EURAUD  Euro / Australian Dollar
                                //CADJPY  Canadian dollar / Japanese Yen
                                //GBPAUD  British Pound / Australian Dollar
                                //NZDUSD  New Zealand Dollar / US Dollar
                                //EURCAD  Euro / Canadian dollar
                                //AUDCAD  Australian Dollar / Canadian Dollar
                                //GBPCAD  British Pound / Canadian dollar
                                //EURCHF  Euro / Swiss Franc
                                //AUDNZD  Australian Dollar / New Zealand Dollar
                                //CHFJPY  Swiss Franc / Japanese Yen
                                List<String> epics_forex = Arrays.asList(
                                        "EURCAD", "AUDCAD", "GBPCAD", "CADJPY",
                                        "USDCAD", "USDJPY", "USDCHF",
                                        "AUDUSD", "AUDJPY", "AUDNZD",
                                        "GBPUSD", "GBPJPY", "GBPAUD",
                                        "EURUSD", "EURJPY", "EURGBP", "EURAUD", "EURCHF",
                                        "NZDUSD", "CHFJPY");

                                for (String EPIC : epics_forex) {
                                    binance_service.checkCapital(EPIC);
                                    wait(SLEEP_MINISECONDS);
                                }
                            }
                        }

                        if (!"_BTC_ETH_BNB_".contains("_" + coin.getSymbol() + "_")) {
                            if (BscScanBinanceApplication.TAKER_TOKENS.contains("_" + coin.getSymbol() + "_")) {
                                // System.out.println("Check taker (m15)" + coin.getSymbol());
                                // binance_service.sendMsgChart15m(coin.getGeckoid(), coin.getSymbol());
                            }
                        }

                        // ----------------------------------------------------------

                        String key = Utils.getStringValue(coin.getGeckoid()) + "_";
                        key += Utils.getStringValue(coin.getSymbol()) + "_";
                        key += Utils.getCurrentYyyyMmDd_HH();
                        boolean reload = false;
                        if (keys_dict.containsKey(key)) {
                            if (!Objects.equals(key, keys_dict.get(key))) {
                                keys_dict.put(key, key);

                                reload = true;
                            }
                        } else {
                            keys_dict.put(key, key);
                            reload = true;
                        }
                        if (reload) {
                            String msg = "(" + (idx + 1) + "/" + size + ")" + Utils.getTimeHHmm();
                            msg += coin.getSymbol() + " " + coin.getGeckoid();
                            System.out.println(msg);

                            binance_service.getChartWD(coin.getGeckoid(), coin.getSymbol());

                            try {
                                gecko_service.loadData(coin.getGeckoid());
                            } catch (Exception e) {
                                System.out.println("dkd error gecko_service.LoadData:[" + coin.getGeckoid() + "]"
                                        + e.getMessage());
                            }

                        }

                        wait(SLEEP_MINISECONDS);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }

                    if (Objects.equals(idx, size - 1)) {
                        Date curr_time = Calendar.getInstance().getTime();
                        long diff = curr_time.getTime() - start_time.getTime();
                        start_time = Calendar.getInstance().getTime();

                        System.out.println("reload: " + Utils.getMmDD_TimeHHmm() + ", spend:"
                                + TimeUnit.MILLISECONDS.toMinutes(diff) + " Minutes.");
                        idx = 0;
                    } else {
                        idx += 1;
                    }
                }

                System.out.println("End BscScanBinanceApplication "
                        + Utils.convertDateToString("yyyy-MM-dd HH:mm:ss", Calendar.getInstance().getTime())
                        + " <----");
            }
        } catch (

        Exception e) {
            System.out.println(e.getMessage());
        }

    }

    public static void wait(int sleep_ms) {
        try {
            java.lang.Thread.sleep(sleep_ms);
        } catch (InterruptedException ex) {
            java.lang.Thread.currentThread().interrupt();
        }
    }

}
