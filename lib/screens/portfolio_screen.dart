import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../theme/spotify_theme.dart';
import '../models/portfolio_asset.dart';
import '../widgets/asset_card.dart';
import '../widgets/add_asset_modal.dart';
import '../widgets/asset_detail_sheet.dart';

class PortfolioScreen extends StatefulWidget {
  final PortfolioProvider provider;
  final int initialTabIndex;

  const PortfolioScreen({
    super.key,
    required this.provider,
    this.initialTabIndex = 0,
  });

  @override
  State<PortfolioScreen> createState() => _PortfolioScreenState();
}

class _PortfolioScreenState extends State<PortfolioScreen> {
  late int _selectedTab;

  final List<String> _tabs = [
    'Tümü',
    '🇹🇷 BIST / TR',
    '🇺🇸 ABD Borsası',
    '🪙 Altın & Emtia',
  ];

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initialTabIndex;
  }

  AssetMarket? get _currentMarketFilter {
    switch (_selectedTab) {
      case 1:
        return AssetMarket.tr;
      case 2:
        return AssetMarket.us;
      case 3:
        return AssetMarket.gold;
      default:
        return null; // Tümü
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = widget.provider;
    final currencyFormatter = NumberFormat.currency(
      locale: 'tr_TR',
      symbol: '₺',
      decimalDigits: 2,
    );

    final filteredAssets = provider.assetsForMarket(_currentMarketFilter);

    // Seçili sekmenin toplam değer ve kâr/zarar hesabı
    double tabTotalValue = 0;
    double tabProfitLoss = 0;
    double tabTotalCost = 0;

    for (var a in filteredAssets) {
      final rate = a.market == AssetMarket.us ? MockPortfolioData.usdToTry : 1.0;
      tabTotalValue += a.totalCurrentValue * rate;
      tabTotalCost += a.totalCost * rate;
    }
    tabProfitLoss = tabTotalValue - tabTotalCost;
    final tabPlPct = tabTotalCost > 0 ? (tabProfitLoss / tabTotalCost) * 100 : 0.0;
    final isProfit = tabProfitLoss >= 0;
    final profitColor = isProfit ? SpotifyTheme.green : SpotifyTheme.red;
    final sign = isProfit ? '+' : '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Header
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Varlıklarım',
                style: TextStyle(
                  color: SpotifyTheme.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              Row(
                children: [
                  // Manuel Varlık Ekleme Butonu (Seçili sekmeye özel)
                  IconButton(
                    icon: const Icon(Icons.add_circle_rounded, color: SpotifyTheme.green, size: 24),
                    tooltip: 'Manuel Varlık Ekle',
                    onPressed: () => AddAssetModal.show(
                      context,
                      provider,
                      targetMarket: _currentMarketFilter,
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (provider.assets.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.cleaning_services_rounded, color: SpotifyTheme.textMuted, size: 19),
                      tooltip: 'Portföyü Sıfırla (Temizle)',
                      onPressed: () => _confirmClearAll(context),
                    ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: SpotifyTheme.surface,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: SpotifyTheme.border),
                    ),
                    child: Text(
                      '${filteredAssets.length} Pozisyon',
                      style: const TextStyle(
                        color: SpotifyTheme.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // 2. Spotify Pill Tabs (Yatay Kaydırılabilir Sekmeler)
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: List.generate(_tabs.length, (index) {
              final isSelected = _selectedTab == index;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTab = index;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? SpotifyTheme.textPrimary : SpotifyTheme.inactivePill,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected ? SpotifyTheme.textPrimary : SpotifyTheme.border,
                      ),
                    ),
                    child: Text(
                      _tabs[index],
                      style: TextStyle(
                        color: isSelected ? Colors.black : SpotifyTheme.textSecondary,
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),

        // 3. Tab Specific Summary Card
        Container(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: SpotifyTheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: SpotifyTheme.border),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_tabs[_selectedTab].toUpperCase()} DEĞERİ',
                    style: const TextStyle(
                      color: SpotifyTheme.textMuted,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    provider.hideBalance ? '₺••••••••' : currencyFormatter.format(tabTotalValue),
                    style: const TextStyle(
                      color: SpotifyTheme.textPrimary,
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: profitColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: profitColor.withOpacity(0.3)),
                ),
                child: Text(
                  provider.hideBalance
                      ? '•••'
                      : '$sign%${tabPlPct.toStringAsFixed(1)} ($sign${currencyFormatter.format(tabProfitLoss)})',
                  style: TextStyle(
                    color: profitColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),

        // 4. Detailed Asset List
        Expanded(
          child: filteredAssets.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open_rounded, size: 48, color: SpotifyTheme.textMuted.withOpacity(0.5)),
                      const SizedBox(height: 12),
                      const Text(
                        'Henüz bu kategoride varlık yok',
                        style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Ekstre yükleyerek otomatik varlık ekleyebilirsiniz',
                        style: TextStyle(color: SpotifyTheme.textMuted, fontSize: 12),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: filteredAssets.length,
                  itemBuilder: (context, index) {
                    final asset = filteredAssets[index];
                    return AssetCard(
                      asset: asset,
                      hideBalance: provider.hideBalance,
                      onTap: () {
                        AssetDetailSheet.show(context, asset, provider);
                      },
                      onDelete: () {
                        provider.removeAsset(asset.id);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: SpotifyTheme.surfaceElevated,
                            content: Text(
                              '${asset.symbol} portföyden silindi',
                              style: const TextStyle(color: SpotifyTheme.textPrimary),
                            ),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _confirmClearAll(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SpotifyTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: SpotifyTheme.border),
        ),
        title: const Text(
          'Tüm Portföy Sıfırlansın mı?',
          style: TextStyle(color: SpotifyTheme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        content: const Text(
          'Tüm hisse, ABD borsası ve altın pozisyonlarınız silinecek ve tertemiz bir portföy başlayacak.',
          style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Vazgeç', style: TextStyle(color: SpotifyTheme.textMuted)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: SpotifyTheme.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: () {
              Navigator.pop(ctx);
              widget.provider.clearAllAssets();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: SpotifyTheme.surfaceElevated,
                  content: Text(
                    'Portföy tamamen temizlendi!',
                    style: TextStyle(color: SpotifyTheme.textPrimary),
                  ),
                ),
              );
            },
            child: const Text('Hepsini Sil', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
