package bsc_scan_binance.service.impl;

import java.math.BigDecimal;
import java.math.BigInteger;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collection;
import java.util.Hashtable;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Objects;

import javax.persistence.EntityManager;
import javax.persistence.PersistenceContext;
import javax.persistence.Query;
import javax.transaction.Transactional;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.select.Elements;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;
import org.springframework.web.client.RestTemplate;

import bsc_scan_binance.BscScanBinanceApplication;
import bsc_scan_binance.entity.BinanceFutures;
import bsc_scan_binance.entity.BinanceVolumeDateTime;
import bsc_scan_binance.entity.BinanceVolumeDateTimeKey;
import bsc_scan_binance.entity.BinanceVolumnDay;
import bsc_scan_binance.entity.BinanceVolumnDayKey;
import bsc_scan_binance.entity.BinanceVolumnWeek;
import bsc_scan_binance.entity.BinanceVolumnWeekKey;
import bsc_scan_binance.entity.BitcoinBalancesOnExchanges;
import bsc_scan_binance.entity.BitcoinBalancesOnExchangesKey;
import bsc_scan_binance.entity.BollArea;
import bsc_scan_binance.entity.BtcFutures;
import bsc_scan_binance.entity.BtcVolumeDay;
import bsc_scan_binance.entity.DepthAsks;
import bsc_scan_binance.entity.DepthBids;
import bsc_scan_binance.entity.GeckoVolumeUpPre4h;
import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.entity.PriorityCoin;
import bsc_scan_binance.repository.BinanceFuturesRepository;
import bsc_scan_binance.repository.BinanceVolumeDateTimeRepository;
import bsc_scan_binance.repository.BinanceVolumnDayRepository;
import bsc_scan_binance.repository.BinanceVolumnWeekRepository;
import bsc_scan_binance.repository.BitcoinBalancesOnExchangesRepository;
import bsc_scan_binance.repository.BollAreaRepository;
import bsc_scan_binance.repository.BtcFuturesRepository;
import bsc_scan_binance.repository.BtcVolumeDayRepository;
import bsc_scan_binance.repository.DepthAsksRepository;
import bsc_scan_binance.repository.DepthBidsRepository;
import bsc_scan_binance.repository.GeckoVolumeUpPre4hRepository;
import bsc_scan_binance.repository.OrdersRepository;
import bsc_scan_binance.repository.PriorityCoinRepository;
import bsc_scan_binance.response.BitcoinBalancesOnExchangesResponse;
import bsc_scan_binance.response.BollAreaResponse;
import bsc_scan_binance.response.BtcFuturesResponse;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.CandidateTokenResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;
import bsc_scan_binance.response.GeckoVolumeUpPre4hResponse;
import bsc_scan_binance.response.OrdersProfitResponse;
import bsc_scan_binance.service.BinanceService;
import bsc_scan_binance.utils.Utils;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;

@Service
@Slf4j
@RequiredArgsConstructor
public class BinanceServiceImpl implements BinanceService {
    @PersistenceContext
    private final EntityManager entityManager;

    @Autowired
    private BinanceVolumnDayRepository binanceVolumnDayRepository;

    @Autowired
    private BinanceVolumeDateTimeRepository binanceVolumeDateTimeRepository;

    @Autowired
    private BinanceVolumnWeekRepository binanceVolumnWeekRepository;

    @Autowired
    private PriorityCoinRepository priorityCoinRepository;

    @Autowired
    private BtcVolumeDayRepository btcVolumeDayRepository;

    @Autowired
    private GeckoVolumeUpPre4hRepository geckoVolumeUpPre4hRepository;

    @Autowired
    private BollAreaRepository bollAreaRepository;

    @Autowired
    private OrdersRepository ordersRepository;

    @Autowired
    private BinanceFuturesRepository binanceFuturesRepository;

    @Autowired
    private DepthBidsRepository depthBidsRepository;

    @Autowired
    private DepthAsksRepository depthAsksRepository;

    @Autowired
    private BtcFuturesRepository btcFuturesRepository;

    @Autowired
    private BitcoinBalancesOnExchangesRepository bitcoinBalancesOnExchangesRepository;

    private static final String SYMBOL_BTC = "BTC";

    private static final String TIME_15m = "15m";
    // private static final int LIMIT_DATA_1m = 60;

    private static final String TIME_1h = "1h";
    private static final String TIME_4h = "4h";
    private static final String TIME_1d = "1d";

    private static final int LIMIT_DATA_15m = 48;
    private static final int LIMIT_DATA_1h = 48;
    private static final int LIMIT_DATA_4h = 60;

    private int pre_monitorBitcoinBalancesOnExchanges_HH = 0;
    private String monitorBitcoinBalancesOnExchanges_temp = "";

    private String pre_monitorBtcPrice_mm = "";
    List<String> monitorBtcPrice_results = new ArrayList<String>();

    private String pre_time_of_btc = "";
    private String pre_time_of_btc_msg_1h = "";
    private String pre_time_of_btc_for_long_short = "";
    private String pre_time_of_btc_kill_long_short = "";
    private String pre_time_of_saved_data_4h = "";
    private String pre_funding_rate_low = "";
    private String pre_funding_rate_high = "";

    List<DepthResponse> list_bids_ok = new ArrayList<DepthResponse>();
    List<DepthResponse> list_asks_ok = new ArrayList<DepthResponse>();

    private String pre_yyyyMMddHH = "";
    private String sp500 = "";
    private Hashtable<String, String> msg_vol_up_dict = new Hashtable<String, String>();

