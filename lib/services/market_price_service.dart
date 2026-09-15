import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/portfolio_asset.dart';

class MarketPriceResult {
  final double price;
  final double? changePercent;

  const MarketPriceResult({required this.price, this.changePercent});
}

class MarketPriceService {
  /// Yahoo Finance / Kamu Açık Finans Endpointlerinden canlı fiyat ve günlük değişim yüzdesi çeker
  static Future<MarketPriceResult?> fetchLiveQuote(String symbol, AssetMarket market) async {
    final clean = symbol.trim().toUpperCase();

    String ticker;
    switch (market) {
      case AssetMarket.tr:
        ticker = clean.endsWith('.IS') ? clean : '$clean.IS';
        break;
      case AssetMarket.us:
        ticker = clean;
        break;
      case AssetMarket.gold:
        ticker = clean == 'ALTINS1' ? 'ALTINS1.IS' : 'GC=F';
        break;
    }

    try {
      final url = Uri.parse(
        'https://query1.finance.yahoo.com/v8/finance/chart/$ticker?interval=1d&range=1d',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64)',
          'Accept': 'application/json',
        },
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final meta = data['chart']?['result']?[0]?['meta'];
        if (meta != null) {
          final regularMarketPrice = meta['regularMarketPrice'];
          final previousClose = meta['chartPreviousClose'] ?? meta['previousClose'];
          
          if (regularMarketPrice is num) {
            double? change;
            if (previousClose is num && previousClose > 0) {
              change = ((regularMarketPrice - previousClose) / previousClose) * 100;
            }
            return MarketPriceResult(
              price: regularMarketPrice.toDouble(),
              changePercent: change,
            );
          }
        }
      }
    } catch (_) {}

    final fallback = _getFallbackPrice(clean);
    if (fallback != null) {
      return MarketPriceResult(price: fallback, changePercent: 0.0);
    }
    return null;
  }

  /// Basit uyumluluk metodu
  static Future<double?> fetchLivePrice(String symbol, AssetMarket market) async {
    final quote = await fetchLiveQuote(symbol, market);
    return quote?.price;
  }

  static double? _getFallbackPrice(String symbol) {
    const fallbackPrices = {
      'SISE': 43.80,
      'THYAO': 304.50,
      'ASELS': 68.20,
      'TUPRS': 178.60,
      'BIMAS': 540.00,
      'TTKOM': 48.20,
      'AAPL': 228.40,
      'NVDA': 125.60,
      'MSFT': 428.00,
      'ALTINS1': 32.40,
      'ALTIN.G': 2940.00,
      // Yeni halka arzlar için son işlem fiyatları
      'NETGL': 28.10,
      'INTET': 37.60,
      'BKRGY': 20.46,
      'VEYAS': 46.20,
      'KPEKS': 15.30,
    };
    return fallbackPrices[symbol];
  }
}
