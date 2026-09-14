import 'package:flutter_test/flutter_test.dart';
import 'package:borsa_app/services/statement_parser_service.dart';
import 'package:borsa_app/models/portfolio_asset.dart';
import 'package:borsa_app/models/trade_transaction.dart';

void main() {
  group('StatementParserService Tests', () {
    test('Correctly detects markets (TR, US, Gold)', () {
      // TR Borsası
      expect(StatementParserService.detectMarket('THYAO', 'TRY'), AssetMarket.tr);
      expect(StatementParserService.detectMarket('SISE', 'TRY'), AssetMarket.tr);

      // ABD Borsası (USD para birimi veya ABD sembolü)
      expect(StatementParserService.detectMarket('AAPL', 'USD'), AssetMarket.us);
      expect(StatementParserService.detectMarket('NVDA', 'USD'), AssetMarket.us);

      // Altın & Emtia
      expect(StatementParserService.detectMarket('ALTIN.G', 'TRY'), AssetMarket.gold);
      expect(StatementParserService.detectMarket('ALTINS1', 'TRY'), AssetMarket.gold);
    });

    test('Parses Midas PDF Statement OCR text correctly', () {
      const sampleMidasText = '''
Midas Menkul Değerler A.Ş.
01/08/23 - 31/08/23 HESAP EKSTRESİ
Müşteri Adı Soyadı : KUBİLAY KALKAN
PORTFÖY ÖZETİ (31/08/23)
TTKOM - Türk Telekomünikasyo... 5 16,81 TRY 44,35 TRY 128,40 TRY
THYAO - Türk Hava Yolları 4 187,57 TRY 229,72 TRY 980,00 TRY
SISE - Türkiye Şişe ve Cam... 24 43,42 TRY 187,92 TRY 1230,00 TRY
TUPRS - Türkiye Petrol Rafin... 2 106,50 TRY 69,20 TRY 282,20 TRY
ASELS - Aselsan 6 26,40 TRY 72,72 TRY 231,12 TRY

YATIRIM İŞLEMLERİ (01/08/23 - 31/08/23)
07/08/23 10:36:40 Piyasa Emri TUPRS Alış Gerçekleşti TRY 2 - 2 106,50 0,09 213,00
''';

      final result = StatementParserService.parseMidasText(sampleMidasText);

      expect(result.customerName, 'KUBİLAY KALKAN');
      expect(result.summaryAssets.length, 5);

      // TTKOM kontrolü
      final ttkom = result.summaryAssets.firstWhere((a) => a.symbol == 'TTKOM');
      expect(ttkom.quantity, 5);
      expect(ttkom.buyPrice, 16.81);
      expect(ttkom.market, AssetMarket.tr);

      // TUPRS İşlem kontrolü
      expect(result.transactions.length, 1);
      final tx = result.transactions.first;
      expect(tx.symbol, 'TUPRS');
      expect(tx.type, TransactionType.buy);
      expect(tx.quantity, 2);
      expect(tx.price, 106.50);
      expect(tx.totalAmount, 213.00);
    });
  });
}
