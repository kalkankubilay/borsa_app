import '../models/portfolio_asset.dart';

class StockSuggestion {
  final String symbol;
  final String name;
  final AssetMarket market;

  const StockSuggestion({
    required this.symbol,
    required this.name,
    required this.market,
  });
}

class StockDirectoryService {
  static const List<StockSuggestion> directory = [
    // --- BIST 100 Popüler Hisseler (TR) ---
    StockSuggestion(symbol: 'SISE', name: 'Türkiye Şişe ve Cam Fabrikaları', market: AssetMarket.tr),
    StockSuggestion(symbol: 'THYAO', name: 'Türk Hava Yolları', market: AssetMarket.tr),
    StockSuggestion(symbol: 'ASELS', name: 'Aselsan Elektronik Sanayi', market: AssetMarket.tr),
    StockSuggestion(symbol: 'TUPRS', name: 'Tüpraş Türkiye Petrol Rafinerileri', market: AssetMarket.tr),
    StockSuggestion(symbol: 'BIMAS', name: 'BİM Birleşik Mağazalar', market: AssetMarket.tr),
    StockSuggestion(symbol: 'EREGL', name: 'Ereğli Demir ve Çelik Fabrikaları', market: AssetMarket.tr),
    StockSuggestion(symbol: 'FROTO', name: 'Ford Otomotiv Sanayi', market: AssetMarket.tr),
    StockSuggestion(symbol: 'KCHOL', name: 'Koç Holding', market: AssetMarket.tr),
    StockSuggestion(symbol: 'SAHOL', name: 'Sabancı Holding', market: AssetMarket.tr),
    StockSuggestion(symbol: 'GARAN', name: 'Garanti BBVA', market: AssetMarket.tr),
    StockSuggestion(symbol: 'AKBNK', name: 'Akbank', market: AssetMarket.tr),
    StockSuggestion(symbol: 'ISCTR', name: 'Türkiye İş Bankası (C)', market: AssetMarket.tr),
    StockSuggestion(symbol: 'YKBNK', name: 'Yapı ve Kredi Bankası', market: AssetMarket.tr),
    StockSuggestion(symbol: 'TTKOM', name: 'Türk Telekomünikasyon', market: AssetMarket.tr),
    StockSuggestion(symbol: 'TCELL', name: 'Turkcell İletişim Hizmetleri', market: AssetMarket.tr),
    StockSuggestion(symbol: 'KOZAL', name: 'Koza Altın İşletmeleri', market: AssetMarket.tr),
    StockSuggestion(symbol: 'PETKM', name: 'Petkim Petrokimya', market: AssetMarket.tr),
    StockSuggestion(symbol: 'ASTOR', name: 'Astor Enerji', market: AssetMarket.tr),
    StockSuggestion(symbol: 'ENKAI', name: 'Enka İnşaat', market: AssetMarket.tr),
    StockSuggestion(symbol: 'TOASO', name: 'Tofaş Türk Otomobil Fabrikası', market: AssetMarket.tr),
    StockSuggestion(symbol: 'ARCLK', name: 'Arçelik', market: AssetMarket.tr),
    StockSuggestion(symbol: 'MGROS', name: 'Migros Ticaret', market: AssetMarket.tr),
    StockSuggestion(symbol: 'SOKM', name: 'Şok Marketler', market: AssetMarket.tr),
    StockSuggestion(symbol: 'EKGYO', name: 'Emlak Konut GMYO', market: AssetMarket.tr),
    StockSuggestion(symbol: 'KONTR', name: 'Kontrolmatik Teknoloji', market: AssetMarket.tr),
    StockSuggestion(symbol: 'MIATK', name: 'Mia Teknoloji', market: AssetMarket.tr),
    StockSuggestion(symbol: 'HEKTS', name: 'Hektaş Ticaret', market: AssetMarket.tr),
    StockSuggestion(symbol: 'SASA', name: 'SASA Polyester Sanayi', market: AssetMarket.tr),

    // --- ABD Borsası Popüler Hisseler (US Stocks - NASDAQ / NYSE / S&P 500) ---
    StockSuggestion(symbol: 'AAPL', name: 'Apple Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'NVDA', name: 'NVIDIA Corporation', market: AssetMarket.us),
    StockSuggestion(symbol: 'MSFT', name: 'Microsoft Corporation', market: AssetMarket.us),
    StockSuggestion(symbol: 'AMZN', name: 'Amazon.com Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'GOOGL', name: 'Alphabet Inc. (Google Class A)', market: AssetMarket.us),
    StockSuggestion(symbol: 'GOOG', name: 'Alphabet Inc. (Google Class C)', market: AssetMarket.us),
    StockSuggestion(symbol: 'META', name: 'Meta Platforms Inc. (Facebook)', market: AssetMarket.us),
    StockSuggestion(symbol: 'TSLA', name: 'Tesla Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'AMD', name: 'Advanced Micro Devices', market: AssetMarket.us),
    StockSuggestion(symbol: 'NFLX', name: 'Netflix Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'INTC', name: 'Intel Corporation', market: AssetMarket.us),
    StockSuggestion(symbol: 'PLTR', name: 'Palantir Technologies', market: AssetMarket.us),
    StockSuggestion(symbol: 'COIN', name: 'Coinbase Global Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'AVGO', name: 'Broadcom Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'QCOM', name: 'Qualcomm Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'TSM', name: 'Taiwan Semiconductor Manufacturing', market: AssetMarket.us),
    StockSuggestion(symbol: 'DIS', name: 'Walt Disney Co.', market: AssetMarket.us),
    StockSuggestion(symbol: 'UBER', name: 'Uber Technologies', market: AssetMarket.us),
    StockSuggestion(symbol: 'CRM', name: 'Salesforce Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'PYPL', name: 'PayPal Holdings', market: AssetMarket.us),
    StockSuggestion(symbol: 'BABA', name: 'Alibaba Group Holding', market: AssetMarket.us),
    StockSuggestion(symbol: 'NKE', name: 'NIKE Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'KO', name: 'Coca-Cola Company', market: AssetMarket.us),
    StockSuggestion(symbol: 'PEP', name: 'PepsiCo Inc.', market: AssetMarket.us),
    StockSuggestion(symbol: 'JPM', name: 'JPMorgan Chase & Co.', market: AssetMarket.us),
    StockSuggestion(symbol: 'BAC', name: 'Bank of America Corp.', market: AssetMarket.us),
    StockSuggestion(symbol: 'SPY', name: 'SPDR S&P 500 ETF Trust', market: AssetMarket.us),
    StockSuggestion(symbol: 'QQQ', name: 'Invesco QQQ Trust (NASDAQ 100)', market: AssetMarket.us),

    // --- Altın & Emtia ---
    StockSuggestion(symbol: 'ALTIN.G', name: 'Fiziki Has Gram Altın (24 Ayar)', market: AssetMarket.gold),
    StockSuggestion(symbol: 'ALTINS1', name: 'Darphane Altın Sertifikası', market: AssetMarket.gold),
    StockSuggestion(symbol: 'CEYREK', name: 'Çeyrek Ziynet Altın', market: AssetMarket.gold),
    StockSuggestion(symbol: 'YARIM', name: 'Yarım Ziynet Altın', market: AssetMarket.gold),
    StockSuggestion(symbol: 'TAM', name: 'Tam Ziynet Altın', market: AssetMarket.gold),
    StockSuggestion(symbol: 'GUMUS.G', name: 'Fiziki Has Gram Gümüş', market: AssetMarket.gold),
    StockSuggestion(symbol: 'GLD', name: 'SPDR Gold Shares ETF', market: AssetMarket.gold),
  ];

  /// Kullanıcı yazdıkça sembol ve isimde arama yapıp öneri listesi döner (seçili markete göre filtrelenebilir)
  static List<StockSuggestion> search(String query, {AssetMarket? marketFilter}) {
    final q = query.trim().toUpperCase();
    if (q.isEmpty) return [];

    return directory.where((item) {
      if (marketFilter != null && item.market != marketFilter) {
        return false;
      }
      final symMatch = item.symbol.toUpperCase().contains(q);
      final nameMatch = item.name.toUpperCase().contains(q);
      return symMatch || nameMatch;
    }).take(8).toList(); // En alakalı 8 sonucu getir
  }
}
