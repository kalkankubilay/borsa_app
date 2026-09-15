import 'package:flutter/material.dart';
import '../models/ipo_item.dart';
import '../models/portfolio_asset.dart';
import '../services/ipo_service.dart';
import '../services/market_price_service.dart';
import '../theme/spotify_theme.dart';
import '../widgets/ipo_card.dart';

class IpoScreen extends StatefulWidget {
  const IpoScreen({super.key});

  @override
  State<IpoScreen> createState() => _IpoScreenState();
}

class _IpoScreenState extends State<IpoScreen> {
  List<IpoItem> _ipos = [];
  bool _isLoading = true;
  int _selectedFilterIndex = 0; // 0: Tümü, 1: SPK Onayında, 2: Onay Aşaması, 3: Geçmiş Halka Arzlar (Son 5)

  @override
  void initState() {
    super.initState();
    _loadIpos();
  }

  Future<void> _loadIpos({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<IpoItem> baseList;
      if (forceRefresh) {
        baseList = await IpoService.fetchLiveIpos();
      } else {
        baseList = await IpoService.getCachedOrFallbackIpos();
        // Arka planda sessizce en güncel JSON'u çek
        IpoService.fetchLiveIpos().then((fresh) {
          if (mounted && fresh.isNotEmpty) {
            _updateIposWithLiveQuotes(fresh);
          }
        });
      }

      await _updateIposWithLiveQuotes(baseList);
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  /// Geçmiş 5 halka arz için canlı borsa fiyatlarını arka planda eşleştirir
  Future<void> _updateIposWithLiveQuotes(List<IpoItem> rawList) async {
    if (!mounted) return;

    setState(() {
      _ipos = rawList;
      _isLoading = false;
    });

    // Geçmiş (completed) statüsündeki hisseler için canlı borsa fiyatlarını çek
    final completedItems = rawList.where((i) => i.status == IpoStatus.completed).toList();
    if (completedItems.isEmpty) return;

    List<IpoItem> updatedList = List.from(rawList);

    for (var item in completedItems) {
      try {
        final quote = await MarketPriceService.fetchLiveQuote(item.symbol, AssetMarket.tr);
        if (quote != null) {
          final index = updatedList.indexWhere((i) => i.id == item.id);
          if (index != -1) {
            updatedList[index] = item.copyWith(
              currentMarketPrice: quote.price,
              currentChangeRate: quote.changePercent,
            );
          }
        }
      } catch (_) {}
    }

    if (mounted) {
      setState(() {
        _ipos = updatedList;
      });
    }
  }

  List<IpoItem> get _filteredIpos {
    if (_selectedFilterIndex == 1) {
      // Sadece SPK onayında/başvurusunda olanlar
      return _ipos.where((i) => i.status == IpoStatus.upcoming).toList();
    } else if (_selectedFilterIndex == 2) {
      // Taslak izahnamesi olanlar
      return _ipos
          .where((i) =>
              i.status == IpoStatus.upcoming &&
              (i.price.contains('Taslak') || i.price.contains('Belirlen')))
          .toList();
    } else if (_selectedFilterIndex == 3) {
      // Sadece geçmiş halka arzlar (Tam olarak en son 5 adet)
      return _ipos.where((i) => i.status == IpoStatus.completed).take(5).toList();
    }
    return _ipos;
  }

  @override
  Widget build(BuildContext context) {
    final completedCount = _ipos.where((i) => i.status == IpoStatus.completed).take(5).length;
    final upcomingCount = _ipos.where((i) => i.status == IpoStatus.upcoming).length;

    return Scaffold(
      backgroundColor: SpotifyTheme.background,
      body: RefreshIndicator(
        color: SpotifyTheme.green,
        backgroundColor: SpotifyTheme.surface,
        onRefresh: () => _loadIpos(forceRefresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Halka Arz Takvimi',
                                style: TextStyle(
                                  color: SpotifyTheme.textPrimary,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _selectedFilterIndex == 3
                                    ? 'Son 5 tamamlanan halka arz ve anlık borsa fiyatları'
                                    : 'SPK onayı bekleyen taslak şirketler ve geçmiş arzlar',
                                style: TextStyle(
                                  color: SpotifyTheme.textSecondary.withValues(alpha: 0.9),
                                  fontSize: 13,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => _loadIpos(forceRefresh: true),
                          icon: const Icon(Icons.refresh_rounded, color: SpotifyTheme.green),
                          tooltip: 'Yenile',
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Filter Chips (Tümü, SPK Onayında, Taslaklar, Geçmiş Halka Arzlar (5))
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(0, 'Tümü (${_ipos.length})'),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            1,
                            'SPK Onayında ($upcomingCount)',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            2,
                            'Onay Aşaması (${_ipos.where((i) => i.status == IpoStatus.upcoming && (i.price.contains('Taslak') || i.price.contains('Belirlen'))).length})',
                          ),
                          const SizedBox(width: 8),
                          _buildFilterChip(
                            3,
                            'Geçmiş Halka Arzlar ($completedCount)',
                            isCompletedTab: true,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Content List
            if (_isLoading && _ipos.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: SpotifyTheme.green),
                ),
              )
            else if (_filteredIpos.isEmpty)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.event_busy_outlined, color: SpotifyTheme.textSecondary, size: 48),
                      const SizedBox(height: 12),
                      const Text(
                        'Bu kategoride halka arz bulunamadı.',
                        style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      TextButton.icon(
                        onPressed: () => _loadIpos(forceRefresh: true),
                        icon: const Icon(Icons.refresh, color: SpotifyTheme.green, size: 18),
                        label: const Text('Yenile', style: TextStyle(color: SpotifyTheme.green)),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final ipo = _filteredIpos[index];
                      return IpoCard(ipo: ipo);
                    },
                    childCount: _filteredIpos.length,
                  ),
                ),
              ),

            const SliverToBoxAdapter(
              child: SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(int index, String label, {bool isCompletedTab = false}) {
    final isSelected = _selectedFilterIndex == index;
    final activeColor = isCompletedTab ? SpotifyTheme.turquoise : SpotifyTheme.green;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? activeColor : SpotifyTheme.cardSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? activeColor : SpotifyTheme.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isCompletedTab) ...[
              Icon(
                Icons.history_rounded,
                size: 14,
                color: isSelected ? Colors.black : SpotifyTheme.turquoise,
              ),
              const SizedBox(width: 6),
            ],
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.black : SpotifyTheme.textPrimary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
