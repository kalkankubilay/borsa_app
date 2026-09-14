import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:borsa_app/main.dart';
import 'package:borsa_app/models/portfolio_asset.dart';
import 'package:borsa_app/providers/portfolio_provider.dart';

void main() {
  test('PortfolioAsset calculates profit and loss correctly', () {
    final asset = PortfolioAsset(
      id: 'test_1',
      symbol: 'THYAO',
      name: 'Türk Hava Yolları',
      market: AssetMarket.tr,
      quantity: 10,
      buyPrice: 200.0,
      currentPrice: 250.0,
      buyDate: DateTime.now(),
    );

    expect(asset.totalCost, 2000.0);
    expect(asset.totalCurrentValue, 2500.0);
    expect(asset.profitLoss, 500.0);
    expect(asset.profitLossPercentage, 25.0);
    expect(asset.isProfit, true);
  });

  testWidgets('App renders Home Screen with title and portfolio items', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const BorsaApp());
    await tester.pumpAndSettle();

    // Portföyüm başlığı bulunmalı
    expect(find.text('Portföyüm'), findsWidgets);
    expect(find.text('Varlık Dağılımı'), findsOneWidget);
    expect(find.text('BIST / TR Portföyü'), findsOneWidget);
  });

  test('PortfolioProvider adds manual asset and calculates weighted average cost', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = PortfolioProvider();
    await Future.delayed(const Duration(milliseconds: 50));
    provider.clearAllAssets();

    // 1. İlk BİM alımı: 10 adet @ 500 TL = 5.000 TL
    provider.addManualAsset(
      symbol: 'BIMAS',
      name: 'BİM Mağazalar',
      market: AssetMarket.tr,
      quantity: 10,
      buyPrice: 500.0,
      currentPrice: 550.0,
      buyDate: DateTime.now(),
    );

    expect(provider.assets.length, 1);
    expect(provider.assets.first.totalCost, 5000.0);
    expect(provider.assets.first.quantity, 10);

    // 2. İkinci BİM alımı: 10 adet @ 600 TL = 6.000 TL -> Toplam 20 adet, Ort: 550 TL
    provider.addManualAsset(
      symbol: 'BIMAS',
      name: 'BİM Mağazalar',
      market: AssetMarket.tr,
      quantity: 10,
      buyPrice: 600.0,
      currentPrice: 550.0,
      buyDate: DateTime.now(),
    );

    expect(provider.assets.length, 1);
    expect(provider.assets.first.quantity, 20);
    expect(provider.assets.first.buyPrice, 550.0);
    expect(provider.assets.first.totalCost, 11000.0);
  });
}
