class DividendIncome {
  final String id;
  final String symbol;
  final String companyName;
  final double amount; // Net temettü tutarı
  final String currency; // 'TRY' veya 'USD'
  final DateTime date;
  final String broker; // 'Midas', 'Ziraat' vb.
  final String note;

  const DividendIncome({
    required this.id,
    required this.symbol,
    required this.companyName,
    required this.amount,
    this.currency = 'TRY',
    required this.date,
    this.broker = 'Midas',
    this.note = '',
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'symbol': symbol,
    'companyName': companyName,
    'amount': amount,
    'currency': currency,
    'date': date.toIso8601String(),
    'broker': broker,
    'note': note,
  };

  factory DividendIncome.fromJson(Map<String, dynamic> json) => DividendIncome(
    id: json['id'] ?? '',
    symbol: json['symbol'] ?? '',
    companyName: json['companyName'] ?? '',
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] ?? 'TRY',
    date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
    broker: json['broker'] ?? 'Midas',
    note: json['note'] ?? '',
  );
}
