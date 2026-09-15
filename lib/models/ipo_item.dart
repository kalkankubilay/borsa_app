enum IpoStatus {
  active, // Talep Toplanan / Devam Eden
  upcoming, // Yaklaşan / Onay Bekleyen
  completed, // Tamamlanan / İşlem Gören (Geçmiş)
}

class IpoItem {
  final String id;
  final String symbol;
  final String companyName;
  final String dates;
  final String price; // Halka arz fiyatı (örn: 25,52 TL)
  final String lotCount;
  final String distributionMethod;
  final String market;
  final String leadManager; // Konsorsiyum / Aracı Kurum
  final String fundUsage; // Halka arz gelirinin kullanım yeri
  final String detailUrl;
  final IpoStatus status;
  final double? currentMarketPrice; // Canlı borsa fiyatı
  final double? currentChangeRate; // Günlük değişim yüzdesi

  const IpoItem({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.dates,
    required this.price,
    required this.lotCount,
    required this.distributionMethod,
    required this.market,
    required this.leadManager,
    required this.fundUsage,
    this.detailUrl = '',
    this.status = IpoStatus.upcoming,
    this.currentMarketPrice,
    this.currentChangeRate,
  });

  IpoItem copyWith({
    double? currentMarketPrice,
    double? currentChangeRate,
  }) {
    return IpoItem(
      id: id,
      symbol: symbol,
      companyName: companyName,
      dates: dates,
      price: price,
      lotCount: lotCount,
      distributionMethod: distributionMethod,
      market: market,
      leadManager: leadManager,
      fundUsage: fundUsage,
      detailUrl: detailUrl,
      status: status,
      currentMarketPrice: currentMarketPrice ?? this.currentMarketPrice,
      currentChangeRate: currentChangeRate ?? this.currentChangeRate,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'companyName': companyName,
    'dates': dates,
    'price': price,
    'lotCount': lotCount,
    'distributionMethod': distributionMethod,
    'market': market,
    'leadManager': leadManager,
    'fundUsage': fundUsage,
    'detailUrl': detailUrl,
    'status': status.name,
    'currentMarketPrice': currentMarketPrice,
    'currentChangeRate': currentChangeRate,
  };

  factory IpoItem.fromJson(Map<String, dynamic> json) => IpoItem(
    id: json['id'] ?? '',
    symbol: json['symbol'] ?? '',
    companyName: json['companyName'] ?? '',
    dates: json['dates'] ?? '',
    price: json['price'] ?? '',
    lotCount: json['lotCount'] ?? '',
    distributionMethod: json['distributionMethod'] ?? '',
    market: json['market'] ?? '',
    leadManager: json['leadManager'] ?? '',
    fundUsage: json['fundUsage'] ?? '',
    detailUrl: json['detailUrl'] ?? '',
    status: IpoStatus.values.firstWhere(
      (e) => e.name == json['status'],
      orElse: () => IpoStatus.upcoming,
    ),
    currentMarketPrice: json['currentMarketPrice'] != null
        ? (json['currentMarketPrice'] as num).toDouble()
        : null,
    currentChangeRate: json['currentChangeRate'] != null
        ? (json['currentChangeRate'] as num).toDouble()
        : null,
  );
}
