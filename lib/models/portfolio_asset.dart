enum AssetMarket {
  tr('🇹🇷 BIST / TR', '₺'),
  us('🇺🇸 ABD Borsası', '\$'),
  gold('🪙 Altın & Emtia', '₺');

  final String label;
  final String currencySymbol;
  const AssetMarket(this.label, this.currencySymbol);

  static AssetMarket fromString(String str) {
    return AssetMarket.values.firstWhere(
      (m) => m.name == str,
      orElse: () => AssetMarket.tr,
    );
  }
}

class PortfolioAsset {
  final String id;
  final String symbol;
  final String name;
  final AssetMarket market;
  final double quantity;
  final double buyPrice; // Alış birim maliyeti
  final double currentPrice; // Anlık birim fiyatı
  final DateTime buyDate;
  final String? unitLabel; // örn: "Adet" veya "Gram"

  const PortfolioAsset({
    required this.id,
    required this.symbol,
    required this.name,
    required this.market,
    required this.quantity,
    required this.buyPrice,
    required this.currentPrice,
    required this.buyDate,
    this.unitLabel = 'Adet',
  });

  // O zamanki toplam maliyet (alış tutarı)
  double get totalCost => quantity * buyPrice;

  // Şimdiki toplam piyasa değeri
  double get totalCurrentValue => quantity * currentPrice;

  // Net kâr / zarar tutarı
  double get profitLoss => totalCurrentValue - totalCost;

  // Yüzdesel getiri
  double get profitLossPercentage {
    if (totalCost == 0) return 0.0;
    return (profitLoss / totalCost) * 100;
  }

  bool get isProfit => profitLoss >= 0;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'name': name,
      'market': market.name,
      'quantity': quantity,
      'buyPrice': buyPrice,
      'currentPrice': currentPrice,
      'buyDate': buyDate.toIso8601String(),
      'unitLabel': unitLabel,
    };
  }

  factory PortfolioAsset.fromJson(Map<String, dynamic> json) {
    return PortfolioAsset(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      name: json['name'] as String,
      market: AssetMarket.fromString(json['market'] as String),
      quantity: (json['quantity'] as num).toDouble(),
      buyPrice: (json['buyPrice'] as num).toDouble(),
      currentPrice: (json['currentPrice'] as num).toDouble(),
      buyDate: DateTime.parse(json['buyDate'] as String),
      unitLabel: json['unitLabel'] as String? ?? 'Adet',
    );
  }
}
