import 'package:flutter/material.dart';
import '../models/ipo_item.dart';
import '../theme/spotify_theme.dart';
import 'ipo_detail_sheet.dart';

class IpoCard extends StatelessWidget {
  final IpoItem ipo;

  const IpoCard({super.key, required this.ipo});

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = ipo.status == IpoStatus.completed;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: SpotifyTheme.cardSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: SpotifyTheme.border, width: 0.8),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => IpoDetailSheet.show(context, ipo),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Symbol, Status Chip & Dates
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: SpotifyTheme.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: SpotifyTheme.border),
                      ),
                      child: Text(
                        ipo.symbol,
                        style: const TextStyle(
                          color: SpotifyTheme.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ipo.companyName,
                            style: const TextStyle(
                              color: SpotifyTheme.textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.calendar_today_outlined, size: 12, color: SpotifyTheme.textSecondary),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  ipo.dates,
                                  style: const TextStyle(
                                    color: SpotifyTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    _buildStatusBadge(ipo.status),
                  ],
                ),
                const SizedBox(height: 14),

                // Key metrics row (Arz Fiyatı, Canlı Borsa Fiyatı / Lot, Yöntem)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.background.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMetricCol('Arz Fiyatı', ipo.price, isGreen: !isCompleted),
                      _buildDivider(),
                      if (isCompleted && ipo.currentMarketPrice != null) ...[
                        _buildLivePriceCol(ipo.currentMarketPrice!, ipo.currentChangeRate),
                        _buildDivider(),
                      ] else ...[
                        _buildMetricCol('Lot Sayısı', ipo.lotCount),
                        _buildDivider(),
                      ],
                      _buildMetricCol(
                        isCompleted ? 'İşlem Pazarı' : 'Dağıtım',
                        isCompleted ? ipo.market : ipo.distributionMethod,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // Fund Usage Highlight Preview
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.savings_outlined, color: SpotifyTheme.green, size: 16),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Gelir Nereye Harcanacak: ${_getFirstFundUsageSummary(ipo.fundUsage)}',
                        style: TextStyle(
                          color: SpotifyTheme.textSecondary.withOpacity(0.9),
                          fontSize: 11.5,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: SpotifyTheme.textSecondary, size: 18),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getFirstFundUsageSummary(String text) {
    if (text.isEmpty) return 'İzahname bekleniyor.';
    final clean = text.replaceAll('\n', ' ').replaceAll('•', '').replaceAll('-', '').trim();
    if (clean.length > 100) {
      return '${clean.substring(0, 100)}...';
    }
    return clean;
  }

  Widget _buildMetricCol(String label, String val, {bool isGreen = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: SpotifyTheme.textSecondary,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          val,
          style: TextStyle(
            color: isGreen ? SpotifyTheme.green : SpotifyTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildLivePriceCol(double price, double? change) {
    final bool isUp = (change ?? 0) >= 0;
    final Color priceColor = isUp ? SpotifyTheme.green : SpotifyTheme.red;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Canlı Borsa',
              style: TextStyle(
                color: SpotifyTheme.textSecondary,
                fontSize: 10,
              ),
            ),
            const SizedBox(width: 4),
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: priceColor,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          children: [
            Text(
              '₺${price.toStringAsFixed(2)}',
              style: TextStyle(
                color: priceColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
            if (change != null) ...[
              const SizedBox(width: 4),
              Text(
                '${isUp ? '+' : ''}${change.toStringAsFixed(1)}%',
                style: TextStyle(
                  color: priceColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 22,
      color: SpotifyTheme.border,
    );
  }

  Widget _buildStatusBadge(IpoStatus status) {
    Color col;
    String label;
    switch (status) {
      case IpoStatus.active:
        col = SpotifyTheme.green;
        label = 'Talep Toplanıyor';
        break;
      case IpoStatus.upcoming:
        col = const Color(0xFFFFB800);
        label = 'SPK Onayında';
        break;
      case IpoStatus.completed:
        col = SpotifyTheme.turquoise;
        label = 'Borsada İşlemde';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: col.withOpacity(0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: col.withOpacity(0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: col,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }
}
