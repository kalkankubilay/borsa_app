import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/portfolio_asset.dart';
import '../providers/portfolio_provider.dart';
import '../services/market_price_service.dart';
import '../theme/spotify_theme.dart';

class AssetDetailSheet extends StatefulWidget {
  final PortfolioAsset asset;
  final PortfolioProvider provider;

  const AssetDetailSheet({
    super.key,
    required this.asset,
    required this.provider,
  });

  static Future<void> show(BuildContext context, PortfolioAsset asset, PortfolioProvider provider) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssetDetailSheet(asset: asset, provider: provider),
    );
  }

  @override
  State<AssetDetailSheet> createState() => _AssetDetailSheetState();
}

class _AssetDetailSheetState extends State<AssetDetailSheet> {
  bool _isFetchingLive = false;

  Future<void> _refreshLivePrice() async {
    setState(() {
      _isFetchingLive = true;
    });

    try {
      final livePrice = await MarketPriceService.fetchLivePrice(
        widget.asset.symbol,
        widget.asset.market,
      );

      if (livePrice != null && mounted) {
        widget.provider.updateAssetCurrentPrice(widget.asset.id, livePrice);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: SpotifyTheme.surfaceElevated,
            content: Row(
              children: [
                const Icon(Icons.bolt_rounded, color: SpotifyTheme.green, size: 20),
                const SizedBox(width: 8),
                Text(
                  '${widget.asset.symbol} canlı fiyatı güncellendi: ₺${livePrice.toStringAsFixed(2)}',
                  style: const TextStyle(color: SpotifyTheme.textPrimary),
                ),
              ],
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLive = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Provider'daki en güncel varlık referansını dinle
    final currentAsset = widget.provider.assets.firstWhere(
      (a) => a.id == widget.asset.id,
      orElse: () => widget.asset,
    );

    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: currentAsset.market.currencySymbol,
      decimalDigits: 2,
    );

    final dateFormatter = DateFormat('dd.MM.yyyy HH:mm');

    final isProfit = currentAsset.isProfit;
    final profitColor = isProfit ? SpotifyTheme.green : SpotifyTheme.red;
    final profitSign = isProfit ? '+' : '';

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 28,
      ),
      decoration: const BoxDecoration(
        color: SpotifyTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: SpotifyTheme.border, width: 1.2)),
      ),
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: SpotifyTheme.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Header: Logo + Symbol + Market Badge
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: SpotifyTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: SpotifyTheme.border),
                  ),
                  child: Icon(
                    currentAsset.market == AssetMarket.tr
                        ? Icons.trending_up_rounded
                        : currentAsset.market == AssetMarket.us
                            ? Icons.language_rounded
                            : Icons.toll_rounded,
                    color: currentAsset.market == AssetMarket.tr
                        ? SpotifyTheme.green
                        : currentAsset.market == AssetMarket.us
                            ? SpotifyTheme.blue
                            : SpotifyTheme.gold,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            currentAsset.symbol,
                            style: const TextStyle(
                              color: SpotifyTheme.textPrimary,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.4,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: SpotifyTheme.surfaceElevated,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: SpotifyTheme.border),
                            ),
                            child: Text(
                              currentAsset.market.label,
                              style: const TextStyle(
                                color: SpotifyTheme.textSecondary,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        currentAsset.name,
                        style: const TextStyle(color: SpotifyTheme.textMuted, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: SpotifyTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Hero: Canlı Aktif Fiyat & Tek Tıkla Canlı Fiyat Çekme
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: SpotifyTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SpotifyTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.fiber_manual_record, color: SpotifyTheme.green, size: 10),
                          SizedBox(width: 6),
                          Text(
                            'AKTİF PİYASA FİYATI',
                            style: TextStyle(
                              color: SpotifyTheme.textMuted,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.9,
                            ),
                          ),
                        ],
                      ),
                      // Canlı Veri Yenileme Butonu
                      GestureDetector(
                        onTap: _isFetchingLive ? null : _refreshLivePrice,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: SpotifyTheme.green.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: SpotifyTheme.green.withOpacity(0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _isFetchingLive
                                  ? const SizedBox(
                                      width: 12,
                                      height: 12,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: SpotifyTheme.green,
                                      ),
                                    )
                                  : const Icon(Icons.sync_rounded, size: 14, color: SpotifyTheme.green),
                              const SizedBox(width: 5),
                              Text(
                                _isFetchingLive ? 'Çekiliyor...' : 'Canlı Fiyatı Çek',
                                style: const TextStyle(
                                  color: SpotifyTheme.green,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        currencyFormatter.format(currentAsset.currentPrice),
                        style: const TextStyle(
                          color: SpotifyTheme.textPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: profitColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: profitColor.withOpacity(0.35)),
                        ),
                        child: Text(
                          '$profitSign%${currentAsset.profitLossPercentage.toStringAsFixed(2)} ($profitSign${currencyFormatter.format(currentAsset.profitLoss)})',
                          style: TextStyle(
                            color: profitColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Yatırım ve Pozisyon Detay Izgarası
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpotifyTheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: SpotifyTheme.border),
              ),
              child: Column(
                children: [
                  _buildDetailRow(
                    label: 'Sahip Olunan Miktar',
                    value: '${currentAsset.quantity} ${currentAsset.unitLabel}',
                    icon: Icons.pie_chart_outline_rounded,
                  ),
                  const Divider(color: SpotifyTheme.border, height: 20),
                  _buildDetailRow(
                    label: 'Ortalama Alış Fiyatı (Maliyet)',
                    value: currencyFormatter.format(currentAsset.buyPrice),
                    icon: Icons.shopping_bag_outlined,
                  ),
                  const Divider(color: SpotifyTheme.border, height: 20),
                  _buildDetailRow(
                    label: 'İlk Yatırılan Toplam Tutar',
                    value: currencyFormatter.format(currentAsset.totalCost),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const Divider(color: SpotifyTheme.border, height: 20),
                  _buildDetailRow(
                    label: 'Şimdiki Toplam Piyasa Değeri',
                    value: currencyFormatter.format(currentAsset.totalCurrentValue),
                    valueColor: SpotifyTheme.textPrimary,
                    isBold: true,
                    icon: Icons.assessment_outlined,
                  ),
                  const Divider(color: SpotifyTheme.border, height: 20),
                  _buildDetailRow(
                    label: 'Net Kâr / Zarar Tutarı',
                    value: '$profitSign${currencyFormatter.format(currentAsset.profitLoss)}',
                    valueColor: profitColor,
                    isBold: true,
                    icon: isProfit ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Son Alım Tarihi Bilgisi
            Center(
              child: Text(
                'İşlem Tarihi: ${dateFormatter.format(currentAsset.buyDate)}',
                style: const TextStyle(color: SpotifyTheme.textMuted, fontSize: 11),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required String label,
    required String value,
    required IconData icon,
    Color? valueColor,
    bool isBold = false,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: SpotifyTheme.textMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(color: SpotifyTheme.textSecondary, fontSize: 13),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor ?? SpotifyTheme.textPrimary,
            fontSize: 14,
            fontWeight: isBold ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
