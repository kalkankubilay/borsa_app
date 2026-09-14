import 'portfolio_asset.dart';

enum TransactionType {
  buy('Alış'),
  sell('Satış');

  final String label;
  const TransactionType(this.label);
}

class TradeTransaction {
  final String id;
  final DateTime date;
  final String symbol;
  final String assetName;
  final TransactionType type;
  final AssetMarket market;
  final double quantity;
  final double price;
  final double fee; // Komisyon
  final double totalAmount;
  final String currency; // 'TRY' veya 'USD'
  final String broker; // 'Midas', 'Ziraat'

  const TradeTransaction({
    required this.id,
    required this.date,
    required this.symbol,
    required this.assetName,
    required this.type,
    required this.market,
    required this.quantity,
    required this.price,
    this.fee = 0.0,
    required this.totalAmount,
    required this.currency,
    this.broker = 'Midas',
  });
}
