package bsc_scan_binance.service;

import java.util.List;

import bsc_scan_binance.entity.Orders;
import bsc_scan_binance.response.CandidateTokenCssResponse;
import bsc_scan_binance.response.DepthResponse;
import bsc_scan_binance.response.EntryCssResponse;

public interface BinanceService {

    List<CandidateTokenCssResponse> getList(Boolean isOrderByBynaceVolume);

    public String loadBinanceData(String gecko_id, String symbol);

    public void loadDataVolumeHour(String gecko_id, String symbol);

    public void monitorProfit();

    public void monitorBollingerBandwidth(Boolean isCallFormBot);

    List<Orders> getOrderList();

    public String loadPremarket();

    public String getTextDepthData();

    public List<List<DepthResponse>> getListDepthData(String symbol);

    public List<String> monitorBtcPrice();

    public String loadPremarketSp500();

    public String getBtcBalancesOnExchanges();

    public List<EntryCssResponse> findAllScalpingToday();

    public String getLs48h(String symbol);
}
