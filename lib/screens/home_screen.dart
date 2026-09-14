import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../theme/spotify_theme.dart';
import '../models/portfolio_asset.dart';
import '../widgets/statement_import_modal.dart';

class HomeScreen extends StatelessWidget {
  final PortfolioProvider provider;
  final Function(int targetTab) onNavigateToSegment;

  const HomeScreen({
    super.key,
    required this.provider,
    required this.onNavigateToSegment,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    final totalVal = provider.totalCurrentValueTry;
    final totalPl = provider.totalProfitLossTry;
    final totalPlPct = provider.totalProfitLossPercentage;
    final isProfit = totalPl >= 0;
    final profitColor = isProfit ? SpotifyTheme.green : SpotifyTheme.red;
    final profitSign = isProfit ? '+' : '';

    final trVal = provider.marketTotalValueTry(AssetMarket.tr);
    final usVal = provider.marketTotalValueTry(AssetMarket.us);
    final goldVal = provider.marketTotalValueTry(AssetMarket.gold);

    final trRatio = totalVal > 0 ? trVal / totalVal : 0.0;
    final usRatio = totalVal > 0 ? usVal / totalVal : 0.0;
    final goldRatio = totalVal > 0 ? goldVal / totalVal : 0.0;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Top Bar / Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portföyüm',
                  style: TextStyle(
                    color: SpotifyTheme.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                Row(
                  children: [
                    // Currency Toggle Pill
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: SpotifyTheme.border),
                      ),
                      child: Row(
                        children: [
                          _buildCurrencyBtn('TRY', provider.selectedCurrency == 'TRY', () {
                            provider.setCurrency('TRY');
                          }),
                          _buildCurrencyBtn('USD', provider.selectedCurrency == 'USD', () {
                            provider.setCurrency('USD');
                          }),
                        ],
                      ),
                    ),
                    // PDF Ekstre Yükle Butonu
                    IconButton(
                      icon: const Icon(
                        Icons.upload_file_rounded,
                        color: SpotifyTheme.green,
                        size: 20,
                      ),
                      tooltip: 'Ekstre Yükle',
                      style: IconButton.styleFrom(
                        backgroundColor: SpotifyTheme.surface,
                        side: const BorderSide(color: SpotifyTheme.border),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: () {
                        StatementImportModal.show(context, provider);
                      },
                    ),
                    const SizedBox(width: 8),

                    // Privacy Eye Toggle
                    IconButton(
                      icon: Icon(
                        provider.hideBalance
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: SpotifyTheme.textSecondary,
                        size: 20,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: SpotifyTheme.surface,
                        side: const BorderSide(color: SpotifyTheme.border),
                        padding: const EdgeInsets.all(10),
                      ),
                      onPressed: provider.toggleHideBalance,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 2. Consolidated Hero Section
          Container(
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: SpotifyTheme.surface,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: SpotifyTheme.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'PORTFÖY TOPLAMI',
                  style: TextStyle(
                    color: SpotifyTheme.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  provider.hideBalance ? '₺••••••••' : currencyFormatter.format(totalVal),
                  style: const TextStyle(
                    color: SpotifyTheme.textPrimary,
                    fontSize: 34,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -1.0,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: profitColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: profitColor.withOpacity(0.35)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isProfit ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                            color: profitColor,
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            provider.hideBalance
                                ? '•••'
                                : '$profitSign%${totalPlPct.toStringAsFixed(1)} ($profitSign${currencyFormatter.format(totalPl)})',
                            style: TextStyle(
                              color: profitColor,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      provider.hideBalance
                          ? 'Maliyet: •••'
                          : 'Maliyet: ${currencyFormatter.format(provider.totalCostTry)}',
                      style: const TextStyle(
                        color: SpotifyTheme.textMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),

                // 3. Asset Allocation Bar
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Varlık Dağılımı',
                      style: TextStyle(
                        color: SpotifyTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '100%',
                      style: TextStyle(
                        color: SpotifyTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: SizedBox(
                    height: 9,
                    child: Row(
                      children: [
                        Expanded(
                          flex: (trRatio * 1000).toInt(),
                          child: Container(color: SpotifyTheme.green),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: (usRatio * 1000).toInt(),
                          child: Container(color: SpotifyTheme.blue),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: (goldRatio * 1000).toInt(),
                          child: Container(color: SpotifyTheme.gold),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildLegendItem('TR Hisseleri', '%${(trRatio * 100).toStringAsFixed(0)}', SpotifyTheme.green),
                    _buildLegendItem('ABD Borsası', '%${(usRatio * 100).toStringAsFixed(0)}', SpotifyTheme.blue),
                    _buildLegendItem('Altın / Emtia', '%${(goldRatio * 100).toStringAsFixed(0)}', SpotifyTheme.gold),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // 4. Section: Piyasalar & Portföy Kartları (Tıklanabilir 3 Sekme Kartı)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Portföy Segmentleri',
                  style: TextStyle(
                    color: SpotifyTheme.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  'Detay için dokunun',
                  style: TextStyle(
                    color: SpotifyTheme.green.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // 3 Segment Kartı
          _buildMarketSummaryCard(
            title: 'BIST / TR Portföyü',
            value: trVal,
            pl: provider.marketTotalProfitLossTry(AssetMarket.tr),
            plPct: provider.marketProfitLossPercentage(AssetMarket.tr),
            badgeColor: SpotifyTheme.green,
            currencyFormatter: currencyFormatter,
            onTap: () => onNavigateToSegment(1), // TR Tab
          ),

          _buildMarketSummaryCard(
            title: 'ABD Borsası (US Stocks)',
            value: usVal,
            pl: provider.marketTotalProfitLossTry(AssetMarket.us),
            plPct: provider.marketProfitLossPercentage(AssetMarket.us),
            badgeColor: SpotifyTheme.blue,
            currencyFormatter: currencyFormatter,
            onTap: () => onNavigateToSegment(2), // US Tab
          ),

          _buildMarketSummaryCard(
            title: 'Altın & Değerli Madenler',
            value: goldVal,
            pl: provider.marketTotalProfitLossTry(AssetMarket.gold),
            plPct: provider.marketProfitLossPercentage(AssetMarket.gold),
            badgeColor: SpotifyTheme.gold,
            currencyFormatter: currencyFormatter,
            onTap: () => onNavigateToSegment(3), // Gold Tab
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyBtn(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected ? SpotifyTheme.surfaceElevated : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? SpotifyTheme.textPrimary : SpotifyTheme.textMuted,
            fontSize: 11,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String title, String pct, Color color) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          '$title $pct',
          style: const TextStyle(
            color: SpotifyTheme.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildMarketSummaryCard({
    required String title,
    required double value,
    required double pl,
    required double plPct,
    required Color badgeColor,
    required NumberFormat currencyFormatter,
    required VoidCallback onTap,
  }) {
    final isProfit = pl >= 0;
    final profitColor = isProfit ? SpotifyTheme.green : SpotifyTheme.red;
    final sign = isProfit ? '+' : '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: SpotifyTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: SpotifyTheme.border),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: badgeColor.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: badgeColor.withOpacity(0.3)),
              ),
              child: Icon(Icons.pie_chart_outline_rounded, color: badgeColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: SpotifyTheme.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  provider.hideBalance ? '₺••••' : currencyFormatter.format(value),
                  style: const TextStyle(
                    color: SpotifyTheme.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  provider.hideBalance ? '•••' : '$sign%${plPct.toStringAsFixed(1)} ($sign${currencyFormatter.format(pl)})',
                  style: TextStyle(
                    color: profitColor,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: SpotifyTheme.textMuted,
              size: 13,
            ),
          ],
        ),
      ),
    );
  }
}
