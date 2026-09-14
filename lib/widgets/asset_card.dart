import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/portfolio_asset.dart';
import '../theme/spotify_theme.dart';

class AssetCard extends StatelessWidget {
  final PortfolioAsset asset;
  final bool hideBalance;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const AssetCard({
    super.key,
    required this.asset,
    this.hideBalance = false,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: asset.market.currencySymbol,
      decimalDigits: 2,
    );

    final isProfit = asset.isProfit;
    final profitColor = isProfit ? SpotifyTheme.green : SpotifyTheme.red;
    final profitSign = isProfit ? '+' : '';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: SpotifyTheme.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: SpotifyTheme.border),
        ),
        child: Row(
        children: [
          // Asset Logo / Badge
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: SpotifyTheme.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: SpotifyTheme.border),
            ),
            alignment: Alignment.center,
            child: _buildAssetIcon(),
          ),
          const SizedBox(width: 14),

          // Symbol & Buy info (Cost)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      asset.symbol,
                      style: const TextStyle(
                        color: SpotifyTheme.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.surfaceElevated,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        asset.market == AssetMarket.tr
                            ? 'BIST'
                            : asset.market == AssetMarket.us
                                ? 'US'
                                : 'EMTİA',
                        style: const TextStyle(
                          color: SpotifyTheme.textSecondary,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  asset.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SpotifyTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  hideBalance
                      ? '***'
                      : '${asset.quantity} ${asset.unitLabel} • Alış: ${currencyFormatter.format(asset.buyPrice)}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: SpotifyTheme.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Current Value & Profit / Loss
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                hideBalance ? '••••' : currencyFormatter.format(asset.totalCurrentValue),
                style: const TextStyle(
                  color: SpotifyTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                hideBalance ? '•••' : 'Anlık: ${currencyFormatter.format(asset.currentPrice)}',
                style: const TextStyle(
                  color: SpotifyTheme.textSecondary,
                  fontSize: 11,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: profitColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: profitColor.withOpacity(0.3)),
                ),
                child: Text(
                  hideBalance
                      ? '•••'
                      : '$profitSign%${asset.profitLossPercentage.toStringAsFixed(1)} ($profitSign${currencyFormatter.format(asset.profitLoss)})',
                  style: TextStyle(
                    color: profitColor,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          if (onDelete != null) ...[
            const SizedBox(width: 6),
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, color: SpotifyTheme.textMuted, size: 18),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              tooltip: 'Varlığı Sil',
              onPressed: () => _confirmDelete(context),
            ),
          ],
        ],
      ),
    ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotifyTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SpotifyTheme.border),
        ),
        title: Text(
          '${asset.symbol} Silinsin mi?',
          style: const TextStyle(color: SpotifyTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: Text(
          '${asset.name} (${asset.quantity} ${asset.unitLabel}) pozisyonu portföyünüzden tamamen kaldırılacak.',
          style: const TextStyle(color: SpotifyTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal', style: TextStyle(color: SpotifyTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SpotifyTheme.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete?.call();
            },
            child: const Text('Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  Widget _buildAssetIcon() {
    IconData icon;
    Color iconColor;

    switch (asset.market) {
      case AssetMarket.tr:
        icon = Icons.trending_up_rounded;
        iconColor = SpotifyTheme.green;
        break;
      case AssetMarket.us:
        icon = Icons.language_rounded;
        iconColor = SpotifyTheme.blue;
        break;
      case AssetMarket.gold:
        icon = Icons.toll_rounded;
        iconColor = SpotifyTheme.gold;
        break;
    }

    return Icon(icon, color: iconColor, size: 22);
  }
}
