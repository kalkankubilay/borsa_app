import 'dart:typed_data';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../models/portfolio_asset.dart';
import '../models/trade_transaction.dart';

class ParsedStatementResult {
  final List<PortfolioAsset> summaryAssets;
  final List<TradeTransaction> transactions;
  final String broker;
  final String customerName;
  final String dateRange;

  ParsedStatementResult({
    required this.summaryAssets,
    required this.transactions,
    this.broker = 'Midas',
    this.customerName = '',
    this.dateRange = '',
  });
}

class StatementParserService {
  /// Belirli bir sembolün ve para biriminin TR mi, ABD mi, Altın mı olduğunu anlar
  static AssetMarket detectMarket(String symbol, String currency) {
    final s = symbol.trim().toUpperCase();
    final c = currency.trim().toUpperCase();

    // 1. Altın / Emtia kontrolü
    if (s.contains('ALTIN') || s.contains('GLD') || s.contains('XAU') || s == 'ALTINS1') {
      return AssetMarket.gold;
    }

    // 2. Para birimi USD ise kesinlikle ABD borsası
    if (c == 'USD' || c == '\$') {
      return AssetMarket.us;
    }

    // 3. Bilinen BIST / TR kalıpları (Genelde 4-5 harfli Türk sembolleri: THYAO, TTKOM, SISE, ASELS, TUPRS, BIMAS vb.)
    // Eğer para birimi TRY ise ve tipik BIST koduysa TR
    if (c == 'TRY' || c == 'TL' || c == '₺') {
      return AssetMarket.tr;
    }

    // 4. Sembolik ayrıştırma: ABD hisseleri genelde 1-4 karakterli (AAPL, TSLA, MSFT, NVDA, AMZN vb.)
    const knownUsTickers = {'AAPL', 'NVDA', 'MSFT', 'AMZN', 'GOOGL', 'META', 'TSLA', 'AMD', 'INTC', 'NFLX', 'SPY', 'QQQ'};
    if (knownUsTickers.contains(s)) {
      return AssetMarket.us;
    }

    return AssetMarket.tr; // Varsayılan BIST
  }

  /// PDF dosyasının byte verilerini okuyarak Midas ekstresini ayrıştırır
  static ParsedStatementResult parsePdfBytes(Uint8List bytes) {
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    final PdfTextExtractor extractor = PdfTextExtractor(document);
    final String fullText = extractor.extractText();
    document.dispose();

    return parseMidasText(fullText);
  }

  /// Midas ekstre metnini ayrıştıran regex ve satır tarayıcı motoru
  static ParsedStatementResult parseMidasText(String text) {
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();

    List<PortfolioAsset> assets = [];
    List<TradeTransaction> transactions = [];
    String customerName = '';
    String dateRange = '';

    // Müşteri Adı ve Tarih Aralığı bulma
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      if (line.contains('Müşteri Adı Soyadı')) {
        customerName = line.split(':').last.trim();
      }
      if (line.contains('HESAP EKSTRESİ')) {
        dateRange = line.replaceAll('HESAP EKSTRESİ', '').trim();
      }
    }

    // --- 1. PORTFÖY ÖZETİ Ayrıştırma ---
    // Örnek Satır: "TTKOM - Türk Telekomünikasyo... 5 16,81 TRY 44,35 TRY 128,40 TRY"
    // veya OCR bloklarında parçalı gelen yapılar
    final summaryRegex = RegExp(
      r'([A-Z0-9.]+)\s*-\s*([^\d]+?)\s+(\d+)\s+([\d,.]+)\s*(TRY|USD)\s+([\d,.]+)\s*(TRY|USD)\s+([\d,.]+)\s*(TRY|USD)',
      caseSensitive: false,
    );

    for (var match in summaryRegex.allMatches(text)) {
      final symbol = match.group(1)!.trim();
      final name = match.group(2)!.trim();
      final quantity = double.tryParse(match.group(3)!) ?? 0.0;
      final buyPrice = _parsePrice(match.group(4)!);
      final currency = match.group(5)!.toUpperCase();
      // group(6) Kar/Zarar
      final totalValue = _parsePrice(match.group(8)!);
      final currentPrice = quantity > 0 ? (totalValue / quantity) : buyPrice;

      final market = detectMarket(symbol, currency);

      assets.add(
        PortfolioAsset(
          id: 'midas_${symbol}_${DateTime.now().millisecondsSinceEpoch}',
          symbol: symbol,
          name: name,
          market: market,
          quantity: quantity,
          buyPrice: buyPrice,
          currentPrice: currentPrice,
          buyDate: DateTime.now(),
          unitLabel: market == AssetMarket.gold ? 'Gram' : 'Adet',
        ),
      );
    }

    // --- 2. YATIRIM İŞLEMLERİ (Alış / Satış) Ayrıştırma ---
    // Örnek: "07/08/23 10:36:40 Piyasa Emri TUPRS Alış Gerçekleşti TRY 2 - 2 106,50 0,09 213,00"
    final tradeRegex = RegExp(
      r'(\d{2}/\d{2}/\d{2}\s+\d{2}:\d{2}:\d{2})\s+([^\n]+?)\s+([A-Z0-9.]+)\s+(Alış|Satış)\s+([^\n]+?)\s+(TRY|USD)\s+(\d+)\s+[-—\d.]*\s+(\d+)\s+([\d,.]+)\s+([\d,.]+)\s+([\d,.]+)',
      caseSensitive: false,
    );

    for (var match in tradeRegex.allMatches(text)) {
      final dateStr = match.group(1)!;
      final symbol = match.group(3)!;
      final typeStr = match.group(4)!;
      final currency = match.group(6)!;
      final execQty = double.tryParse(match.group(8)!) ?? 0.0;
      final price = _parsePrice(match.group(9)!);
      final fee = _parsePrice(match.group(10)!);
      final total = _parsePrice(match.group(11)!);

      final market = detectMarket(symbol, currency);
      final type = typeStr.toLowerCase().contains('sat') ? TransactionType.sell : TransactionType.buy;

      transactions.add(
        TradeTransaction(
          id: 'tx_${symbol}_${DateTime.now().millisecondsSinceEpoch}',
          date: _parseDate(dateStr),
          symbol: symbol,
          assetName: symbol,
          type: type,
          market: market,
          quantity: execQty,
          price: price,
          fee: fee,
          totalAmount: total,
          currency: currency,
          broker: 'Midas',
        ),
      );
    }

    return ParsedStatementResult(
      summaryAssets: assets,
      transactions: transactions,
      customerName: customerName,
      dateRange: dateRange,
    );
  }

  static double _parsePrice(String str) {
    // "187,57" veya "1.230,00" formatını double'a çevir
    var cleaned = str.replaceAll('.', '').replaceAll(',', '.').trim();
    return double.tryParse(cleaned) ?? 0.0;
  }

  static DateTime _parseDate(String str) {
    // "07/08/23 10:36:40"
    try {
      final parts = str.split(' ');
      final dateParts = parts[0].split('/');
      final day = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      var year = int.parse(dateParts[2]);
      if (year < 100) year += 2000;

      final timeParts = parts[1].split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final second = int.parse(timeParts[2]);

      return DateTime(year, month, day, hour, minute, second);
    } catch (_) {
      return DateTime.now();
    }
  }
}