    @Override
    @Transactional
    public List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume) {
        try {
            log.info("Start getList ---->");
            String sql = " select                                                                                 \n"
                    + "   can.gecko_id,                                                                           \n"
                    + "   can.symbol,                                                                             \n"
                    + "   concat (can.name, (case when (select gecko_id from binance_futures where gecko_id=can.gecko_id) is not null then ' (Futures)' else '' end)) as name,  \n"

                    + "    boll.low_price   as low_price_24h,                                                     \n"
                    + "    boll.hight_price as hight_price_24h,                                                   \n"
                    + "    boll.price_can_buy,                                                                    \n"
                    + "    boll.price_can_sell,                                                                   \n"
                    + "    boll.is_bottom_area,                                                                   \n"
                    + "    boll.is_top_area,                                                                      \n"
                    + "    0 as profit,                                                                           \n"
                    + "                                                                                           \n"
                    + "    (select count(w.gecko_id) from binance_volumn_week w where w.ema > 0 and w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval  '6 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')) as count_up, "
                    + "    concat('Pump:', coalesce((select string_agg(his1.hh, '<') from (select * from binance_pumping_history his1 where his1.gecko_id = can.gecko_id and his1.symbol = can.symbol and his1.total_pump > 3 order by his1.total_pump desc limit 5) as his1), ''), 'h', ' ', \n"
                    + "           'Dump:', coalesce((select string_agg(his2.hh, '<') from (select * from binance_pumping_history his2 where his2.gecko_id = can.gecko_id and his2.symbol = can.symbol and his2.total_dump > 3 order by his2.total_dump desc limit 5) as his2), ''), 'h' \n"
                    + "          ) as pumping_history,                                                            \n"

                    + "   ROUND(can.volumn_div_marketcap * 100, 0) volumn_div_marketcap,                          \n"
                    + "                                                                                           \n"
                    + "   ROUND((cur.total_volume / COALESCE ((SELECT (case when pre.total_volume = 0.0 then 1000000000 else pre.total_volume end) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 1000000000) * 100 - 100), 0) pre_4h_total_volume_up, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                  as vol_now,      \n"
                    + "                                                                                           \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW()), 'HH24')), 0)                     , 5) as price_now,    \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0), 5) as price_pre_1h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0), 5) as price_pre_2h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0), 5) as price_pre_3h, \n"
                    + "   ROUND(coalesce((SELECT pre.price_at_binance FROM public.binance_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0), 5) as price_pre_4h, \n"
                    + "                                                                                           \n"
                    + "   can.market_cap ,                                                                        \n"
                    + "   cur.price_at_binance            as current_price,                                       \n"
                    + "   can.total_volume                as gecko_total_volume,                                  \n"
                    + "   false as top10_vol_up,                                                                  \n"
                    + "   0 as vol_up_rate,                                                                       \n"
                    + "                                                                                           \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '1 hours'), 'HH24')), 0) as gec_vol_pre_1h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '2 hours'), 'HH24')), 0) as gec_vol_pre_2h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '3 hours'), 'HH24')), 0) as gec_vol_pre_3h, \n"
                    + "   coalesce((SELECT ROUND(pre.total_volume/1000000, 1) FROM public.gecko_volumn_day pre WHERE cur.gecko_id = pre.gecko_id AND cur.symbol = pre.symbol AND hh=TO_CHAR((NOW() - interval '4 hours'), 'HH24')), 0) as gec_vol_pre_4h, \n"
                    + "                                                                                           \n"
                    + "   can.price_change_percentage_24h,                                                        \n"
                    + "   can.price_change_percentage_7d,                                                         \n"
                    + "   can.price_change_percentage_14d,                                                        \n"
                    + "   can.price_change_percentage_30d,                                                        \n"
                    + "                                                                                           \n"
                    + "   can.category,                                                                           \n"
                    + "   can.trend,                                                                              \n"
                    + "   can.total_supply,                                                                       \n"
                    + "   can.max_supply,                                                                         \n"
                    + "   can.circulating_supply,                                                                 \n"
                    + "   can.binance_trade,                                                                      \n"
                    + "   can.coin_gecko_link,                                                                    \n"
                    + "   can.backer,                                                                             \n"
                    + "   can.note,                                                                               \n"
                    + "                                                                                           \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW(), 'yyyyMMdd'))                     as today,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '1 days', 'yyyyMMdd')) as day_0,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '2 days', 'yyyyMMdd')) as day_1,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '3 days', 'yyyyMMdd')) as day_2,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '4 days', 'yyyyMMdd')) as day_3,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '5 days', 'yyyyMMdd')) as day_4,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '6 days', 'yyyyMMdd')) as day_5,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '7 days', 'yyyyMMdd')) as day_6,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '8 days', 'yyyyMMdd')) as day_7,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '9 days', 'yyyyMMdd')) as day_8,  \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '10 days', 'yyyyMMdd')) as day_9, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '11 days', 'yyyyMMdd')) as day_10, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '12 days', 'yyyyMMdd')) as day_11, \n"
                    + "   (select concat(w.total_volume, '~', ROUND(w.avg_price, 4), '~', ROUND(w.min_price, 4), '~', ROUND(w.max_price, 4), '~', ROUND(w.ema, 5), '~', coalesce(price_change_24h, 0), '~', ROUND(gecko_volume, 1) ) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '13 days', 'yyyyMMdd')) as day_12, \n"
                    + "   can.priority,                                                                           \n"

                    + "   macd.ema07d,                                                                            \n"
                    + "   macd.ema14d,                                                                            \n"
                    + "   macd.ema21d,                                                                            \n"
                    + "   macd.ema28d,                                                                            \n"
                    + "   macd.min60d,                                                                            \n"
                    + "   macd.max28d,                                                                            \n"
                    + "   macd.min14d,                                                                            \n"
                    + "   macd.min28d,                                                                            \n" // min
                    + "   false AS uptrend,                                                                       \n"
                    + "   vol.vol0d,                                                                              \n"
                    + "   vol.vol1d,                                                                              \n"
                    + "   vol.vol7d                                                                               \n"
                    + "   , gecko_week.vol_gecko_increate                                                         \n"
                    + "   , '' opportunity                                                                        \n"
                    + "                                                                                           \n"
                    + "   , concat('1h: ', rate1h, '%, 2h: ', rate2h, '%, 4h: ', rate4h, '%, 1d0h: ', rate1d0h, '%, 1d4h: ', rate1d4h, '%') as binance_vol_rate \n"
                    + "   , rate1h                                                                                \n"
                    + "   , rate2h                                                                                \n"
                    + "   , rate4h                                                                                \n"
                    + "   , rate1d0h                                                                              \n"
                    + "   , rate1d4h                                                                              \n"
                    + "   , cur.rsi                                                                               \n"
                    + "   , (select futures_msg from binance_futures where gecko_id = can.gecko_id)    as futures      \n"
                    + "   , (select futures_css from binance_futures where gecko_id = can.gecko_id)    as futures_css  \n"
                    + "                                                                                           \n"
                    + " from                                                                                      \n"
                    + "   candidate_coin can,                                                                     \n"
                    + "   binance_volumn_day cur,                                                                 \n"
                    + "   view_binance_volume_rate vbvr,                                                          \n"
                    + " (                                                                                         \n"
                    + "    select                                                                                 \n"
                    + "       xyz.gecko_id,                                                                       \n"
                    + "       xyz.symbol,                                                                         \n"
                    + "       COALESCE(price_today   - price_pre_07d*1.05, -99) as ema07d,                        \n"
                    + "       COALESCE(price_pre_07d - price_pre_14d, -99) as ema14d,                             \n"
                    + "       COALESCE(price_pre_14d - price_pre_21d, -99) as ema21d,                             \n"
                    + "       COALESCE(price_pre_21d - price_pre_28d, -99) as ema28d,                             \n"
                    + "       COALESCE(min60d, -99) min60d,                                                       \n"
                    + "       COALESCE(max28d, -99) max28d,                                                       \n"
                    + "       COALESCE(min14d, -99) min14d,                                                       \n"
                    + "       COALESCE(min28d, -99) min28d                                                        \n"
                    + "    from                                                                                   \n"
                    + "      (                                                                                    \n"
                    + "          select                                                                           \n"
                    + "              can.gecko_id,                                                                \n"
                    + "              can.symbol,                                                                  \n"
                    + "              can.name,                                                                    \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW(), 'yyyyMMdd')) as price_today,      \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval  '6 days', 'yyyyMMdd')) as price_pre_07d,  \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '13 days', 'yyyyMMdd')) as price_pre_14d,  \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '20 days', 'yyyyMMdd')) as price_pre_21d,  \n"
                    + "             (select COALESCE(w.avg_price, 0) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd = TO_CHAR(NOW() - interval '28 days', 'yyyyMMdd')) as price_pre_28d,  \n"
                    + "             ROUND((select MIN(COALESCE(w.avg_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '60 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min60d, \n" // min60d
                    + "             ROUND((select MIN(COALESCE(w.avg_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '30 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as max28d, \n" // max28d
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '14 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min14d, \n" // min14d
                    + "             ROUND((select MIN(COALESCE(w.min_price, 1000000)) from binance_volumn_week w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and yyyymmdd between TO_CHAR(NOW() - interval '30 days', 'yyyyMMdd') and TO_CHAR(NOW(), 'yyyyMMdd')), 5) as min28d  \n" // min28d
                    + "                                                                                           \n"
                    + "          from                                                                             \n"
                    + "              candidate_coin can                                                           \n"
                    + "    ) xyz                                                                                  \n"
                    + " ) macd                                                                                    \n"
                    + " , ("
                    + "     select                                                                                \n"
                    + "        gecko_id,                                                                          \n"
                    + "        symbol,                                                                            \n"
                    + "        ROUND((COALESCE(volume_today  , 0))/1000000, 1) as vol0d, \n"
                    + "        ROUND((COALESCE(volume_pre_01d, 0))/1000000, 1) as vol1d, \n"
                    + "        ROUND((COALESCE(volume_pre_07d, 0))/1000000, 1) as vol7d  \n"
                    + "     from                                                                                  \n"
                    + "       (                                                                                   \n"
                    + "           select                                                                          \n"
                    + "               can.gecko_id,                                                               \n"
                    + "               can.symbol,                                                                 \n"
                    + "               can.name,                                                                   \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and dd = TO_CHAR(NOW(), 'dd'))                      as volume_today,  \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and dd = TO_CHAR(NOW() - interval  '1 days', 'dd')) as volume_pre_01d, \n"
                    + "              (select COALESCE(w.total_volume, 0) from gecko_volume_month w where w.gecko_id = can.gecko_id and w.symbol = can.symbol and dd = TO_CHAR(NOW() - interval  '6 days', 'dd')) as volume_pre_07d  \n"
                    + "           from                                                                            \n"
                    + "               candidate_coin can                                                          \n"
                    + "     ) tmp                                                                                 \n"
                    + ") vol                                                                                      \n"
                    + ", " + Utils.sql_boll_2_body
                    + ", (                                                                                        \n"
                    + "     SELECT                                                                                \n"
                    + "           gecko_id                                                                        \n"
                    + "         , symbol                                                                          \n"
                    + "         , vol_today                                                                       \n"
                    + "         , vol_avg_07d                                                                     \n"
                    + "         , (case when vol_today > vol_avg_07d then true else false end) as vol_up          \n"
                    + "         , ROUND((case when vol_avg_07d > 0 and vol_today/vol_avg_07d > 1.5 then vol_today/vol_avg_07d else 0 end), 1) as vol_gecko_increate \n"
                    + "     from                                                                                  \n"
                    + "     (                                                                                     \n"
                    + "         SELECT                                                                            \n"
                    + "             gecko_id                                                                      \n"
                    + "             , symbol                                                                      \n"
                    + "             , (select ROUND(COALESCE(w.total_volume, 0), 0) from gecko_volume_month w where w.gecko_id = mon.gecko_id and w.symbol = mon.symbol and w.dd = TO_CHAR(NOW(), 'dd')) as vol_today \n"
                    + "             , (select ROUND(AVG(COALESCE(w.total_volume, 0)), 0) from gecko_volume_month w where w.gecko_id = mon.gecko_id and w.symbol = mon.symbol  \n"
                    + "              and w.dd in (  TO_CHAR(NOW() - interval  '6 days', 'dd')                     \n"
                    + "                           , TO_CHAR(NOW() - interval  '5 days', 'dd')                     \n"
                    + "                           , TO_CHAR(NOW() - interval  '4 days', 'dd')                     \n"
                    + "                           , TO_CHAR(NOW() - interval  '3 days', 'dd')                     \n"
                    + "                           , TO_CHAR(NOW() - interval  '2 days', 'dd')                     \n"
                    + "                           , TO_CHAR(NOW() - interval  '1 days', 'dd')                     \n"
                    + "                           , TO_CHAR(NOW(), 'dd')                                          \n"
                    + "                           )                                                               \n"
                    + "             ) as vol_avg_07d                                                              \n"
                    + "         FROM public.gecko_volume_month mon                                                \n"
                    + "         where mon.dd = TO_CHAR(NOW(), 'dd')                                               \n"
                    + "     )tmp                                                                                  \n"
                    + " ) gecko_week                                                                              \n"
                    + "                                                                                           \n"
                    + " WHERE                                                                                     \n"
                    + "       cur.hh = (case when EXTRACT(MINUTE FROM NOW()) < 3 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                    + "   AND can.gecko_id = cur.gecko_id                                                         \n"
                    + "   AND can.gecko_id = vbvr.gecko_id                                                        \n"
                    + "   AND can.symbol = cur.symbol                                                             \n"
                    + "   AND can.gecko_id = macd.gecko_id                                                        \n"
                    + "   AND can.gecko_id = boll.gecko_id                                                        \n"
                    + "   AND can.gecko_id = vol.gecko_id                                                         \n"
                    + "   AND can.gecko_id = gecko_week.gecko_id                                                  \n"
                    + ((BscScanBinanceApplication.app_flag != Utils.const_app_flag_all_coin)
                            ? "   AND can.gecko_id IN (SELECT gecko_id FROM binance_futures) \n"
                            : "")
                    + " order by                                                                                  \n"
                    + "     coalesce(can.priority, 3) ASC                                                         \n"
                    + "   , vbvr.rate1d0h DESC, vbvr.rate4h DESC                                                  \n";

            Query query = entityManager.createNativeQuery(sql, "CandidateTokenResponse");

            @SuppressWarnings("unchecked")
            List<CandidateTokenResponse> results = query.getResultList();

            List<CandidateTokenCssResponse> list = new ArrayList<CandidateTokenCssResponse>();

            ModelMapper mapper = new ModelMapper();
            Integer index = 1;
            String sql_update_ema = "";
            Boolean btc_is_good_price = false;
            Boolean this_token_is_good_price = false;
            List<PriorityCoin> listPriorityCoin = priorityCoinRepository.findAll();

            // monitorTokenSales(results);
            for (CandidateTokenResponse dto : results) {

                PriorityCoin priorityCoin = listPriorityCoin.stream()
                        .filter(item -> Objects.equals(item.getGeckoid(), dto.getGecko_id())).findFirst()
                        .orElse(new PriorityCoin());

                priorityCoin.setGeckoid(dto.getGecko_id());

                CandidateTokenCssResponse css = new CandidateTokenCssResponse();
                mapper.map(dto, css);

                BigDecimal price_now = Utils.getBigDecimal(dto.getPrice_now());
                BigDecimal mid_price = Utils.getMidPrice(dto.getPrice_can_buy(), dto.getPrice_can_sell());
                BigDecimal market_cap = Utils.getBigDecimal(dto.getMarket_cap());
                BigDecimal gecko_total_volume = Utils.getBigDecimal(dto.getGecko_total_volume());

                if ((market_cap.compareTo(BigDecimal.valueOf(36000001)) < 0)
                        && (market_cap.compareTo(BigDecimal.valueOf(1000000)) > 0)) {
                    css.setMarket_cap_css("highlight");
                }

                BigDecimal volumn_binance_div_marketcap = BigDecimal.ZERO;
                String volumn_binance_div_marketcap_str = "";
                if (market_cap.compareTo(BigDecimal.ZERO) > 0) {
                    volumn_binance_div_marketcap = Utils.getBigDecimal(dto.getVol_now()).divide(
                            market_cap.divide(BigDecimal.valueOf(100000000), 5, RoundingMode.CEILING), 1,
                            RoundingMode.CEILING);
                } else if (gecko_total_volume.compareTo(BigDecimal.ZERO) > 0) {
                    volumn_binance_div_marketcap = Utils.getBigDecimal(dto.getVol_now()).divide(
                            gecko_total_volume.divide(BigDecimal.valueOf(100000000), 5, RoundingMode.CEILING), 1,
                            RoundingMode.CEILING);
                }

                if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(30)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    css.setVolumn_binance_div_marketcap_css("font-weight-bold");

                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(20)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();
                    css.setVolumn_binance_div_marketcap_css("text-primary");

                } else if (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) > 0) {
                    volumn_binance_div_marketcap_str = "B:" + volumn_binance_div_marketcap.toString();

                } else {
                    volumn_binance_div_marketcap_str = volumn_binance_div_marketcap.toString();
                }

                css.setVolumn_binance_div_marketcap(volumn_binance_div_marketcap_str);
                css.setPumping_history(dto.getPumping_history().replace("Pump:h", "").replace("Dump:h", ""));

                css.setBinance_trade("https://www.binance.com/en/futures/" + dto.getSymbol().toUpperCase() + "USDT");
                // Price
                String pre_price_history = Utils.removeLastZero(dto.getPrice_now()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_1h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_2h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_3h()) + "←"
                        + Utils.removeLastZero(dto.getPrice_pre_4h());
                if (pre_price_history.length() > 28) {
                    pre_price_history = Utils.removeLastZero(dto.getPrice_now()) + "←"
                            + Utils.removeLastZero(dto.getPrice_pre_1h()) + "←"
                            + Utils.removeLastZero(dto.getPrice_pre_2h());
                }
                css.setPre_price_history(pre_price_history);

                if (getValue(css.getVolumn_div_marketcap()) > Long.valueOf(100)) {
                    css.setVolumn_div_marketcap_css("text-primary");
                } else if (getValue(css.getVolumn_div_marketcap()) < Long.valueOf(20)) {
                    css.setVolumn_div_marketcap_css("font-weight-bold text-danger");
                }

                css.setCurrent_price(Utils.removeLastZero(dto.getCurrent_price()));
                css.setPrice_change_24h_css(Utils.getTextCss(css.getPrice_change_percentage_24h()));
                css.setPrice_change_07d_css(Utils.getTextCss(css.getPrice_change_percentage_7d()));
                css.setPrice_change_14d_css(Utils.getTextCss(css.getPrice_change_percentage_14d()));
                css.setPrice_change_30d_css(Utils.getTextCss(css.getPrice_change_percentage_30d()));

                String gecko_volumn_history = dto.getGec_vol_pre_1h() + "←" + dto.getGec_vol_pre_2h() + " ←"
                        + dto.getGec_vol_pre_3h() + "←" + dto.getGec_vol_pre_4h() + "M";

                if (gecko_volumn_history.length() > 20) {
                    gecko_volumn_history = dto.getGec_vol_pre_1h() + "←" + dto.getGec_vol_pre_2h() + "M";
                }

                css.setGecko_volumn_history(gecko_volumn_history);

                List<String> volList = new ArrayList<String>();
                List<String> avgPriceList = new ArrayList<String>();
                List<String> lowPriceList = new ArrayList<String>();
                List<String> hightPriceList = new ArrayList<String>();

                List<String> temp = splitVolAndPrice(css.getToday());
                css.setToday_vol(temp.get(0));
                String mid_price_percent = Utils.toPercent(mid_price, price_now);
                css.setToday_price(Utils.removeLastZero(mid_price.toString()) + "$ (" + mid_price_percent + "%)");

                if (mid_price_percent.contains("-")) {
                    css.setToday_price_css("text-danger");
                } else {
                    css.setToday_price_css("text-primary");
                }

                css.setToday_gecko_vol(
                        temp.get(6) + " (Vol4h: " + Utils.getBigDecimal(dto.getVol_up_rate()).toString() + ")");
                String today_ema = "";
                if (temp.get(4).contains("-")) {
                    today_ema = "(" + (7 - Utils.getIntValue(dto.getCount_up())) + "Down, " + dto.getCount_up()
                            + "Up )";
                } else {
                    today_ema = "(" + dto.getCount_up() + "Up" + ", " + (7 - Utils.getIntValue(dto.getCount_up()))
                            + "Down) ";

                }
                today_ema += temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)";
                css.setToday_ema(today_ema);

                volList.add("");
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                BigDecimal lowest_price_today = Utils.getBigDecimalValue(temp.get(2));
                BigDecimal highest_price_today = Utils.getBigDecimalValue(temp.get(3));
                BigDecimal taget_percent_lost_today = Utils
                        .getBigDecimalValue(Utils.toPercent(lowest_price_today, price_now, 1));
                BigDecimal taget_percent_profit_today = Utils
                        .getBigDecimalValue(Utils.toPercent(highest_price_today, price_now, 1));

                BigDecimal vol_today = Utils.getBigDecimal(temp.get(0).replace(",", ""));

                temp = splitVolAndPrice(css.getDay_0());
                css.setDay_0_vol(temp.get(0));
                css.setDay_0_price(temp.get(1));
                css.setDay_0_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_0_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));
                BigDecimal vol_yesterday = Utils.getBigDecimal(temp.get(0).replace(",", ""));

                if (vol_yesterday.compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal vol_up = vol_today.divide(vol_yesterday, 1, RoundingMode.CEILING);
                    if (vol_up.compareTo(BigDecimal.valueOf(2)) > 0) {
                        css.setStar("BUp: " + String.valueOf(vol_up));
                        css.setStar_css("text-primary");
                    }
                }
                temp = splitVolAndPrice(css.getDay_1());
                css.setDay_1_vol(temp.get(0));
                css.setDay_1_price(temp.get(1));
                css.setDay_1_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_1_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_2());
                css.setDay_2_vol(temp.get(0));
                css.setDay_2_price(temp.get(1));
                css.setDay_2_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_2_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_3());
                css.setDay_3_vol(temp.get(0));
                css.setDay_3_price(temp.get(1));
                css.setDay_3_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_3_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_4());
                css.setDay_4_vol(temp.get(0));
                css.setDay_4_price(temp.get(1));
                css.setDay_4_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_4_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_5());
                css.setDay_5_vol(temp.get(0));
                css.setDay_5_price(temp.get(1));
                css.setDay_5_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_5_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_6());
                css.setDay_6_vol(temp.get(0));
                css.setDay_6_price(temp.get(1));
                css.setDay_6_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_6_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_7());
                css.setDay_7_vol(temp.get(0));
                css.setDay_7_price(temp.get(1));
                css.setDay_7_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_7_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_8());
                css.setDay_8_vol(temp.get(0));
                css.setDay_8_price(temp.get(1));
                css.setDay_8_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_8_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_9());
                css.setDay_9_vol(temp.get(0));
                css.setDay_9_price(temp.get(1));
                css.setDay_9_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_9_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_10());
                css.setDay_10_vol(temp.get(0));
                css.setDay_10_price(temp.get(1));
                css.setDay_10_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_10_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_11());
                css.setDay_11_vol(temp.get(0));
                css.setDay_11_price(temp.get(1));
                css.setDay_11_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_11_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                temp = splitVolAndPrice(css.getDay_12());
                css.setDay_12_vol(temp.get(0));
                css.setDay_12_price(temp.get(1));
                css.setDay_12_ema(temp.get(4) + " (" + temp.get(5).replace("-", "↓") + "%)");
                css.setDay_12_gecko_vol(temp.get(6));

                volList.add(temp.get(0));
                avgPriceList.add(temp.get(1));
                lowPriceList.add(temp.get(2));
                hightPriceList.add(temp.get(3));

                int idx_vol_max = getIndexMax(volList);
                int idx_price_max = getIndexMax(avgPriceList);
                int idx_vol_min = getIndexMin(volList);
                int idx_price_min = getIndexMin(avgPriceList);

                setEmaCss(css);

                String str_down = "";
                if (Utils.getBigDecimal(avgPriceList.get(idx_price_min)).compareTo(BigDecimal.ZERO) > 0) {
                    BigDecimal down = Utils.getBigDecimal(avgPriceList.get(idx_price_max))
                            .divide(Utils.getBigDecimal(avgPriceList.get(idx_price_min)), 2, RoundingMode.CEILING)
                            .multiply(BigDecimal.valueOf(100));
                    str_down = "(" + down.subtract(BigDecimal.valueOf(100)).toString().replace(".00", "") + "%)";
                }
                setVolumnDayCss(css, idx_vol_max, "text-primary"); // Max Volumn
                setPriceDayCss(css, idx_price_max, "text-primary", ""); // Max Price
                setVolumnDayCss(css, idx_vol_min, "text-danger"); // Min Volumn
                setPriceDayCss(css, idx_price_min, "text-danger", str_down); // Min Price

                BigDecimal min_add_5_percent = Utils.getBigDecimal(avgPriceList.get(idx_price_min));
                min_add_5_percent = min_add_5_percent.multiply(BigDecimal.valueOf(Double.valueOf(1.05)));

                BigDecimal max_subtract_5_percent = Utils.getBigDecimal(avgPriceList.get(idx_price_max));
                max_subtract_5_percent.multiply(BigDecimal.valueOf(Double.valueOf(0.95)));

                // --------------AVG PRICE---------------
                BigDecimal avg_price = BigDecimal.ZERO;
                BigDecimal total_price = BigDecimal.ZERO;
                for (String price : avgPriceList) {
                    if (!Objects.equals("", price)) {
                        total_price = total_price.add(Utils.getBigDecimalValue(price));
                    }
                }

                avg_price = total_price.divide(BigDecimal.valueOf(avgPriceList.size()), 5, RoundingMode.CEILING);

                price_now = Utils.getBigDecimalValue(css.getCurrent_price());

                {
                    String low_to_hight_price = "L:" + Utils.removeLastZero(lowest_price_today.toString()) + "("
                            + taget_percent_lost_today + "%)_H:" + Utils.removeLastZero(highest_price_today.toString())
                            + "(" + taget_percent_profit_today.toString().replace(".0", "") + "%)";

                    css.setLow_to_hight_price(low_to_hight_price);

                    css.setLow_price(low_to_hight_price.substring(0, low_to_hight_price.indexOf("_")));
                    css.setHight_price(low_to_hight_price.substring(low_to_hight_price.indexOf("_") + 1));

                    if (Utils.isGoodPriceLong(price_now, lowest_price_today, highest_price_today)) {

                        css.setLow_price_css("text-primary");
                    }
                }

                this_token_is_good_price = Utils.isGoodPriceLong(price_now, lowest_price_today, highest_price_today);

                priorityCoin.setCurrent_price(price_now);

                if ((price_now.compareTo(BigDecimal.ZERO) > 0) && (avg_price.compareTo(BigDecimal.ZERO) > 0)) {

                    BigDecimal percent = Utils.getBigDecimalValue(Utils.toPercent(avg_price, price_now, 1));
                    css.setAvg_price(Utils.removeLastZero(avg_price.toString()));
                    css.setAvg_percent(percent.toString() + "%");

                } else {
                    css.setAvg_price("0.0");
                }

                {
                    if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(30)) > 0) {
                        css.setRate1d0h_css("text-primary font-weight-bold");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(0)) > 0) {
                        css.setRate1d0h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(-30)) < 0) {
                        css.setRate1d0h_css("text-danger font-weight-bold");
                    } else if (Utils.getBigDecimal(dto.getRate1d0h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate1d0h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate1h()).compareTo(BigDecimal.valueOf(40)) > 0) {
                        css.setRate1h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate1h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate1h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate2h()).compareTo(BigDecimal.valueOf(30)) > 0) {
                        css.setRate2h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate2h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate2h_css("text-danger");
                    }

                    if (Utils.getBigDecimal(dto.getRate4h()).compareTo(BigDecimal.valueOf(40)) > 0) {
                        css.setRate4h_css("text-primary");
                    } else if (Utils.getBigDecimal(dto.getRate4h()).compareTo(BigDecimal.valueOf(0)) < 0) {
                        css.setRate4h_css("text-danger");
                    }

                    BigDecimal price_min = Utils.getBigDecimal(avgPriceList.get(idx_price_min));
                    BigDecimal price_max = Utils.getBigDecimal(avgPriceList.get(idx_price_max));

                    priorityCoin.setMin_price_14d(price_min);
                    priorityCoin.setMax_price_14d(price_max);

                    BigDecimal min_14d_per = Utils.getBigDecimalValue(Utils.toPercent(dto.getMin14d(), price_now));
                    String min_14d = "Min14d: " + Utils.removeLastZero(dto.getMin14d().toString()) + "(" + min_14d_per
                            + "%) Max14d: ";

                    if (min_14d_per.compareTo(BigDecimal.valueOf(-0.8)) > 0) {
                        css.setStar("m14d" + css.getStar());
                        css.setStar_css("text-white rounded-lg bg-info");

                        css.setMin_14d_css("text-primary");

                    } else if (min_14d_per.compareTo(BigDecimal.valueOf(-3)) > 0) {
                        css.setMin_14d_css("text-primary");
                    }

                    String max_14d_percent = Utils.toPercent(price_max, price_now);
                    css.setOco_tp_price(min_14d);
                    css.setOco_tp_price_hight(price_max.toString() + "(" + max_14d_percent + "%)");

                    if (Utils.getBigDecimalValue(max_14d_percent).compareTo(BigDecimal.ZERO) <= 0) {

                        BigDecimal avg_boll_max = Utils
                                .getBigDecimalValue(Utils.toPercent(dto.getPrice_can_sell(), price_now, 1));

                        if (avg_boll_max.compareTo(BigDecimal.valueOf(0.1)) <= 0) {
                            css.setAvg_boll_max_css("text-danger");
                        }
                    }

                    if (Utils.getBigDecimalValue(max_14d_percent).compareTo(BigDecimal.valueOf(20)) > 0) {
                        css.setOco_tp_price_hight_css("text-primary font-weight-bold");
                    } else if (Utils.getBigDecimalValue(max_14d_percent).compareTo(BigDecimal.valueOf(10)) > 0) {
                        css.setOco_tp_price_hight_css("text-primary");
                    } else {
                        css.setOco_tp_price_hight_css("text-danger");
                    }

                    BigDecimal min28d_percent = Utils.getBigDecimalValue(Utils.toPercent(dto.getMin28d(), price_now));
                    BigDecimal max28d_percent = Utils.getBigDecimalValue(Utils.toPercent(dto.getMax28d(), price_now));

                    String avg_history = "L60d: " + Utils.removeLastZero(dto.getMin60d().toString()) + "("
                            + Utils.toPercent(dto.getMin60d(), price_now) + "%)";

                    avg_history += ", L28d: " + Utils.removeLastZero(dto.getMax28d().toString()) + "(" + max28d_percent
                            + "%), min28d: ";

                    String min28day = Utils.removeLastZero(dto.getMin28d().toString()) + "(" + min28d_percent + "%)";

                    if ((price_now.compareTo(dto.getMax28d()) < 0)
                            || (max28d_percent.compareTo(BigDecimal.valueOf(-0.5)) >= 0)) {

                        // String hold = "HOLD_28d:" + dto.getSymbol() + " (" +
                        // Utils.removeLastZero(price_now.toString()) + "$)";
                        // hold += ", " + avg_history + min28day + ", Mc:" +
                        // Utils.toMillions(dto.getMarket_cap());

                        String key_hold = "HOLD"
                                + Utils.convertDateToString("_yyyyMMdd_", Calendar.getInstance().getTime())
                                + dto.getSymbol();

                        if (!msg_vol_up_dict.contains(key_hold)) {
                            // Utils.sendToMyTelegram(hold);
                            msg_vol_up_dict.put(key_hold, key_hold);
                        }

                        css.setMin28day_css("text-primary font-weight-bold");
                        css.setStar("m28d " + css.getStar());
                        css.setStar_css("text-white rounded-lg bg-info");

                    } else if (min28d_percent.compareTo(BigDecimal.valueOf(-10)) < 0) {

                        // css.setMin28day_css("text-danger");

                    }

                    css.setAvg_history(avg_history);
                    css.setMin28day(min28day);
                }

                priorityCoin.setTarget_price(Utils.getBigDecimalValue(css.getAvg_price()));
                priorityCoin.setVmc(Utils.getIntValue(css.getVolumn_div_marketcap()));
                priorityCoin.setLow_price(lowest_price_today);
                priorityCoin.setHeight_price(highest_price_today);
                priorityCoin.setIndex(index);
                priorityCoin.setSymbol(css.getSymbol());
                priorityCoin.setName(css.getName());
                priorityCoin.setEma(dto.getEma07d());

                Boolean is_candidate = false;
                Boolean predict = false;
                if (!Objects.equals(null, dto.getPrice_can_buy()) && !Objects.equals(null, dto.getPrice_can_sell())
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_buy()) != 0
                        && BigDecimal.ZERO.compareTo(dto.getPrice_can_sell()) != 0) {

                    BigDecimal stop_loss = (dto.getLow_price_24h().multiply(BigDecimal.valueOf(0.999)))
                            .setScale(Utils.getDecimalNumber(dto.getLow_price_24h()), BigDecimal.ROUND_DOWN);
                    BigDecimal price_can_buy_24h = dto.getPrice_can_buy();

                    BigDecimal price_can_buy_24h_percent = Utils
                            .getBigDecimalValue(Utils.toPercent(price_can_buy_24h, price_now));

                    BigDecimal stop_loss_precent = Utils
                            .getBigDecimalValue(Utils.toPercent(stop_loss, price_can_buy_24h));

                    BigDecimal price_can_sell_24h = dto.getPrice_can_sell();
                    BigDecimal take_profit_percent = Utils
                            .getBigDecimalValue(Utils.toPercent(price_can_sell_24h, price_now));
                    BigDecimal roe = take_profit_percent;
                    if (take_profit_percent.compareTo(BigDecimal.ZERO) != 0) {
                        if (stop_loss_precent.abs().compareTo(BigDecimal.valueOf(1)) > 0) {
                            roe = take_profit_percent.divide(stop_loss_precent.abs(), 5, RoundingMode.CEILING);
                        }

                    }

                    priorityCoin.setTarget_percent(Utils.getIntValue(take_profit_percent.toBigInteger()));

                    css.setAvg_boll_min("Buy: " + Utils.removeLastZero(price_can_buy_24h.toString()) + "("
                            + price_can_buy_24h_percent + "%)");

                    css.setAvg_boll_max("TP: " + take_profit_percent + "%");

                    css.setStop_loss("SL: " + Utils.removeLastZero(stop_loss) + "(" + stop_loss_precent + "%)");

                    String priceChange24h = dto.getPrice_change_percentage_24h().replace("%", "");

                    if (!dto.getFutures().contains("Short:")) {
                        if (price_can_buy_24h_percent.compareTo(BigDecimal.valueOf(-1.5)) > 0) {
                            css.setAvg_boll_min_css("text-white bg-success rounded-lg");
                        }

                        if (Utils.getBigDecimalValue(priceChange24h).compareTo(BigDecimal.valueOf(6)) < 0) {
                            if (Utils.isGoodPriceLong(price_now, price_can_buy_24h, price_can_sell_24h)) {
                                if (roe.compareTo(BigDecimal.valueOf(3)) > 0) {
                                    css.setStop_loss_css("bg-warning rounded-lg px-1");
                                    css.setAvg_boll_min_css("text-white bg-success rounded-lg");
                                    css.setAvg_boll_max_css("bg-warning rounded-lg px-1");
                                }
                            }
                        }
                    }

                    BigDecimal temp_prire_24h = Utils
                            .formatPrice(dto.getLow_price_24h().multiply(BigDecimal.valueOf(1.008)), 5);
                    if (dto.getPrice_can_buy().compareTo(temp_prire_24h) < 0) {
                        temp_prire_24h = dto.getPrice_can_buy();
                    }
                    temp_prire_24h = Utils.formatPriceLike(temp_prire_24h, price_now);
                    BigDecimal temp_prire_24h_percent = Utils
                            .getBigDecimalValue(Utils.toPercent(temp_prire_24h, price_now));
                    css.setEntry_price(temp_prire_24h);
                    css.setStr_entry_price("E:" + Utils.removeLastZero(temp_prire_24h.toString()) + "("
                            + Utils.removeLastZero(temp_prire_24h_percent.toString()) + "%)");

                    if (!dto.getFutures().contains("Short:")) {
                        if (temp_prire_24h_percent.compareTo(BigDecimal.valueOf(-1)) > 0) {
                            css.setStr_entry_price_css("text-primary font-weight-bold");
                        } else if (temp_prire_24h_percent.compareTo(BigDecimal.valueOf(-0.3)) > 0) {
                            css.setStr_entry_price_css("text-white bg-success rounded-lg");
                        }
                    }
                    css.setTrading_view("https://vn.tradingview.com/chart/?symbol=BINANCE%3A"
                            + dto.getSymbol().toUpperCase() + "USDT");

                    // btc_warning_css
                    if (Objects.equals("BTC", dto.getSymbol().toUpperCase())) {

                        String textDepth = getTextDepthData();
                        css.setOco_depth(textDepth);

                        css.setBinance_trade("https://www.tradingview.com/chart/?symbol=CRYPTOCAP%3AUSDT.D");
                        css.setCoin_gecko_link("https://www.tradingview.com/chart/?symbol=CRYPTOCAP%3ATOTAL");

                        String curr_time_of_btc = Utils.convertDateToString("yyyy-MM-dd_HH",
                                Calendar.getInstance().getTime()); // dd_HH_mm
                        curr_time_of_btc = curr_time_of_btc.substring(0, curr_time_of_btc.length() - 1);

                        BigDecimal btc_range_b_s = ((price_can_sell_24h.subtract(price_can_buy_24h))
                                .divide(price_can_buy_24h, 3, RoundingMode.CEILING));

                        int hh = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
                        boolean check_L_H = true;
                        if (hh < 7 || hh > 12) {
                            BigDecimal btc_range_L_H = taget_percent_profit_today.subtract(taget_percent_lost_today);
                            if (btc_range_L_H.compareTo(BigDecimal.valueOf(1)) < 0) {
                                check_L_H = false;
                            }
                        }

                        // take_profit_percent > 3% ?
                        if ((btc_range_b_s.compareTo(BigDecimal.valueOf(0.015)) >= 0) && check_L_H) {

                            if (Utils.isGoodPriceLong(price_now, price_can_buy_24h, price_can_sell_24h)) {

                                css.setBtc_warning_css("bg-success rounded-lg");
                                if (!Objects.equals(curr_time_of_btc, pre_time_of_btc)) {
                                    btc_is_good_price = true;
                                    // (Good time to buy)

                                    pre_time_of_btc = curr_time_of_btc;
                                }
                            }

                            if ((price_now.multiply(BigDecimal.valueOf(1.005)).compareTo(highest_price_today) > 0)) {

                                css.setBtc_warning_css("bg-danger rounded-lg");

                                if (ordersRepository.count() > 0) {
                                    String curr_percent_btc = Utils.toPercent(price_now, highest_price_today);
                                    if (!Objects.equals(curr_percent_btc, pre_time_of_btc)) {

                                        Utils.sendToTelegram(
                                                "(Time to Sell) Btc: " + Utils.removeLastZero(price_now.toString())
                                                        + Utils.new_line_from_service + css.getLow_to_hight_price()
                                                        + Utils.new_line_from_service + "Can" + css.getAvg_boll_min()
                                                        + " " + "Can" + css.getAvg_boll_max());
                                    }
                                }

                            }
                        }
                    }

                }

                if ((Utils.getBigDecimalValue(dto.getVolumn_div_marketcap()).compareTo(BigDecimal.valueOf(20)) < 0)
                        && (volumn_binance_div_marketcap.compareTo(BigDecimal.valueOf(10)) < 0)) {
                    is_candidate = false;
                    predict = false;
                    css.setVolumn_binance_div_marketcap_css("font-weight-bold text-danger");
                }

                if (Objects.equals("BTC", dto.getSymbol().toUpperCase())) {

                    // monitorToken(css); // debug

                    if (!Objects.equals(pre_yyyyMMddHH,
                            Utils.convertDateToString("yyyyMMddHH", Calendar.getInstance().getTime()))) {

                        sp500 = loadPremarketSp500().replace(" ", "").replace("Futures", "(Futures)")
                                .replace(Utils.new_line_from_bot, " ");

                        pre_yyyyMMddHH = Utils.convertDateToString("yyyyMMddHH", Calendar.getInstance().getTime());
                    }

                    css.setNote("");
                    String btcOnEx = getBtcBalancesOnExchanges().replaceAll(Utils.new_line_from_service, " ");
                    css.setPumping_history(btcOnEx);

                    css.setStar(sp500);
                    css.setStar_css("display-tity text-left");
                    if (sp500.contains("-")) {
                        css.setStar_css("bg-danger rounded-lg display-tity text-left text-white");
                    }
                }
                // ---------------------------------------------------

                priorityCoin.setPredict(predict);
                priorityCoin.setCandidate(is_candidate);

                String note = "Can" + css.getAvg_boll_min() + "~" + "Can" + css.getAvg_boll_max() + "~";

                note += "v/mc:"
                        + Utils.getBigDecimalValue(css.getGecko_total_volume().replaceAll(",", ""))
                                .divide(BigDecimal.valueOf(1000000), 1, RoundingMode.CEILING)
                        + "M (" + css.getVolumn_div_marketcap() + "%)";

                note += ", B:"
                        + Utils.getBigDecimalValue(css.getToday_vol().replaceAll(",", ""))
                                .divide(BigDecimal.valueOf(1000000), 1, RoundingMode.CEILING)
                        + "M (" + css.getVolumn_binance_div_marketcap().replace("B:", "") + "%)";

                note += ", Mc:" + Utils.getBigDecimalValue(css.getMarket_cap().replaceAll(",", ""))
                        .divide(BigDecimal.valueOf(1000000), 1, RoundingMode.CEILING);

                note += "M~24h: " + Utils.formatPrice(Utils.getBigDecimalValue(css.getPrice_change_percentage_24h()), 1)
                        + "%, 7d: "
                        + Utils.formatPrice(Utils.getBigDecimalValue(css.getPrice_change_percentage_7d()), 1)
                        + "%, 14d: "
                        + Utils.formatPrice(Utils.getBigDecimalValue(css.getPrice_change_percentage_14d()), 1) + "%"

                        + ", Vol4h: " + Utils.getBigDecimal(dto.getVol_up_rate()).toString();

                note += (Utils.isNotBlank(Utils.getStringValue(css.getNote()))
                        ? "~" + Utils.getStringValue(css.getNote())
                        : "")

                        + (Utils.isNotBlank(Utils.getStringValue(css.getTrend()))
                                ? "~" + Utils.getStringValue(css.getTrend())
                                : "")

                        + (Utils.isNotBlank(Utils.getStringValue(css.getPumping_history()))
                                ? "~" + Utils.getStringValue(css.getPumping_history())
                                : "");

                note += "~" + css.getOco_tp_price() + css.getOco_tp_price_hight();

                priorityCoin.setNote(note);

                priorityCoin.setGoodPrice(false);
                if (this_token_is_good_price || btc_is_good_price) {
                    priorityCoin.setGoodPrice(true);
                }

                index += 1;
                priorityCoinRepository.save(priorityCoin);

                sql_update_ema += String.format(
                        " update binance_volumn_week set ema='%s', price_change_24h='%s', gecko_volume='%s', min_price_14d='%s', max_price_14d='%s' ",
                        dto.getEma07d(), dto.getPrice_change_percentage_24h(), dto.getVol0d(),
                        Utils.getBigDecimal(avgPriceList.get(idx_price_min)),
                        Utils.getBigDecimal(avgPriceList.get(idx_price_max)));

                sql_update_ema += String.format(
                        " where gecko_id='%s' and symbol='%s' and yyyymmdd=TO_CHAR(NOW(), 'yyyyMMdd'); \n",
                        dto.getGecko_id(), dto.getSymbol());

                list.add(css);
            }

            query = entityManager.createNativeQuery(sql_update_ema);
            query.executeUpdate();

            if (btc_is_good_price) {
                // monitorTokenSales(list);
            }
            // monitorTokenSales(list); //debug
            return list;

        } catch (Exception e) {
            e.printStackTrace();
            log.info("Get list Inquiry Consigned Delivery error ------->");
            log.error(e.getMessage());
            return new ArrayList<CandidateTokenCssResponse>();
        }
    }

    public String monitorTokenSales(List<CandidateTokenCssResponse> results) {

        String buy_msg = "";
        int count = 1;
        int idx = 1;
        String strCanBuy = "(" + Utils.convertDateToString("MM/dd HH:mm", Calendar.getInstance().getTime()) + ")";

        String sp500 = loadPremarketSp500();
        boolean alert = true;
        if (sp500.contains("S&P500-") && !Utils.isBusinessTime()) {
            alert = false;
        }

        for (CandidateTokenCssResponse dto : results) {
            idx += 1;
            if (idx > 100) {
                break;
            }

            String msg = monitorToken(dto);

            if (Utils.isNotBlank(msg)) {

                if (msg.contains("BUY:")) {

                    if (Utils.isNotBlank(buy_msg)) {
                        buy_msg += Utils.new_line_from_service;
                    }
                    buy_msg += msg.replace("BUY:", "(" + Utils.getStringValue(count) + ")..");

                    count += 1;

                    if (alert && (count % 10 == 0)) {
                        if (count < 11) {
                            Utils.sendToTelegram(strCanBuy + Utils.new_line_from_service + buy_msg);
                        } else {
                            Utils.sendToTelegram(Utils.new_line_from_service + buy_msg);
                        }

                        buy_msg = "";
                        if (count > 20) {
                            return "";
                        }
                    }
                }

            }
        }

        String result = "";
        if (alert && Utils.isNotBlank(buy_msg) && !msg_vol_up_dict.contains(buy_msg)) {

            if (count < 11) {
                Utils.sendToTelegram(strCanBuy + Utils.new_line_from_service + buy_msg);
            } else {
                Utils.sendToTelegram(Utils.new_line_from_service + buy_msg);
            }

            msg_vol_up_dict.put(buy_msg, buy_msg);
            result = buy_msg;
        }

        return result;
    }

    public String monitorToken(CandidateTokenCssResponse css) {
        boolean isCandidate = false;
        if (css.getSymbol().equals("BTC")) {
            isCandidate = true;
        }

        String priceChange24h = css.getPrice_change_percentage_24h().replace("%", "");

        if (!isCandidate && Utils.isNotBlank(css.getAvg_boll_min_css())
                && (css.getRate1d0h().compareTo(BigDecimal.valueOf(0)) > 0)
                && (Utils.getBigDecimalValue(priceChange24h).compareTo(BigDecimal.valueOf(6)) < 0)) {

            if (CollectionUtils.isEmpty(ordersRepository.findAllByIdGeckoid(css.getGecko_id()))) {
                if (binanceFuturesRepository.existsById(css.getGecko_id())) {

                    isCandidate = true;
                }
            }
        }

        if (isCandidate) {
            String result = Utils.removeLastZero(css.getLow_price_24h().toString());
            result += "~" + Utils.removeLastZero(css.getEntry_price().toString()) + ", ";

            String stop_loss1 = String.valueOf(css.getStop_loss().subSequence(css.getStop_loss().indexOf("(") + 1,
                    css.getStop_loss().indexOf(")"))).replaceAll("%", "");

            String stop_loss2 = css.getAvg_boll_min().substring(css.getAvg_boll_min().indexOf("(") + 1,
                    css.getAvg_boll_min().indexOf("%"));

            result += "SL" + Utils.getBigDecimalValue(stop_loss1).add(Utils.getBigDecimalValue(stop_loss2)) + "%";

            result = "BUY:" + Utils.appendSpace(css.getSymbol(), 4) + result;

            result = result.replace(" ", ".").replace(",", ".");

            if (css.getSymbol().equals("BTC")) {
                result += Utils.new_line_from_service + css.getOco_depth();
            }

            return result;
        }

        return "";
    }

    private void setEmaCss(CandidateTokenCssResponse css) {
        if (!css.getToday_ema().contains("-") && css.getDay_0_ema().contains("-")) {
            css.setToday_ema_css("text-primary font-weight-bold");
        } else if (css.getToday_ema().contains("-")) {
            css.setToday_ema_css("text-danger");
        } else {
            css.setToday_ema_css("text-primary");
        }

        if (!css.getDay_0_ema().contains("-")) {
            css.setDay_0_ema_css("text-primary");
        } else if (css.getDay_0_ema().contains("-")) {
            css.setDay_0_ema_css("text-danger");
        }

        if (!css.getDay_1_ema().contains("-")) {
            css.setDay_1_ema_css("text-primary");
        } else if (css.getDay_1_ema().contains("-")) {
            css.setDay_1_ema_css("text-danger");
        }

        if (!css.getDay_2_ema().contains("-")) {
            css.setDay_2_ema_css("text-primary");
        } else if (css.getDay_2_ema().contains("-")) {
            css.setDay_2_ema_css("text-danger");
        }

        if (!css.getDay_3_ema().contains("-")) {
            css.setDay_3_ema_css("text-primary");
        } else if (css.getDay_3_ema().contains("-")) {
            css.setDay_3_ema_css("text-danger");
        }

        if (!css.getDay_4_ema().contains("-")) {
            css.setDay_4_ema_css("text-primary");
        } else if (css.getDay_4_ema().contains("-")) {
            css.setDay_4_ema_css("text-danger");
        }

        if (!css.getDay_5_ema().contains("-")) {
            css.setDay_5_ema_css("text-primary");
        } else if (css.getDay_5_ema().contains("-")) {
            css.setDay_5_ema_css("text-danger");
        }

        if (!css.getDay_6_ema().contains("-")) {
            css.setDay_6_ema_css("text-primary");
        } else if (css.getDay_6_ema().contains("-")) {
            css.setDay_6_ema_css("text-danger");
        }

        if (!css.getDay_7_ema().contains("-")) {
            css.setDay_7_ema_css("text-primary");
        } else if (css.getDay_7_ema().contains("-")) {
            css.setDay_7_ema_css("text-danger");
        }

        if (!css.getDay_8_ema().contains("-")) {
            css.setDay_8_ema_css("text-primary");
        } else if (css.getDay_8_ema().contains("-")) {
            css.setDay_8_ema_css("text-danger");
        }

        if (!css.getDay_9_ema().contains("-")) {
            css.setDay_9_ema_css("text-primary");
        } else if (css.getDay_9_ema().contains("-")) {
            css.setDay_9_ema_css("text-danger");
        }

        if (!css.getDay_10_ema().contains("-")) {
            css.setDay_10_ema_css("text-primary");
        } else if (css.getDay_10_ema().contains("-")) {
            css.setDay_10_ema_css("text-danger");
        }

        if (!css.getDay_11_ema().contains("-")) {
            css.setDay_11_ema_css("text-primary");
        } else if (css.getDay_11_ema().contains("-")) {
            css.setDay_11_ema_css("text-danger");
        }

    }

    private Long getValue(String value) {
        if (Objects.equals(null, value) || Objects.equals("", value))
            return Long.valueOf(0);

        return Long.valueOf(value);

    }

    private int getIndexMax(List<String> list) {
        int max_idx = 0;
        String str_temp = "";
        BigDecimal temp = BigDecimal.ZERO;
        BigDecimal max_val = BigDecimal.ZERO;

        for (int idx = 0; idx < list.size(); idx++) {
            str_temp = String.valueOf(list.get(idx)).replace(",", "");

            if (!Objects.equals("", str_temp)) {

                temp = Utils.getBigDecimal(str_temp);
                if (temp.compareTo(max_val) == 1) {
                    max_val = temp;
                    max_idx = idx;
                }
            }
        }

        return max_idx;
    }

    private int getIndexMin(List<String> list) {
        int min_idx = 0;
        String str_temp = "";
        BigDecimal temp = BigDecimal.ZERO;
        BigDecimal min_val = BigDecimal.valueOf(Long.MAX_VALUE);

        for (int idx = 0; idx < list.size(); idx++) {
            str_temp = String.valueOf(list.get(idx)).replace(",", "");

            if (!Objects.equals("", str_temp)) {

                temp = Utils.getBigDecimal(str_temp);
                if (temp.compareTo(min_val) == -1) {
                    min_val = temp;
                    min_idx = idx;
                }
            }
        }

        return min_idx;
    }

    private void setVolumnDayCss(CandidateTokenCssResponse css, int index, String css_class) {
        switch (index) {
        case 0:
            css.setToday_vol_css(css_class);
            break;
        case 1:
            css.setDay_0_vol_css(css_class);
            break;
        case 2:
            css.setDay_1_vol_css(css_class);
            break;
        case 3:
            css.setDay_2_vol_css(css_class);
            break;
        case 4:
            css.setDay_3_vol_css(css_class);
            break;
        case 5:
            css.setDay_4_vol_css(css_class);
            break;
        case 6:
            css.setDay_5_vol_css(css_class);
            break;
        case 7:
            css.setDay_6_vol_css(css_class);
            break;
        case 8:
            css.setDay_7_vol_css(css_class);
            break;
        case 9:
            css.setDay_8_vol_css(css_class);
            break;
        case 10:
            css.setDay_9_vol_css(css_class);
            break;
        case 11:
            css.setDay_10_vol_css(css_class);
            break;
        case 12:
            css.setDay_11_vol_css(css_class);
            break;
        case 13:
            css.setDay_12_vol_css(css_class);
            break;
        }
    }

    private void setPriceDayCss(CandidateTokenCssResponse css, int index, String css_class, String percent) {
        switch (index) {
        case 0:
            break;
        case 1:
            css.setDay_0_price_css(css_class);
            css.setDay_0_price(css.getDay_0_price() + percent);
            break;
        case 2:
            css.setDay_1_price_css(css_class);
            css.setDay_1_price(css.getDay_1_price() + percent);
            break;
        case 3:
            css.setDay_2_price_css(css_class);
            css.setDay_2_price(css.getDay_2_price() + percent);
            break;
        case 4:
            css.setDay_3_price_css(css_class);
            css.setDay_3_price(css.getDay_3_price() + percent);
            break;
        case 5:
            css.setDay_4_price_css(css_class);
            css.setDay_4_price(css.getDay_4_price() + percent);
            break;
        case 6:
            css.setDay_5_price_css(css_class);
            css.setDay_5_price(css.getDay_5_price() + percent);
            break;
        case 7:
            css.setDay_6_price_css(css_class);
            css.setDay_6_price(css.getDay_6_price() + percent);
            break;
        case 8:
            css.setDay_7_price_css(css_class);
            css.setDay_7_price(css.getDay_7_price() + percent);
            break;
        case 9:
            css.setDay_8_price_css(css_class);
            css.setDay_8_price(css.getDay_8_price() + percent);
            break;
        case 10:
            css.setDay_9_price_css(css_class);
            css.setDay_9_price(css.getDay_9_price() + percent);
            break;
        case 11:
            css.setDay_10_price_css(css_class);
            css.setDay_10_price(css.getDay_10_price() + percent);
            break;
        case 12:
            css.setDay_11_price_css(css_class);
            css.setDay_11_price(css.getDay_11_price() + percent);
            break;
        case 13:
            css.setDay_12_price_css(css_class);
            css.setDay_12_price(css.getDay_12_price() + percent);
            break;
        }
    }

    private List<String> splitVolAndPrice(String value) {
        if (Objects.isNull(value)) {
            return Arrays.asList("", "", "", "", "", "", "");
        }
        String[] arr = value.split("~");

        String volumn = arr[0];
        String avg_price = arr[1];
        String min_price = arr[2];
        String max_price = arr[3];
        volumn = String.format("%,.0f", Utils.getBigDecimal(volumn));

        return Arrays.asList(volumn, Utils.removeLastZero(avg_price), Utils.removeLastZero(min_price),
                Utils.removeLastZero(max_price), arr[4], arr[5], arr[6]);
    }

    @SuppressWarnings("unchecked")
    @Override
    @Transactional
    public void monitorProfit() {
        try {
            log.info("Start monitorProfit ---->");

            Query query = entityManager.createNativeQuery(Utils.sql_OrdersProfitResponse, "OrdersProfitResponse");

            List<OrdersProfitResponse> results = query.getResultList();

            if (!CollectionUtils.isEmpty(results)) {

                for (OrdersProfitResponse dto : results) {
                    String msg = "";

                    BigDecimal tp_percent = Utils.getBigDecimalValue(String.valueOf(dto.getTp_percent()));
                    BigDecimal target_percent = Utils.getBigDecimalValue(String.valueOf(dto.getTarget_percent()))
                            .multiply(BigDecimal.valueOf(0.9));

                    if (target_percent.compareTo(BigDecimal.valueOf(5)) < 0) {
                        target_percent = BigDecimal.valueOf(5);
                    }

                    if (tp_percent.compareTo(target_percent) >= 0) {

                        msg += "TakeProfit (target=" + target_percent + "%): "
                                + Utils.createMsgBalance(dto, Utils.new_line_from_service) + Utils.new_line_from_service
                                + Utils.new_line_from_service;

                    } else if (tp_percent.compareTo(BigDecimal.valueOf(-5)) <= 0) {

                        msg += "STOP LOSS 5%: " + Utils.createMsgBalance(dto, Utils.new_line_from_service)
                                + Utils.new_line_from_service + Utils.new_line_from_service;

                    } else if (tp_percent.compareTo(BigDecimal.valueOf(-1)) <= 0) {

                        msg += "STOP LOSS 1%: " + Utils.createMsgBalance(dto, Utils.new_line_from_service)
                                + Utils.new_line_from_service + Utils.new_line_from_service;
                    }

                    if (Utils.isNotBlank(msg)) {
                        Utils.sendToChatId(dto.getChatId(), msg);
                    }
                }

            }
        } catch (Exception e) {
            e.printStackTrace();
            log.info("monitorProfit error ------->");
            log.error(e.getMessage());
        }
    }

    @Override
    @Transactional
    public void monitorBollingerBandwidth(Boolean isCallFormBot) {
        try {
            int minus = Utils.getIntValue(Utils.convertDateToString("mm", Calendar.getInstance().getTime()));

            log.info("Start monitorToken ---->");
            if (minus >= 45) {
                String sql = "" + " select                                                              \n"
                        + "     boll.gecko_id,                                                          \n"
                        + "     boll.symbol,                                                            \n"
                        + "     boll.name,                                                              \n"
                        + "     boll.avg_price,                                                         \n"
                        + "     boll.price_open_candle,                                                 \n"
                        + "     boll.price_close_candle,                                                \n"
                        + "     boll.low_price,                                                         \n"
                        + "     boll.hight_price,                                                       \n"
                        + "     boll.price_can_buy,                                                     \n"
                        + "     boll.price_can_sell,                                                    \n"
                        + "     boll.is_bottom_area,                                                    \n"
                        + "     boll.is_top_area,                                                       \n"
                        + "     ROUND(100*(price_can_sell - price_can_buy)/price_can_buy, 2) as profit,                                             \n"
                        + "     (case when vector.vector_now > 0 then true else false end)   as vector_up,                                          \n"
                        + "     concat('v1h:', cast(vector.vector_now as varchar), ', v4h:' ,cast(vector.vector_pre4h as varchar)) as vector_desc   \n"
                        + " FROM                                                                        \n"
                        + Utils.sql_boll_2_body + " , \n"
                        + " (                                                                                      \n"
                        + "  select                                                                                \n"
                        + "       pre.gecko_id,                                                                    \n"
                        + "       pre.hh,                                                                          \n"
                        + "       ROUND(100 * (price_now   - price_pre4h) /price_pre4h, 2)  as vector_now,         \n"
                        + "       ROUND(100 * (price_pre4h - price_pre8h) /price_pre8h, 2)  as vector_pre4h        \n"
                        + "   from (                                                                               \n"
                        + "       select                                                                           \n"
                        + "       tmp.gecko_id,                                                                    \n"
                        + "       tmp.hh,                                                                          \n"
                        + "       (case when price_now is null then price_pre1h else price_now end) as price_now,  \n"
                        + "          price_pre4h,                                                                  \n"
                        + "          price_pre8h                                                                   \n"
                        + "       from (                                                                           \n"
                        + "           select                                                                       \n"
                        + "               d.gecko_id,                                                              \n"
                        + "               d.hh, \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW(), 'HH24')) as price_now,                          \n"
                        + "               (select COALESCE(h.avg_price, 0) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh = TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre1h,  \n"
                        + "                                                                                             \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '4 hours', 'HH24') and TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as price_pre4h,   \n"
                        + "               (select ROUND(AVG(COALESCE(h.avg_price, 0)), 5) from btc_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '8 hours', 'HH24') and TO_CHAR(NOW() - interval  '5 hours', 'HH24')) as price_pre8h    \n"
                        + "           from  \n" + "               btc_volumn_day d \n"
                        + "           where d.hh = (case when EXTRACT(MINUTE FROM NOW()) < 3 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                        + "           ) as tmp                                                                     \n"
                        + "   ) as pre                                                                             \n"
                        + " ) vector                                                                               \n"
                        + "                                                                                        \n"
                        + " where 1=1                                                                              \n"
                        + " and vector.gecko_id = boll.gecko_id                                                    \n";

                Query query = entityManager.createNativeQuery(sql, "BollAreaResponse");

                @SuppressWarnings("unchecked")
                List<BollAreaResponse> boll_anna_list = query.getResultList();
                if (!CollectionUtils.isEmpty(boll_anna_list)) {

                    List<BollArea> list = new ArrayList<BollArea>();
                    for (BollAreaResponse dto : boll_anna_list) {
                        BollArea entiy = (new ModelMapper()).map(dto, BollArea.class);
                        list.add(entiy);
                    }

                    bollAreaRepository.deleteAll();
                    bollAreaRepository.saveAll(list);
                }
            }

            if (minus >= 45) {
                String sql = " select                                                                       \n"
                        + "     gecko_id,                                                                   \n"
                        + "     symbol,                                                                     \n"
                        + "     hh,                                                                         \n"
                        + "     curr_voulme,                                                                \n"
                        + "     avg_vol_pre4h,                                                              \n"
                        + "     ROUND(vol.curr_voulme / avg_vol_pre4h, 1) as vol_up_rate                    \n"
                        + " from                                                                            \n"
                        + " (                                                                               \n"
                        + "     select                                                                      \n"
                        + "         gecko_id,                                                               \n"
                        + "         symbol,                                                                 \n"
                        + "         hh,                                                                     \n"
                        + "         ROUND(total_volume/1000000, 1) as curr_voulme,                          \n"
                        + "         (select ROUND(AVG(COALESCE(h.total_volume, 0))/1000000, 1) from gecko_volumn_day h where h.gecko_id = d.gecko_id and h.hh between TO_CHAR(NOW() - interval  '4 hours', 'HH24') and TO_CHAR(NOW() - interval  '1 hours', 'HH24')) as avg_vol_pre4h \n"
                        + "     from gecko_volumn_day d                                                     \n"
                        + "     where d.hh = (case when EXTRACT(MINUTE FROM NOW()) < 15 then TO_CHAR(NOW() - interval '1 hours', 'HH24') else TO_CHAR(NOW(), 'HH24') end) \n"
                        + " ) vol                                                                           \n"
                        + " where                                                                           \n"
                        + "     avg_vol_pre4h > 0                                                           \n"
                        + " order by                                                                        \n"
                        + "     vol.curr_voulme / avg_vol_pre4h desc                                        \n";

                Query query = entityManager.createNativeQuery(sql, "GeckoVolumeUpPre4hResponse");

                @SuppressWarnings("unchecked")
                List<GeckoVolumeUpPre4hResponse> vol_list = query.getResultList();
                if (!CollectionUtils.isEmpty(vol_list)) {
                    geckoVolumeUpPre4hRepository.deleteAll();
                    List<GeckoVolumeUpPre4h> saveList = new ArrayList<GeckoVolumeUpPre4h>();

                    for (GeckoVolumeUpPre4hResponse dto : vol_list) {
                        GeckoVolumeUpPre4h entity = (new ModelMapper()).map(dto, GeckoVolumeUpPre4h.class);
                        entity.setGeckoid(dto.getGecko_id());
                        saveList.add(entity);
                    }
                    geckoVolumeUpPre4hRepository.saveAll(saveList);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            log.info("monitorToken error ------->");
            log.error(e.getMessage());
        }
    }

    @Override
    public List<Orders> getOrderList() {
        return ordersRepository.findAll();
    }

    @Override
    public String loadPremarket() {
        String sp_500 = getPreMarket("https://markets.businessinsider.com/index/s&p_500");
        String sp500_future = getPreMarket("https://markets.businessinsider.com/futures/s&p-500-futures");

        String dow_jones = getPreMarket("https://markets.businessinsider.com/index/dow_jones");
        String dow_jones_future = getPreMarket("https://markets.businessinsider.com/futures/dow-futures");

        String nasdaq = getPreMarket("https://markets.businessinsider.com/index/nasdaq_100");
        String nasdaq_future = getPreMarket("https://markets.businessinsider.com/futures/nasdaq-100-futures");

        String value = "";
        value = appendStringForBot(value, sp_500);
        value = appendStringForBot(value, sp500_future);
        value = appendStringForBot(value, "");
        value = appendStringForBot(value, dow_jones);
        value = appendStringForBot(value, dow_jones_future);
        value = appendStringForBot(value, "");
        value = appendStringForBot(value, nasdaq);
        value = appendStringForBot(value, nasdaq_future);

        return value;
    }

    @Override
    public String loadPremarketSp500() {
        String value = "";

        String sp_500 = getPreMarket("https://markets.businessinsider.com/index/s&p_500");
        String sp500_future = getPreMarket("https://markets.businessinsider.com/futures/s&p-500-futures");

        value = appendStringForBot(value, sp_500);
        value = appendStringForBot(value, sp500_future);
        return value;
    }

    private String appendStringForBot(String value, String append) {
        String val = value;
        if (Utils.isNotBlank(append)) {
            if (Utils.isNotBlank(val)) {
                val += Utils.new_line_from_bot;
            }
            val += append.replace("E-mini ", "");
        }

        return val;
    }

    private String getPreMarket(String url) {
        try {
            Document doc = Jsoup.connect(url).get();

            Elements assets1 = doc.getElementsByClass("price-section__label");
            Elements assets2 = doc.getElementsByClass("price-section__absolute-value");
            Elements assets3 = doc.getElementsByClass("price-section__relative-value");

            String sp500 = "";
            if (!Objects.equals(null, assets1) && assets1.size() > 0) {
                sp500 = assets1.get(0).text() + "";
            }
            if (!Objects.equals(null, assets2) && assets2.size() > 0) {
                sp500 += " " + assets2.get(0).text();
            }
            if (!Objects.equals(null, assets3) && assets3.size() > 0) {
                sp500 += " (" + assets3.get(0).text() + ")";
            }
            return sp500;
        } catch (Exception e) {
            log.info("BinanceServiceImpl.loadPremarket error --->");
            // e.printStackTrace();
            log.error(e.getMessage());
        }
        return "S&P 500 xxx (xxx%), Futures yyy (yyy%)";
    }

    // ------------------------------------------------------------------------------------

    @Override
    @Transactional
    public void loadDataVolumeHour(String gecko_id, String symbol) {
        try {
            final Integer limit = 24;
            String url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "USDT" + "&interval=1h&limit="
                    + String.valueOf(limit);

            List<Object> result_usdt = Utils.getBinanceData(url_usdt, limit);

            if (!isHasData(result_usdt, limit - 1)) {
                url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "BUSD" + "&interval=1h&limit="
                        + String.valueOf(limit);

                result_usdt = Utils.getBinanceData(url_usdt, limit);
            }

            List<BtcVolumeDay> list_day = new ArrayList<BtcVolumeDay>();

            int hh_index = 0;
            for (int idx = limit - 1; idx >= 0; idx--) {
                Object obj_usdt = result_usdt.get(idx);

                @SuppressWarnings("unchecked")
                List<Object> arr_usdt = (List<Object>) obj_usdt;

                BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
                BigDecimal price_high = Utils.getBigDecimal(arr_usdt.get(2));
                BigDecimal price_low = Utils.getBigDecimal(arr_usdt.get(3));
                BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));
                String open_time = arr_usdt.get(0).toString();

                if (Objects.equals("0", open_time)) {
                    break;
                }

                BigDecimal avgPrice = price_open_candle;
                if (price_open_candle.compareTo(price_close_candle) > 0) {
                    avgPrice = price_close_candle;
                }

                BtcVolumeDay day = new BtcVolumeDay();
                Calendar calendar = Calendar.getInstance();
                calendar.add(Calendar.HOUR_OF_DAY, -hh_index);
                day.setId(
                        new BinanceVolumnDayKey(gecko_id, symbol, Utils.convertDateToString("HH", calendar.getTime())));
                day.setAvg_price(avgPrice);
                day.setLow_price(price_low);
                day.setHight_price(price_high);
                day.setPrice_open_candle(price_open_candle);
                day.setPrice_close_candle(price_close_candle);
                list_day.add(day);

                hh_index += 1;
            }
            btcVolumeDayRepository.saveAll(list_day);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    @Transactional
    public String loadBinanceData(String gecko_id, String symbol) {
        // debug
        // scalping(gecko_id, symbol);

        try {
            final Integer limit = 14;
            final String url_usdt = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "USDT" + "&interval="
                    + TIME_1d + "&limit=" + String.valueOf(limit);

            final String url_busd = "https://api.binance.com/api/v3/klines?symbol=" + symbol + "BUSD" + "&interval="
                    + TIME_1d + "&limit=" + String.valueOf(limit);

            BigDecimal price_at_binance = Utils.getBinancePrice(SYMBOL_BTC);
            if (Objects.equals(BigDecimal.ZERO, price_at_binance)) {
                return "";
            }
            List<Object> result_usdt = Utils.getBinanceData(url_usdt, limit);
            List<Object> result_busd = Utils.getBinanceData(url_busd, limit);

            List<BinanceVolumnWeek> list_week = new ArrayList<BinanceVolumnWeek>();
            List<BigDecimal> list_price_close_candle = new ArrayList<BigDecimal>();

            String sql_pump_dump = "";
            BinanceVolumnDay day = new BinanceVolumnDay();
            int day_index = 0;
            for (int idx = limit - 1; idx >= 0; idx--) {
                Object obj_usdt = result_usdt.get(idx);
                Object obj_busd = result_busd.get(idx);

                @SuppressWarnings("unchecked")
                List<Object> arr_usdt = (List<Object>) obj_usdt;
                @SuppressWarnings("unchecked")
                List<Object> arr_busd = (List<Object>) obj_busd;

                BigDecimal price_open_candle = Utils.getBigDecimal(arr_usdt.get(1));
                BigDecimal price_high = Utils.getBigDecimal(arr_usdt.get(2));
                BigDecimal price_low = Utils.getBigDecimal(arr_usdt.get(3));
                BigDecimal price_close_candle = Utils.getBigDecimal(arr_usdt.get(4));
                String open_time = arr_usdt.get(0).toString();

                if (Objects.equals("0", open_time)) {
                    price_open_candle = Utils.getBigDecimal(arr_busd.get(1));
                    price_high = Utils.getBigDecimal(arr_busd.get(2));
                    price_low = Utils.getBigDecimal(arr_busd.get(3));
                    price_close_candle = Utils.getBigDecimal(arr_busd.get(4));

                    open_time = arr_busd.get(0).toString();
                }

                if (!Objects.equals("0", open_time)) {
                    BigDecimal avgPrice = price_open_candle;
                    if (price_open_candle.compareTo(price_close_candle) > 0) {
                        avgPrice = price_close_candle;
                    }

                    BigDecimal quote_asset_volume1 = Utils.getBigDecimal(arr_usdt.get(7));
                    BigDecimal number_of_trades1 = Utils.getBigDecimal(arr_usdt.get(8));

                    BigDecimal quote_asset_volume2 = Utils.getBigDecimal(arr_busd.get(7));
                    BigDecimal number_of_trades2 = Utils.getBigDecimal(arr_busd.get(8));

                    BigDecimal total_volume = quote_asset_volume1.add(quote_asset_volume2);
                    BigDecimal total_trans = number_of_trades1.add(number_of_trades2);

                    if (idx == limit - 1) {

                        Calendar calendar = Calendar.getInstance();

                        day.setId(new BinanceVolumnDayKey(gecko_id, symbol,
                                Utils.convertDateToString("HH", calendar.getTime())));
                        day.setTotalVolume(total_volume);
                        day.setTotalTrasaction(total_trans);
                        day.setPriceAtBinance(price_at_binance);
                        day.setLow_price(price_low);
                        day.setHight_price(price_high);
                        day.setPrice_open_candle(price_open_candle);
                        day.setPrice_close_candle(price_close_candle);

                        {
                            BinanceVolumeDateTime ddhh = new BinanceVolumeDateTime();
                            BinanceVolumeDateTimeKey key = new BinanceVolumeDateTimeKey();
                            key.setGeckoid(gecko_id);
                            key.setSymbol(symbol);
                            key.setDd(Utils.convertDateToString("dd", calendar.getTime()));
                            key.setHh(Utils.convertDateToString("HH", calendar.getTime()));
                            ddhh.setId(key);
                            ddhh.setVolume(total_volume);

                            binanceVolumeDateTimeRepository.save(ddhh);
                        }

                        // pump/dump
                        {
                            calendar.add(Calendar.HOUR_OF_DAY, -2);
                            BinanceVolumnDay pre2h = binanceVolumnDayRepository
                                    .findById(new BinanceVolumnDayKey(gecko_id, symbol,
                                            Utils.convertDateToString("HH", calendar.getTime())))
                                    .orElse(null);

                            if (!Objects.equals(null, pre2h) && (Utils.getBigDecimal(pre2h.getPriceAtBinance())
                                    .compareTo(BigDecimal.ZERO) > 0)) {

                                String str_pump_dump = "";
                                if (price_at_binance
                                        .compareTo(pre2h.getPriceAtBinance().multiply(BigDecimal.valueOf(1.1))) > 0) {

                                    str_pump_dump = " total_pump = total_pump + 1 ";

                                } else if (price_at_binance
                                        .compareTo(pre2h.getPriceAtBinance().multiply(BigDecimal.valueOf(0.9))) < 0) {

                                    str_pump_dump = " total_dump = total_dump + 1 ";
                                }

                                if (!Objects.equals("", str_pump_dump)) {
                                    sql_pump_dump = " WITH UPD AS (UPDATE binance_pumping_history SET " + str_pump_dump
                                            + " WHERE gecko_id='" + gecko_id + "' AND symbol='" + symbol
                                            + "' AND HH=TO_CHAR(NOW(), 'HH24') \n"
                                            + " RETURNING gecko_id, symbol, hh), \n" + " INS AS (SELECT '" + gecko_id
                                            + "', '" + symbol
                                            + "', TO_CHAR(NOW(), 'HH24'), 1, 1 WHERE NOT EXISTS (SELECT * FROM UPD)) \n"
                                            + " INSERT INTO binance_pumping_history(gecko_id, symbol, hh, total_pump, total_dump) SELECT * FROM INS; \n";
                                }
                            }
                        }

                    }

                    BinanceVolumnWeek entity = new BinanceVolumnWeek();
                    Calendar calendar_day = Calendar.getInstance();
                    calendar_day.add(Calendar.DAY_OF_MONTH, -day_index);
                    entity.setId(new BinanceVolumnWeekKey(gecko_id, symbol,
                            Utils.convertDateToString("yyyyMMdd", calendar_day.getTime())));
                    entity.setAvgPrice(avgPrice);
                    entity.setTotalVolume(total_volume);
                    entity.setTotalTrasaction(total_trans);
                    entity.setMin_price(price_low);
                    entity.setMax_price(price_high);
                    list_week.add(entity);

                    list_price_close_candle.add(avgPrice);
                }
                day_index += 1;
            }

            // https://www.omnicalculator.com/finance/rsi#:~:text=Calculate%20relative%20strength%20(RS)%20by,1%20%2D%20RS)%20from%20100.

            int size = list_week.size() - 1;
            if (size > 0) {
                binanceVolumnDayRepository.save(day);
                binanceVolumnWeekRepository.saveAll(list_week);
                if (!Objects.equals("", sql_pump_dump)) {
                    Query query = entityManager.createNativeQuery(sql_pump_dump);
                    query.executeUpdate();
                }
            }

            if ("BTC".contains(symbol.toUpperCase())) {
                saveDepthData(gecko_id, symbol);
            }

            return setCoinGlassData(gecko_id, symbol);

        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    private Boolean isHasData(List<Object> result_usdt, int index) {
        Object obj_usdt = result_usdt.get(index);

        @SuppressWarnings("unchecked")
        List<Object> arr_usdt = (List<Object>) obj_usdt;

        String open_time = arr_usdt.get(0).toString();

        if (Objects.equals("0", open_time)) {
            return false;
        }

        return true;
    }

    /**
     * https://fapi.coinglass.com/api/futures/longShortRate?symbol=BTC&timeType=3
     *
     * https://fapi.coinglass.com/api/tradingData/accountLSRatio?symbol=BTC&exName=Okex&type=-1&timeType=3
     * https://fapi.coinglass.com/api/tradingData/accountLSRatio?symbol=BTC&exName=Huobi&type=1&timeType=3
     *
     */
    @SuppressWarnings("unchecked")
    private String setCoinGlassData(String gecko_id, String symbol) {
        boolean exit = true;
        if (exit) {
            return "";
        }

        String url = "https://fapi.coinglass.com/api/tradingData/accountLSRatio?symbol=" + symbol.toUpperCase()
                + "&exName=Binance&type=1&timeType=3";

        /*
         *
         * https://fapi.coinglass.com/api/tradingData/accountLSRatio?symbol=BTC&exName=
         * Binance&type=1&timeType=3
         * https://fapi.coinglass.com/api/tradingData/positionLSRatio?symbol=BTC&exName=
         * Binance&type=1&timeType=3
         */
        BigDecimal topTraderBinanceLongRate = BigDecimal.ZERO;

        List<String> list = new ArrayList<String>();
        try {
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            Object longRatioList = Utils.getLinkedHashMapValue(result, Arrays.asList("data", "longRatioList"));
            Object shortRatioList = Utils.getLinkedHashMapValue(result, Arrays.asList("data", "shortRatioList"));
            Object longShortRatioList = Utils.getLinkedHashMapValue(result,
                    Arrays.asList("data", "longShortRatioList"));
            // Object dateList = Utils.getLinkedHashMapValue(result, Arrays.asList("data",
            // "dateList"));

            if (longRatioList instanceof Collection) {
                List<Double> longRatioList2 = new ArrayList<>((Collection<Double>) longRatioList);
                List<Double> shortRatioList2 = new ArrayList<>((Collection<Double>) shortRatioList);
                List<Double> longShortRatioList2 = new ArrayList<>((Collection<Double>) longShortRatioList);

                if (longRatioList2.size() > 0) {
                    int index = longRatioList2.size() - 1;

                    // List<String> dateList2 = new ArrayList<>((Collection<String>) dateList);
                    // String abc = String.valueOf(dateList2.get(index));
                    // Date date = Utils.getDate(abc);
                    // String str_date = Utils.convertDateToString("HH:mm", date);

                    double longShortRatio = longShortRatioList2.get(index);
                    topTraderBinanceLongRate = Utils.getBigDecimal(longRatioList2.get(index));

                    String msg = "";
                    if (longShortRatio > 1) {
                        msg += "Long:" + String.valueOf(longRatioList2.get(index)) + "%";
                    } else {
                        msg += "Short:" + String.valueOf(shortRatioList2.get(index)) + "%";
                    }

                    // log.info("End getCoinGlassData <--");
                    msg = "(" + msg + ")";
                    list.add(msg);

                    String css = "";

                    if (msg.contains("Short:")) {
                        css = "text-danger";
                    } else {
                        css = "text-primary";
                        if (longRatioList2.get(index) < 60) {
                            css = "";
                        }
                    }

                    if (longRatioList2.get(index) > 71) {
                        css += " font-weight-bold";
                    }
                    list.add(css);
                }
            }

            if (CollectionUtils.isEmpty(list)) {
                list.add("(Futures)");
                list.add("");
            }

            String futuresMsg = symbol + " " + list.get(0);
            String futuresCss = list.get(1);

            BinanceFutures entity = binanceFuturesRepository.findById(gecko_id).orElse(null);
            if (!Objects.equals(null, entity)) {
                entity.setFuturesMsg(futuresMsg);
                entity.setFuturesCss(futuresCss);
                entity.setTopTraderBinanceLongRate(topTraderBinanceLongRate);

                binanceFuturesRepository.save(entity);
            }

            return futuresMsg;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return "";
    }

    @SuppressWarnings({ "unchecked" })
    @Transactional
    private void saveDepthData(String gecko_id, String symbol) {
        try {

            List<DepthBids> depthBidsList = depthBidsRepository.findAll();
            for (DepthBids entity : depthBidsList) {
                entity.setQty(BigDecimal.ZERO);
            }
            depthBidsRepository.saveAll(depthBidsList);

            List<DepthAsks> depthAsksList = depthAsksRepository.findAll();
            for (DepthAsks entity : depthAsksList) {
                entity.setQty(BigDecimal.ZERO);
            }
            depthAsksRepository.saveAll(depthAsksList);

            BigDecimal MIL_VOL = BigDecimal.valueOf(1000);
            if ("BTC".equals(symbol.toUpperCase())) {
                MIL_VOL = BigDecimal.valueOf(10000);
            }

            String url = "https://api.binance.com/api/v3/depth?limit=5000&symbol=" + symbol.toUpperCase() + "USDT";

            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);

            Object obj_bids = Utils.getLinkedHashMapValue(result, Arrays.asList("bids"));
            Object obj_asks = Utils.getLinkedHashMapValue(result, Arrays.asList("asks"));

            if (obj_bids instanceof Collection) {
                List<Object> obj_bids2 = new ArrayList<>((Collection<Object>) obj_bids);
                List<DepthBids> saveList = new ArrayList<DepthBids>();
                BigInteger rowidx = BigInteger.ZERO;
                for (Object obj : obj_bids2) {
                    List<Double> bids = new ArrayList<>((Collection<Double>) obj);
                    BigDecimal price = Utils.getBigDecimalValue(String.valueOf(bids.get(0)));
                    BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(bids.get(1)));

                    BigDecimal volume = price.multiply(qty);
                    if (volume.compareTo(MIL_VOL) < 0) {
                        continue;
                    }

                    DepthBids entity = new DepthBids();
                    rowidx = rowidx.add(BigInteger.valueOf(1));
                    entity.setGeckoId(gecko_id);
                    entity.setSymbol(symbol);
                    entity.setPrice(price);
                    entity.setRowidx(rowidx);
                    entity.setQty(qty);
                    saveList.add(entity);

                }
                depthBidsRepository.saveAll(saveList);
            }

            if (obj_asks instanceof Collection) {
                List<Object> obj_asks2 = new ArrayList<>((Collection<Object>) obj_asks);
                List<DepthAsks> saveList = new ArrayList<DepthAsks>();
                BigInteger rowidx = BigInteger.ZERO;
                for (Object obj : obj_asks2) {
                    List<Double> asks = new ArrayList<>((Collection<Double>) obj);
                    BigDecimal price = Utils.getBigDecimalValue(String.valueOf(asks.get(0)));
                    BigDecimal qty = Utils.getBigDecimalValue(String.valueOf(asks.get(1)));

                    BigDecimal volume = price.multiply(qty);
                    if (volume.compareTo(MIL_VOL) < 0) {
                        continue;
                    }

                    DepthAsks entity = new DepthAsks();
                    rowidx = rowidx.add(BigInteger.valueOf(1));
                    entity.setGeckoId(gecko_id);
                    entity.setSymbol(symbol);
                    entity.setPrice(price);
                    entity.setRowidx(rowidx);
                    entity.setQty(qty);
                    saveList.add(entity);
                }
                depthAsksRepository.saveAll(saveList);
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    // 1: all, 2: bids, 3: asks
    private List<DepthResponse> getDepthDataBtc(int type) {
        try {
            if (depthBidsRepository.count() < 1) {
                return new ArrayList<DepthResponse>();
            }

            String view = "view_btc_depth";
            String orderby = "price ASC ";
            if (type == 2) {
                view = "view_btc_depth_bids";
                orderby = "price DESC ";
            }
            if (type == 3) {
                view = "view_btc_depth_asks";
                orderby = "price ASC ";
            }

            String sql = "SELECT                                                                                  \n"
                    + "    gecko_id,                                                                              \n"
                    + "    symbol,                                                                                \n"
                    + "    price,                                                                                 \n"
                    + "    qty,                                                                                   \n"
                    + "    val_million_dolas                                                                      \n"
                    + "FROM " + view + "                                                                          \n"
                    + "WHERE val_million_dolas > 0                                                                \n"
                    + "ORDER BY " + orderby;

            Query query = entityManager.createNativeQuery(sql, "DepthResponse");

            @SuppressWarnings("unchecked")
            List<DepthResponse> list = query.getResultList();

            return list;

        } catch (Exception e) {
            e.printStackTrace();
        }

        return new ArrayList<DepthResponse>();
    }

    @Override
    @Transactional
    public List<List<DepthResponse>> getListDepthData(String symbol) {
        List<List<DepthResponse>> result = new ArrayList<List<DepthResponse>>();

        // BTC
        if (symbol.toUpperCase().equals("BTC")) {
            saveDepthData("bitcoin", "BTC");
            List<DepthResponse> list_bids = getDepthDataBtc(2);
            List<DepthResponse> list_asks = getDepthDataBtc(3);

            list_bids_ok = new ArrayList<DepthResponse>();
            list_asks_ok = new ArrayList<DepthResponse>();

            BigDecimal wall = BigDecimal.valueOf(2);
            BigDecimal total_bids = BigDecimal.ZERO;
            for (DepthResponse dto : list_bids) {
                BigDecimal price = dto.getPrice();
                BigDecimal val = dto.getVal_million_dolas();

                if (val.compareTo(wall) < 0) {
                    total_bids = total_bids.add(val);
                }

                if (val.compareTo(wall) >= 0) {
                    DepthResponse real_wall = new DepthResponse();
                    real_wall.setPrice(price);
                    real_wall.setVal_million_dolas(total_bids);
                    list_bids_ok.add(real_wall);
                }

                dto.setPrice(price);
                list_bids_ok.add(dto);
            }

            BigDecimal total_asks = BigDecimal.ZERO;
            for (DepthResponse dto : list_asks) {
                BigDecimal price = dto.getPrice();
                BigDecimal val = dto.getVal_million_dolas();

                if (val.compareTo(wall) < 0) {
                    total_asks = total_asks.add(val);
                }

                if (val.compareTo(wall) >= 0) {
                    DepthResponse real_wall = new DepthResponse();
                    real_wall.setPrice(price);
                    real_wall.setVal_million_dolas(total_asks);
                    list_asks_ok.add(real_wall);
                }

                dto.setPrice(price);
                list_asks_ok.add(dto);
            }

            result.add(list_bids_ok);
            result.add(list_asks_ok);
            return result;
        }

        // Others
        try {
            List<BinanceVolumnDay> temp = binanceVolumnDayRepository.searchBySymbol(symbol);
            if (CollectionUtils.isEmpty(temp)) {
                return new ArrayList<List<DepthResponse>>();
            }

            String geckoId = temp.get(0).getId().getGeckoid();
            saveDepthData(geckoId, symbol.toUpperCase());

            String sql_bids = "                                                                                          \n"
                    + " select * from (                                                                             \n"

                    + "SELECT                                                                                       \n"
                    + "    gecko_id,                                                                                \n"
                    + "    symbol,                                                                                  \n"
                    + "    price,                                                                                   \n"
                    + "    qty,                                                                                     \n"
                    + "    round(price * qty / 1000, 1) as val_million_dolas                                        \n"
                    + "FROM                                                                                         \n"
                    + "    depth_bids                                                                               \n"
                    + "WHERE gecko_id = '" + geckoId + "'                                                           \n"
                    + " ) depth where depth.val_million_dolas > 10   ORDER BY price ASC                             \n";

            String sql_asks = "                                                                                     \n"
                    + " select * from (                                                                             \n"

                    + "SELECT                                                                                       \n"
                    + "    gecko_id,                                                                                \n"
                    + "    symbol,                                                                                  \n"
                    + "    price,                                                                                   \n"
                    + "    qty,                                                                                     \n"
                    + "    round(price * qty / 1000, 1) as val_million_dolas                                        \n"
                    + "FROM                                                                                         \n"
                    + "    depth_asks                                                                               \n"
                    + "WHERE gecko_id = '" + geckoId + "'                                                           \n"

                    + " ) depth where depth.val_million_dolas > 10   ORDER BY price DESC                            \n";

            Query query = entityManager.createNativeQuery(sql_bids, "DepthResponse");
            @SuppressWarnings("unchecked")
            List<DepthResponse> list_bids = query.getResultList();

            query = entityManager.createNativeQuery(sql_asks, "DepthResponse");
            @SuppressWarnings("unchecked")
            List<DepthResponse> list_asks = query.getResultList();

            List<DepthResponse> list_bids_ok = new ArrayList<DepthResponse>();
            BigDecimal wall = BigDecimal.valueOf(2);
            BigDecimal total_bids = BigDecimal.ZERO;
            for (DepthResponse dto : list_bids) {
                BigDecimal price = Utils.getBigDecimalValue(Utils.removeLastZero(String.valueOf(dto.getPrice())));
                BigDecimal val = dto.getVal_million_dolas();

                if (val.compareTo(wall) < 0) {
                    total_bids = total_bids.add(val);
                }

                if (val.compareTo(wall) >= 0) {
                    DepthResponse real_wall = new DepthResponse();
                    real_wall.setPrice(BigDecimal.valueOf(99999));
                    real_wall.setVal_million_dolas(total_bids);
                    list_bids_ok.add(real_wall);
                }

                dto.setPrice(price);
                list_bids_ok.add(dto);
            }

            List<DepthResponse> list_asks_ok = new ArrayList<DepthResponse>();
            for (DepthResponse dto : list_asks) {
                dto.setPrice(Utils.getBigDecimalValue(Utils.removeLastZero(String.valueOf(dto.getPrice()))));
                list_asks_ok.add(dto);
            }

            result.add(list_bids_ok);
            result.add(list_asks_ok);
            return result;
        } catch (Exception e) {
            e.printStackTrace();
        }

        return result;
    }

    @Override
    @Transactional
    public String getTextDepthData() {
        BigDecimal price_now = Utils.getBinancePrice(SYMBOL_BTC);
        saveDepthData("bitcoin", "BTC");

        String result = "";

        List<DepthResponse> list = getDepthDataBtc(1);

        if (!CollectionUtils.isEmpty(list)) {
            Boolean isAddPriceNow = false;

            for (DepthResponse dto : list) {

                if (!isAddPriceNow) {
                    if (dto.getPrice().compareTo(price_now) > 0) {
                        result += "< NOW >";
                        isAddPriceNow = true;
                    }
                }

                result += dto.toStringMillion(price_now);
            }
        }

        return result.trim();
    }

    public BtcFuturesResponse getBtcFuturesResponse(String symbol, String TIME) {
        String str_id = "'" + symbol + "_" + TIME + "_%'";
        String header = symbol + "_" + TIME + "_";

        String sql = "SELECT                                                                                            \n"
                + "    (SELECT min(low_price) FROM btc_futures WHERE id like " + str_id + ") AS low_price_h, \n"
                + "    (SELECT                                                                                          \n"
                + "        ROUND(AVG(COALESCE(open_price, 0)), 0) open_candle                                           \n"
                + "    FROM(                                                                                            \n"
                + "        SELECT open_price                                                                            \n"
                + "        FROM                                                                                         \n"
                + "        (                                                                                            \n"
                + "            SELECT case when uptrend then price_open_candle else price_close_candle end as open_price \n"
                + "                  FROM btc_futures WHERE id like" + str_id + "  \n"
                + "        ) low_candle1                                                                                \n"
                + "        ORDER BY open_price asc limit 5                                                              \n"
                + "    ) low_candle) open_candle_h                                                                      \n"
                + "    ,                                                                                                \n"
                + "    (SELECT ROUND(AVG(COALESCE(close_price, 0)), 0) open_candle                                      \n"
                + "     FROM(                                                                                           \n"
                + "        SELECT close_price                                                                           \n"
                + "        FROM                                                                                         \n"
                + "        (                                                                                            \n"
                + "            SELECT case when uptrend then price_close_candle else price_open_candle end as close_price \n"
                + "              FROM btc_futures WHERE id like " + str_id + " \n"
                + "        ) close_candle1                                                                              \n"
                + "        ORDER BY close_price desc limit 5                                                            \n"
                + "    ) close_candle) close_candle_h,                                                                  \n"
                + "    (SELECT max(hight_price) FROM btc_futures WHERE id like " + str_id + ")   AS hight_price_h, \n"
                + "                                                                                                     \n"
                + "    (                                                                                                \n"
                + "        SELECT id as id_half1                                                                        \n"
                + "         FROM btc_futures WHERE id like " + str_id + " and id < '" + header + "24' \n"
                + "        ORDER BY (case when uptrend then price_open_candle else price_close_candle end) asc limit 1  \n"
                + "    )  as id_half1,                                                                                  \n"
                + "    (                                                                                                \n"
                + "        SELECT case when uptrend then price_open_candle else price_close_candle end as open_price_half1 \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id < '" + header + "24' \n"
                + "        ORDER BY open_price_half1 asc limit 1                                                        \n"
                + "    )  as open_price_half1,                                                                          \n"
                + "    (                                                                                                \n"
                + "        SELECT id as id_half2                                                                        \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id >= '" + header + "24' \n"
                + "        ORDER BY (case when uptrend then price_open_candle else price_close_candle end) asc limit 1  \n"
                + "    )  as id_half2,                                                                                  \n"
                + "    (                                                                                                \n"
                + "        SELECT case when uptrend then price_open_candle else price_close_candle end as open_price_half2 \n"
                + "          FROM btc_futures WHERE id like " + str_id + " and id >= '" + header + "24' \n"
                + "        ORDER BY open_price_half2 asc limit 1                                                        \n"
                + "    )  as open_price_half2                                                                           \n";

        Query query = entityManager.createNativeQuery(sql, "BtcFuturesResponse");

        @SuppressWarnings("unchecked")
        List<BtcFuturesResponse> vol_list = query.getResultList();
        if (CollectionUtils.isEmpty(vol_list)) {
            return null;
        }

        BtcFuturesResponse dto = vol_list.get(0);
        if (Objects.equals(null, dto.getLow_price_h())) {
            return null;
        }
        return dto;
    }

    @SuppressWarnings("unchecked")
    @Override
    @Transactional
    public List<String> monitorBtcPrice() {
        String time = Utils.convertDateToString("(hh:mm)", Calendar.getInstance().getTime());

        if (Objects.equals(time, pre_monitorBtcPrice_mm)) {
            return monitorBtcPrice_results;
        }
        pre_monitorBtcPrice_mm = time;

        List<String> results = new ArrayList<String>();
        monitorBtcPrice_results = new ArrayList<String>();

        int HH = Utils.getIntValue(Utils.convertDateToString("HH", Calendar.getInstance().getTime()));
        String curr_time_of_btc = Utils.convertDateToString("MMdd_HHmm", Calendar.getInstance().getTime());
        curr_time_of_btc = curr_time_of_btc.substring(0, curr_time_of_btc.length() - 1);
        String curr_time_of_btc_pre10m = String.valueOf(curr_time_of_btc);
        String curr_time_of_btc_pre1h = curr_time_of_btc.substring(0, curr_time_of_btc.length() - 1);

        try {
            log.info(time + " Start monitorBtcPrice ---->");
            List<BtcFutures> btc1hs = Utils.loadData("BTC", TIME_1h, LIMIT_DATA_1h);
            btcFuturesRepository.saveAll(btc1hs);

            BigDecimal price_at_binance = btc1hs.get(0).getCurrPrice();

            // https://www.binance.com/en-GB/futures/funding-history/3
            //
            {
                String url = "https://www.binance.com/fapi/v1/marketKlines?interval=15m&limit=1&symbol=pBTCUSDT";
                List<Object> funding_rate_objs = Utils.getBinanceData(url, 1);
                if (!CollectionUtils.isEmpty(funding_rate_objs)) {

                    Object obj = funding_rate_objs.get(0);
                    List<Object> arr_ = (List<Object>) obj;

                    if (!CollectionUtils.isEmpty(arr_)) {
                        // BigDecimal open = Utils.getBigDecimal(arr_.get(1));
                        BigDecimal high = Utils.getBigDecimal(arr_.get(2)).multiply(BigDecimal.valueOf(100));
                        BigDecimal low = Utils.getBigDecimal(arr_.get(3)).multiply(BigDecimal.valueOf(100));
                        // BigDecimal close = Utils.getBigDecimal(arr_.get(4));

                        if (high.compareTo(BigDecimal.valueOf(0.5)) > 0) {

                            getListDepthData("BTC");
                            String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_asks_ok);

                            Utils.sendToTelegram("(DANGER DANGER) CZ kill SHORT !!! Wait 3~5 minutes."
                                    + Utils.new_line_from_service + "(Sell wall) " + wall);

                        } else if (high.compareTo(BigDecimal.valueOf(0.2)) > 0) {

                            getListDepthData("BTC");
                            String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_asks_ok);

                            Utils.sendToTelegram("(DANGER) CZ kill SHORT !!! Wait 3~5 minutes."
                                    + Utils.new_line_from_service + "(Sell wall) " + wall);
                            // Utils.sendToTelegram("https://www.binance.com/en-GB/futures/funding-history/3");
                        }

                        if (low.compareTo(BigDecimal.valueOf(-1)) < 0) {

                            getListDepthData("BTC");
                            String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_bids_ok);

                            Utils.sendToTelegram("(DANGER DANGER DANGER) CZ kill LONG !!! Wait 3~5 minutes."
                                    + Utils.new_line_from_service + "(Buy wall) " + wall);
                            // Utils.sendToTelegram("https://www.binance.com/en-GB/futures/funding-history/3");

                        } else if (low.compareTo(BigDecimal.valueOf(-0.5)) < 0) {

                            getListDepthData("BTC");
                            String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_bids_ok);

                            Utils.sendToTelegram("(DANGER DANGER) CZ kill LONG !!! Wait 3~5 minutes."
                                    + Utils.new_line_from_service + "(Buy wall) " + wall);

                        } else if (low.compareTo(BigDecimal.valueOf(-0.2)) < 0) {

                            getListDepthData("BTC");
                            String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_bids_ok);

                            Utils.sendToTelegram("(DANGER) CZ kill LONG !!! Wait 3~5 minutes."
                                    + Utils.new_line_from_service + "(Buy wall) " + wall);
                            // Utils.sendToTelegram("https://www.binance.com/en-GB/futures/funding-history/3");

                        }

                        // MyTelegram
                        {
                            if (!Objects.equals(String.valueOf(low), pre_funding_rate_low)) {
                                if (low.compareTo(BigDecimal.valueOf(-0.2)) < 0) {

                                    getListDepthData("BTC");
                                    String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_bids_ok);

                                    pre_funding_rate_low = String.valueOf(low);

                                    Utils.sendToMyTelegram(time + " (DANGER) CZ kill Long !!! Wait 3~5 minutes."
                                            + Utils.new_line_from_service + "(Buy wall) " + wall);

                                } else if (low.compareTo(BigDecimal.valueOf(-0.12)) < 0) {
                                    pre_funding_rate_low = String.valueOf(low);

                                    getListDepthData("BTC");
                                    String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_bids_ok);

                                    Utils.sendToMyTelegram(time + " (" + pre_funding_rate_low
                                            + ") Wait 3~5 minutes." + Utils.new_line_from_service
                                            + "(Sell wall) " + wall);
                                }
                            }

                            if (!Objects.equals(String.valueOf(high), pre_funding_rate_high)) {
                                if (high.compareTo(BigDecimal.valueOf(0.2)) > 0) {
                                    pre_funding_rate_high = String.valueOf(high);

                                    getListDepthData("BTC");
                                    String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_asks_ok);

                                    Utils.sendToMyTelegram(time + " (Sell wall) CZ kill Short !!! wait 3~5 minutes."
                                            + Utils.new_line_from_service + wall);

                                } else if (high.compareTo(BigDecimal.valueOf(0.02)) > 0) {
                                    pre_funding_rate_high = String.valueOf(high);

                                    getListDepthData("BTC");
                                    String wall = Utils.getNextBidsOrAsksWall(price_at_binance, list_asks_ok);

                                    Utils.sendToMyTelegram(time + " (" + pre_funding_rate_high
                                            + ") Wait 3~5 minutes" + Utils.new_line_from_service
                                            + "(Sell wall) " + wall);
                                }
                            }
                        }

                    }
                }
            }

            String hh = Utils.convertDateToString("HH", Calendar.getInstance().getTime());
            if (!Objects.equals(hh, pre_time_of_saved_data_4h)) {
                List<BtcFutures> btc4hs = Utils.loadData("BTC", TIME_4h, LIMIT_DATA_4h);
                btcFuturesRepository.saveAll(btc4hs);
                pre_time_of_saved_data_4h = hh;
            }

            BtcFuturesResponse dto_1h = getBtcFuturesResponse("BTC", TIME_1h);
            if (Objects.equals(null, dto_1h)) {
                return results;
            }
            BtcFuturesResponse dto_10d = getBtcFuturesResponse("BTC", TIME_4h);
            if (Objects.equals(null, dto_10d)) {
                return results;
            }

            BigDecimal entry0 = Utils.getNextEntry(dto_1h);
            String trend = Utils.checkTrend(dto_1h);
            boolean isUptrend = trend.contains("1");
            boolean isDowntrend = trend.contains("2");
            boolean isSideway = trend.contains("3");

            BigDecimal good_price_for_long = Utils.getGoodPriceLongByPercent(price_at_binance, dto_1h.getLow_price_h(),
                    dto_1h.getOpen_candle_h(), BigDecimal.valueOf(1));

            BigDecimal good_price_for_short = Utils.getGoodPriceShortByPercent(price_at_binance,
                    dto_1h.getHight_price_h(), dto_1h.getClose_candle_h(), BigDecimal.valueOf(1));

            String msg = time;

            String low_height = Utils.getMsgLowHeight(price_at_binance, dto_10d);
            low_height += " " + Utils.new_line_from_service;
            low_height += "10d" + Utils.new_line_from_service + Utils.getMsgLowHeight(price_at_binance, dto_10d);

            if (isUptrend) {
                msg += " Uptrend... " + " BTC: " + Utils.removeLastZero(String.valueOf(price_at_binance)) + "$";
                if (Utils.isGoodPriceLong(price_at_binance, dto_1h.getLow_price_h(), dto_1h.getHight_price_h())) {
                    msg += " (Good)";
                }
                msg += Utils.new_line_from_service;
                msg += low_height;
                results.add(Utils.getStringValue(msg));

                results.add("(Long*)" + Utils.new_line_from_service + Utils.getMsgLong(good_price_for_long, dto_1h));
                results.add("(Long now)" + Utils.new_line_from_service + Utils.getMsgLong(price_at_binance, dto_1h));

                if (!Objects.equals(null, entry0)) {
                    results.add("(Long**)" + Utils.new_line_from_service + Utils.getMsgShort(entry0, dto_1h));
                } else {
                    results.add(
                            "(Short*)" + Utils.new_line_from_service + Utils.getMsgShort(good_price_for_short, dto_1h));
                }
                results.add("(Short now)" + Utils.new_line_from_service + Utils.getMsgShort(price_at_binance, dto_1h));
            }

            if (isDowntrend) {
                msg += " Downtrend... " + " BTC: " + Utils.removeLastZero(String.valueOf(price_at_binance)) + "$";
                if (Utils.isGoodPriceShort(price_at_binance, dto_1h.getOpen_candle_h(), dto_1h.getClose_candle_h())) {
                    msg += " (Good)";
                }
                msg += Utils.new_line_from_service;
                msg += low_height;
                results.add(Utils.getStringValue(msg));

                results.add("(Short*)" + Utils.new_line_from_service + Utils.getMsgShort(good_price_for_short, dto_1h));
                results.add("(Short now)" + Utils.new_line_from_service + Utils.getMsgShort(price_at_binance, dto_1h));

                results.add("(Long*)" + Utils.new_line_from_service + Utils.getMsgLong(good_price_for_long, dto_1h));
                results.add("(Long now)" + Utils.new_line_from_service + Utils.getMsgLong(price_at_binance, dto_1h));
            }

            if (isSideway) {
                msg = time + " Btc sideway" + Utils.new_line_from_service + low_height;
                results.add(Utils.getStringValue(msg));

                results.add("(Long now)" + Utils.new_line_from_service + Utils.getMsgLong(price_at_binance, dto_1h));
                results.add("(Short now)" + Utils.new_line_from_service + Utils.getMsgShort(price_at_binance, dto_1h));

                results.add("(Long*)" + Utils.new_line_from_service + Utils.getMsgLong(good_price_for_long, dto_1h));
                results.add("(Short*)" + Utils.new_line_from_service + Utils.getMsgShort(good_price_for_short, dto_1h));
            }

            // (Good time to buy)
            if (!Objects.equals(curr_time_of_btc, pre_time_of_btc_for_long_short) && (HH % 4 == 0)) {
                if (price_at_binance.compareTo(good_price_for_long) <= 0) {

                    Utils.sendToTelegram(
                            "(Long)" + Utils.new_line_from_service + Utils.getMsgLong(price_at_binance, dto_1h));

                    pre_time_of_btc_for_long_short = curr_time_of_btc;
                }

                if (price_at_binance.compareTo(good_price_for_short) > 0) {

                    Utils.sendToTelegram(
                            "(Short)" + Utils.new_line_from_service + Utils.getMsgShort(price_at_binance, dto_1h));
                    pre_time_of_btc_for_long_short = curr_time_of_btc;
                }
            }

            // kill long/short 10m
            if (!Objects.equals(curr_time_of_btc_pre10m, pre_time_of_btc_kill_long_short)) {
                if (price_at_binance.compareTo(dto_1h.getLow_price_h()) <= 0) {
                    Utils.sendToTelegram("CZ kill LONG !!!");
                    pre_time_of_btc_kill_long_short = curr_time_of_btc_pre10m;
                }

                if (price_at_binance.compareTo(dto_1h.getHight_price_h()) >= 0) {
                    // kill short: loss 30$ 2022/09/09
                    Utils.sendToTelegram("CZ kill SHORT !!!");
                    pre_time_of_btc_kill_long_short = curr_time_of_btc_pre10m;
                }
            }

            // (10d)
            if (!Objects.equals(curr_time_of_btc_pre1h, pre_time_of_btc_msg_1h) && (HH % 4 == 0)) {
                if (price_at_binance.compareTo(dto_10d.getOpen_candle_h()) <= 0) {
                    Utils.sendToTelegram("(Bitcoin bottomed in 10d)" + Utils.new_line_from_service + "(LONG)"
                            + Utils.new_line_from_service + Utils.getMsgLong(dto_10d.getLow_price_h(), dto_10d));

                    pre_time_of_btc_msg_1h = curr_time_of_btc_pre1h;
                }

                if (price_at_binance.compareTo(dto_10d.getClose_candle_h()) >= 0) {
                    Utils.sendToTelegram("(Bitcoin hits 10d peak)" + Utils.new_line_from_service + "(Short)"
                            + Utils.new_line_from_service + Utils.getMsgShort(dto_10d.getHight_price_h(), dto_10d));

                    pre_time_of_btc_msg_1h = curr_time_of_btc_pre1h;
                }
            }

            monitorBtcPrice_results = new ArrayList<>(results);
            return results;

        } catch (

        Exception e) {
            e.printStackTrace();
        }

        return results;
    }

    @SuppressWarnings({ "rawtypes", "unchecked" })
    @Transactional
    private String monitorBitcoinBalancesOnExchanges() {

        log.info("Start monitorBitcoinBalancesOnExchanges ---->");
        String url = "https://fapi.coinglass.com/api/exchange/chain/balance/list";

        try {
            RestTemplate restTemplate = new RestTemplate();
            Object result = restTemplate.getForObject(url, Object.class);
            Object dataList = Utils.getLinkedHashMapValue(result, Arrays.asList("data"));

            if (dataList instanceof Collection) {
                List<LinkedHashMap> exchangeList = new ArrayList<>((Collection<LinkedHashMap>) dataList);

                if (exchangeList.size() > 0) {

                    String yyyyMMdd = Utils.convertDateToString("yyyyMMdd", Calendar.getInstance().getTime());
                    List<BitcoinBalancesOnExchanges> entities = new ArrayList<BitcoinBalancesOnExchanges>();

                    for (LinkedHashMap exchange : exchangeList) {

                        Object exchangeName = Utils.getLinkedHashMapValue(exchange, Arrays.asList("exchangeName"));
                        Object symbol = Utils.getLinkedHashMapValue(exchange, Arrays.asList("symbol"));
                        Object balance = Utils.getLinkedHashMapValue(exchange, Arrays.asList("balance"));

                        Object balanceChange = Utils.getLinkedHashMapValue(exchange, Arrays.asList("balanceChange"));
                        Object balanceChangePercent = Utils.getLinkedHashMapValue(exchange,
                                Arrays.asList("balanceChangePercent"));

                        Object d7BalanceChange = Utils.getLinkedHashMapValue(exchange,
                                Arrays.asList("d7BalanceChange"));
                        Object d7BalanceChangePercent = Utils.getLinkedHashMapValue(exchange,
                                Arrays.asList("d7BalanceChangePercent"));

                        Object d30BalanceChange = Utils.getLinkedHashMapValue(exchange,
                                Arrays.asList("d30BalanceChange"));
                        Object d30BalanceChangePercent = Utils.getLinkedHashMapValue(exchange,
                                Arrays.asList("d30BalanceChangePercent"));
                        Object exLogo = Utils.getLinkedHashMapValue(exchange, Arrays.asList("exLogo"));

                        BitcoinBalancesOnExchanges entity = new BitcoinBalancesOnExchanges();
                        BitcoinBalancesOnExchangesKey id = new BitcoinBalancesOnExchangesKey();
                        id.setYyyymmdd(yyyyMMdd);
                        id.setExchangeName(Utils.getStringValue(exchangeName));
                        id.setSymbol(Utils.getStringValue(symbol));

                        entity.setId(id);
                        entity.setBalance(Utils.getBigDecimal(balance));
                        entity.setBalanceChange(Utils.getBigDecimal(balanceChange));
                        entity.setBalanceChangePercent(Utils.getBigDecimal(balanceChangePercent));
                        entity.setD7BalanceChange(Utils.getBigDecimal(d7BalanceChange));
                        entity.setD7BalanceChangePercent(Utils.getBigDecimal(d7BalanceChangePercent));
                        entity.setD30BalanceChange(Utils.getBigDecimal(d30BalanceChange));
                        entity.setD30BalanceChangePercent(Utils.getBigDecimal(d30BalanceChangePercent));
                        entity.setExLogo(Utils.getStringValue(exLogo));

                        entities.add(entity);
                    }

                    bitcoinBalancesOnExchangesRepository.saveAll(entities);
                }
            }

            log.info("Start getBtcBalancesOnExchanges ---->");

            String sql = " SELECT                                                                                   \n"
                    + "  fun_btc_price_now()                                              as price_now              \n"
                    + ", sum(balance_change)                                              as change_24h             \n"
                    + ", round(sum(balance_change) * fun_btc_price_now() / 1000000, 0)    as change_24h_val_million \n"
                    + ", sum(d7_balance_change)                                           as change_7d              \n"
                    + ", round(sum(d7_balance_change) * fun_btc_price_now() / 1000000, 0) as change_7d_val_million  \n"
                    + " FROM bitcoin_balances_on_exchanges                                                          \n"
                    + " WHERE                                                                                       \n"
                    + " yyyymmdd='" + Utils.convertDateToString("yyyyMMdd", Calendar.getInstance().getTime()) + "'";

            Query query = entityManager.createNativeQuery(sql, "BitcoinBalancesOnExchangesResponse");

            List<BitcoinBalancesOnExchangesResponse> vol_list = query.getResultList();
            if (CollectionUtils.isEmpty(vol_list)) {
                return "";
            }

            BitcoinBalancesOnExchangesResponse dto = vol_list.get(0);

            String msg = "BTC 24h: " + dto.getChange_24h() + "btc(" + dto.getChange_24h_val_million() + "m$)"
                    + Utils.new_line_from_service;

            msg += " 07d: " + dto.getChange_7d() + "btc(" + dto.getChange_7d_val_million() + "m$)";

            return msg;

        } catch (Exception e) {
            e.printStackTrace();
        }
        return "";
    }

    @Override
    public String getBtcBalancesOnExchanges() {
        int HH = Utils.getCurrentHH();
        if (HH != pre_monitorBitcoinBalancesOnExchanges_HH) {
            monitorBitcoinBalancesOnExchanges_temp = monitorBitcoinBalancesOnExchanges();
            pre_monitorBitcoinBalancesOnExchanges_HH = HH;
            return monitorBitcoinBalancesOnExchanges_temp;
        } else {
            return monitorBitcoinBalancesOnExchanges_temp;
        }
    }

    // ra vao toi da 1h, char 5m, target 3%
    // Xu huong gia, vi tri nen, boll
    // 1d: xet 2 cay nen, dang xu huong tang,

    /*
     * / I. nen 1D, gia hien tai thap hon 5% gia trung binh (5*) hnay: xanh, hqua
     * xanh; gia hien tai hnay > gia dong cua hqua.
     *
     * (3*) hqua xanh, hnay do hnay dang hoi: rau dai (rau > 2 lan than nen), than
     * ngan, gia hien tai hnay > 50% chieu dai than nen hqua.
     *
     * (1*) hqua do, hnay xanh gia hien tai hom nay > gia cao nhat cua hqua
     *
     *
     * II. Nen 4h hien tai bat buoc phai xanh. Loai truong hop sap cham AVG hoac BEL
     * tren. cach bel > 5% or cach AVG > 5%. Chu y gio dong cua cay nen 4h.
     *
     * (5*) Cay nen truoc Xanh
     *
     * (3*) Cay nen truoc la do, dang co xu huong hoi len.
     *
     * III. Nen 1h, xu huong tang, gia hien tai cach bel > 5% or cach AVG > 5%.
     *
     * IV. 30m dang xu huong tang /
     */
    @Transactional
    public void scalping(String gecko_id, String symbol) {
        try {
            BinanceFutures entity = binanceFuturesRepository.findById(gecko_id).orElse(null);

            if (!Objects.equals(null, entity)) {
                entity.setScalpingToday(false);
                binanceFuturesRepository.save(entity);
            }
            // Check 4h hien tai bat buoc phai xanh.
            List<BtcFutures> list_4h = Utils.loadData(symbol, TIME_4h, 1);
            if (CollectionUtils.isEmpty(list_4h)) {
                return;
            }
            if (!list_4h.get(0).isUptrend()) {
                return;
            }

            List<BtcFutures> list15m = Utils.loadData(symbol, TIME_15m, LIMIT_DATA_15m);

            BigDecimal min_open = BigDecimal.valueOf(1000000);
            BigDecimal min_low = BigDecimal.valueOf(1000000);
            BigDecimal max_Hig = BigDecimal.ZERO;
            for (BtcFutures dto : list15m) {
                if (min_low.compareTo(dto.getLow_price()) > 0) {
                    min_low = dto.getLow_price();
                }

                if (max_Hig.compareTo(dto.getHight_price()) < 0) {
                    max_Hig = dto.getHight_price();
                }

                if (dto.isUptrend()) {
                    if (min_open.compareTo(dto.getPrice_open_candle()) > 0) {
                        min_open = dto.getPrice_open_candle();
                    }
                } else {
                    if (min_open.compareTo(dto.getPrice_close_candle()) > 0) {
                        min_open = dto.getPrice_close_candle();
                    }
                }
            }

            BigDecimal price_at_binance = list15m.get(0).getCurrPrice();
            BigDecimal percent_to_top = Utils.getPercent(max_Hig, price_at_binance);
            BigDecimal percent_to_bottom = Utils.getPercent(price_at_binance, min_low);

            if (!Objects.equals(null, entity)
                    && percent_to_top.compareTo(percent_to_bottom.multiply(BigDecimal.valueOf(2))) > 0) {

                String msg = Utils.getMsgLong(symbol, price_at_binance, min_low, min_open, max_Hig);
                entity.setScalpingToday(true);
                entity.setScalpingEntry(msg);

                binanceFuturesRepository.save(entity);
                // Utils.sendToMyTelegram("Scalping: " + symbol + Utils.new_line_from_service +
                // msg);

                log.info("scalping: " + symbol + ", " + Utils.removeLastZero(String.valueOf(price_at_binance)) + "$");
            }

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    @Override
    public List<EntryCssResponse> findAllScalpingToday() {
        List<EntryCssResponse> results = new ArrayList<EntryCssResponse>();

        List<BinanceFutures> list = binanceFuturesRepository.findAllByScalpingToday();
        if (!CollectionUtils.isEmpty(list)) {
            for (BinanceFutures entity : list) {
                String msg = entity.getScalpingEntry();
                List<String> msgs = new ArrayList<String>(Arrays.asList(msg.split(Utils.new_line_from_service)));

                if (!CollectionUtils.isEmpty(msgs) && msgs.size() > 4) {
                    String entry = Utils.getStringValue(msgs.get(1));
                    String stop_loss = Utils.getStringValue(msgs.get(2));
                    String low = Utils.getStringValue(msgs.get(3));
                    String tp1 = msgs.size() > 4 ? Utils.getStringValue(msgs.get(4)) : "";
                    String tp2 = msgs.size() > 5 ? Utils.getStringValue(msgs.get(5)) : "";

                    EntryCssResponse dto = new EntryCssResponse();
                    dto.setSymbol(entity.getSymbol());
                    dto.setTradingview("https://vn.tradingview.com/chart/?symbol=BINANCE%3A"
                            + entity.getSymbol().toUpperCase() + "USDT");
                    dto.setFutures_msg(entity.getFuturesMsg());
                    dto.setEntry(entry);
                    dto.setStop_loss(stop_loss);
                    dto.setLow(low);
                    dto.setTp1(tp1);
                    dto.setTp2(tp2);

                    results.add(dto);
                }
            }
        }

        return results;
    }

}
