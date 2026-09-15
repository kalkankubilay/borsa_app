import 'package:flutter/material.dart';
import '../models/ipo_item.dart';
import '../theme/spotify_theme.dart';

class IpoDetailSheet extends StatelessWidget {
  final IpoItem ipo;

  const IpoDetailSheet({super.key, required this.ipo});

  static void show(BuildContext context, IpoItem ipo) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => IpoDetailSheet(ipo: ipo),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: SpotifyTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: SpotifyTheme.cardSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SpotifyTheme.border),
                  ),
                  child: Center(
                    child: Text(
                      ipo.symbol.isNotEmpty ? ipo.symbol : 'ARZ',
                      style: const TextStyle(
                        color: SpotifyTheme.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ipo.symbol,
                        style: const TextStyle(
                          color: SpotifyTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        ipo.companyName,
                        style: const TextStyle(
                          color: SpotifyTheme.textSecondary,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: SpotifyTheme.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(color: SpotifyTheme.border, height: 1),

          // Scrollable Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status Badge Banner
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                    decoration: BoxDecoration(
                      color: _statusBgColor(ipo.status),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _statusBorderColor(ipo.status)),
                    ),
                    child: Row(
                      children: [
                        Icon(_statusIcon(ipo.status), color: _statusColor(ipo.status), size: 18),
                        const SizedBox(width: 8),
                        Text(
                          _statusText(ipo.status),
                          style: TextStyle(
                            color: _statusColor(ipo.status),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            ipo.dates,
                            textAlign: TextAlign.right,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: SpotifyTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 11.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Halka Arz Detayları Grid
                  const Text(
                    'HALKA ARZ DETAYLARI',
                    style: TextStyle(
                      color: SpotifyTheme.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _buildDetailRow(Icons.payments_outlined, 'Halka Arz Fiyatı', ipo.price, isHighlight: ipo.currentMarketPrice == null),
                  if (ipo.currentMarketPrice != null)
                    _buildDetailRow(
                      Icons.trending_up_rounded,
                      'Canlı Borsa Fiyatı',
                      '₺${ipo.currentMarketPrice!.toStringAsFixed(2)}${ipo.currentChangeRate != null ? " (${(ipo.currentChangeRate! >= 0 ? "+" : "") + ipo.currentChangeRate!.toStringAsFixed(1)}%)" : ""}',
                      isHighlight: true,
                    ),
                  _buildDetailRow(Icons.layers_outlined, 'Dağıtılacak Pay', ipo.lotCount),
                  _buildDetailRow(Icons.pie_chart_outline_rounded, 'Dağıtım Yöntemi', ipo.distributionMethod),
                  _buildDetailRow(Icons.storefront_outlined, 'İşlem Pazarı', ipo.market),
                  _buildDetailRow(Icons.account_balance_outlined, 'Konsorsiyum Lideri', ipo.leadManager),

                  const SizedBox(height: 24),

                  // Önemli: Fonun Kullanım Yeri (Şirketin toplanan parayı nereye harcayacağı)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: SpotifyTheme.cardSurface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: SpotifyTheme.green.withOpacity(0.35), width: 1.2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: SpotifyTheme.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.savings_outlined,
                                color: SpotifyTheme.green,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Text(
                                'HALKA ARZ GELİRİNİN KULLANIM YERİ',
                                style: TextStyle(
                                  color: SpotifyTheme.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Şirketin halka arzdan elde edeceği fonu izahnameye göre nereye harcamayı planladığı:',
                          style: TextStyle(
                            color: SpotifyTheme.textSecondary.withOpacity(0.85),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: SpotifyTheme.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: SpotifyTheme.border),
                          ),
                          child: Text(
                            ipo.fundUsage.trim(),
                            style: const TextStyle(
                              color: SpotifyTheme.textPrimary,
                              fontSize: 13,
                              height: 1.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Katılım & T1-T2 Bilgilendirme Notu
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: SpotifyTheme.cardSurface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SpotifyTheme.border),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, color: SpotifyTheme.textSecondary, size: 18),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Tüm banka ve aracı kurumlardan "Halka Arz" menüsü üzerinden katılım sağlayabilirsiniz. Dağıtım eşit olduğunda kişi başı düşen pay başvuran yatırımcı sayısına göre otomatik tahsis edilir.',
                            style: TextStyle(
                              color: SpotifyTheme.textSecondary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String title, String value, {bool isHighlight = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: SpotifyTheme.cardSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: SpotifyTheme.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: isHighlight ? SpotifyTheme.green : SpotifyTheme.textSecondary, size: 18),
          const SizedBox(width: 12),
          Text(
            title,
            style: const TextStyle(
              color: SpotifyTheme.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isHighlight ? SpotifyTheme.green : SpotifyTheme.textPrimary,
                fontSize: 13,
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _statusColor(IpoStatus status) {
    switch (status) {
      case IpoStatus.active:
        return SpotifyTheme.green;
      case IpoStatus.upcoming:
        return const Color(0xFFFFB800);
      case IpoStatus.completed:
        return SpotifyTheme.textSecondary;
    }
  }

  Color _statusBgColor(IpoStatus status) {
    return _statusColor(status).withOpacity(0.12);
  }

  Color _statusBorderColor(IpoStatus status) {
    return _statusColor(status).withOpacity(0.3);
  }

  IconData _statusIcon(IpoStatus status) {
    switch (status) {
      case IpoStatus.active:
        return Icons.check_circle_outline_rounded;
      case IpoStatus.upcoming:
        return Icons.access_time_rounded;
      case IpoStatus.completed:
        return Icons.done_all_rounded;
    }
  }

  String _statusText(IpoStatus status) {
    switch (status) {
      case IpoStatus.active:
        return 'Talep Toplanıyor';
      case IpoStatus.upcoming:
        return 'SPK Onayında';
      case IpoStatus.completed:
        return 'Tamamlandı';
    }
  }
}
