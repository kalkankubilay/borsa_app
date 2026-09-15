import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../theme/spotify_theme.dart';
import '../services/stock_directory_service.dart';
import '../models/portfolio_asset.dart';

class DividendDetailSheet extends StatefulWidget {
  final PortfolioProvider provider;

  const DividendDetailSheet({super.key, required this.provider});

  static void show(BuildContext context, PortfolioProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DividendDetailSheet(provider: provider),
    );
  }

  @override
  State<DividendDetailSheet> createState() => _DividendDetailSheetState();
}

class _DividendDetailSheetState extends State<DividendDetailSheet> {
  final _formKey = GlobalKey<FormState>();
  final _symbolController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  String _selectedBroker = 'Midas';
  bool _isAdding = false;
  List<StockSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _symbolController.addListener(_onSymbolChanged);
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _companyNameController.dispose();
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _onSymbolChanged() {
    final sym = _symbolController.text.trim();
    if (sym.isNotEmpty) {
      final results = StockDirectoryService.search(sym, marketFilter: AssetMarket.tr);
      setState(() {
        _suggestions = results;
      });
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _selectSuggestion(StockSuggestion suggestion) {
    setState(() {
      _symbolController.text = suggestion.symbol;
      _companyNameController.text = suggestion.name;
      _suggestions = [];
    });
  }

  void _submitAdd() {
    if (!_formKey.currentState!.validate()) return;

    final sym = _symbolController.text.trim().toUpperCase();
    final name = _companyNameController.text.trim();
    final amt = double.parse(_amountController.text.replaceAll(',', '.'));
    final note = _noteController.text.trim();

    widget.provider.addDividend(
      symbol: sym,
      companyName: name.isNotEmpty ? name : sym,
      amount: amt,
      currency: 'TRY',
      date: _selectedDate,
      broker: _selectedBroker,
      note: note,
    );

    setState(() {
      _isAdding = false;
      _symbolController.clear();
      _companyNameController.clear();
      _amountController.clear();
      _noteController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SpotifyTheme.surfaceElevated,
        content: Text('$sym temettü geliri kaydedildi!', style: const TextStyle(color: SpotifyTheme.green)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);
    final dateFormatter = DateFormat('dd.MM.yyyy');
    final totalDiv = widget.provider.totalDividendIncomeTry;

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
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.monetization_on_rounded, color: SpotifyTheme.green, size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Temettü Gelirleri',
                        style: TextStyle(
                          color: SpotifyTheme.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'BIST ve Midas kâr payı özetiniz',
                        style: TextStyle(
                          color: SpotifyTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isAdding ? Icons.close : Icons.add_circle_outline_rounded,
                      color: SpotifyTheme.green),
                  tooltip: _isAdding ? 'Vazgeç' : 'Temettü Ekle',
                  onPressed: () {
                    setState(() {
                      _isAdding = !_isAdding;
                    });
                  },
                ),
              ],
            ),
          ),
          const Divider(color: SpotifyTheme.border, height: 1),

          // Toplam Temettü Gösterge Kartı
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: SpotifyTheme.cardSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SpotifyTheme.green.withValues(alpha: 0.3), width: 1.2),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'TOPLAM ELDE EDİLEN TEMETTÜ',
                        style: TextStyle(
                          color: SpotifyTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        currencyFormatter.format(totalDiv),
                        style: const TextStyle(
                          color: SpotifyTheme.green,
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: SpotifyTheme.background,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SpotifyTheme.border),
                    ),
                    child: Text(
                      '${widget.provider.dividends.length} Dağıtım',
                      style: const TextStyle(
                        color: SpotifyTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Manuel Ekleme Formu
          if (_isAdding)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'YENİ TEMETTÜ GİRİŞİ',
                        style: TextStyle(
                          color: SpotifyTheme.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Sembol & Öneriler
                      TextFormField(
                        controller: _symbolController,
                        style: const TextStyle(color: SpotifyTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Hisse Kodu (Örn: TUPRS, EREGL)',
                          labelStyle: const TextStyle(color: SpotifyTheme.textSecondary),
                          prefixIcon: const Icon(Icons.search, color: SpotifyTheme.green),
                          filled: true,
                          fillColor: SpotifyTheme.cardSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) => (val == null || val.trim().isEmpty) ? 'Hisse kodu girin' : null,
                      ),
                      if (_suggestions.isNotEmpty)
                        Container(
                          margin: const EdgeInsets.only(top: 4),
                          constraints: const BoxConstraints(maxHeight: 140),
                          decoration: BoxDecoration(
                            color: SpotifyTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: SpotifyTheme.border),
                          ),
                          child: ListView.builder(
                            shrinkWrap: true,
                            itemCount: _suggestions.length,
                            itemBuilder: (context, i) {
                              final item = _suggestions[i];
                              return ListTile(
                                dense: true,
                                title: Text(item.symbol, style: const TextStyle(color: SpotifyTheme.green, fontWeight: FontWeight.bold)),
                                subtitle: Text(item.name, style: const TextStyle(color: SpotifyTheme.textSecondary, fontSize: 11)),
                                onTap: () => _selectSuggestion(item),
                              );
                            },
                          ),
                        ),
                      const SizedBox(height: 12),

                      // Net Temettü Tutarı
                      TextFormField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(color: SpotifyTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Net Temettü Tutarı (₺)',
                          labelStyle: const TextStyle(color: SpotifyTheme.textSecondary),
                          prefixIcon: const Icon(Icons.attach_money_rounded, color: SpotifyTheme.green),
                          filled: true,
                          fillColor: SpotifyTheme.cardSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) return 'Tutar girin';
                          final n = double.tryParse(val.replaceAll(',', '.'));
                          if (n == null || n <= 0) return 'Geçerli bir tutar girin';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),

                      // Aracı Kurum Seçimi
                      Row(
                        children: [
                          Expanded(
                            child: _buildBrokerChoice('Midas'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildBrokerChoice('Ziraat'),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildBrokerChoice('Diğer'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Not / Açıklama
                      TextFormField(
                        controller: _noteController,
                        style: const TextStyle(color: SpotifyTheme.textPrimary),
                        decoration: InputDecoration(
                          labelText: 'Açıklama (Opsiyonel)',
                          labelStyle: const TextStyle(color: SpotifyTheme.textSecondary),
                          filled: true,
                          fillColor: SpotifyTheme.cardSurface,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 48,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: SpotifyTheme.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: _submitAdd,
                          child: const Text(
                            'Temettüyü Kaydet',
                            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            // Temettü Listesi
            Expanded(
              child: widget.provider.dividends.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.savings_outlined, color: SpotifyTheme.textSecondary, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Henüz temettü geliri kaydedilmedi.',
                            style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 14),
                          ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() {
                                _isAdding = true;
                              });
                            },
                            icon: const Icon(Icons.add, color: SpotifyTheme.green),
                            label: const Text('Manuel Temettü Ekle', style: TextStyle(color: SpotifyTheme.green)),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: widget.provider.dividends.length,
                      itemBuilder: (context, index) {
                        final div = widget.provider.dividends[index];
                        return Dismissible(
                          key: Key(div.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: SpotifyTheme.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.delete_outline, color: Colors.white),
                          ),
                          onDismissed: (_) {
                            widget.provider.removeDividend(div.id);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: SpotifyTheme.cardSurface,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: SpotifyTheme.border, width: 0.8),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: SpotifyTheme.background,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: SpotifyTheme.border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      div.symbol,
                                      style: const TextStyle(
                                        color: SpotifyTheme.green,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        div.companyName,
                                        style: const TextStyle(
                                          color: SpotifyTheme.textPrimary,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 13,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${dateFormatter.format(div.date)} • ${div.broker}',
                                        style: const TextStyle(
                                          color: SpotifyTheme.textSecondary,
                                          fontSize: 11,
                                        ),
                                      ),
                                      if (div.note.isNotEmpty) ...[
                                        const SizedBox(height: 2),
                                        Text(
                                          div.note,
                                          style: TextStyle(
                                            color: SpotifyTheme.textSecondary.withValues(alpha: 0.8),
                                            fontSize: 10.5,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                                Text(
                                  '+${currencyFormatter.format(div.amount)}',
                                  style: const TextStyle(
                                    color: SpotifyTheme.green,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
        ],
      ),
    );
  }

  Widget _buildBrokerChoice(String broker) {
    final isSel = _selectedBroker == broker;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedBroker = broker;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSel ? SpotifyTheme.green.withValues(alpha: 0.15) : SpotifyTheme.cardSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: isSel ? SpotifyTheme.green : SpotifyTheme.border),
        ),
        child: Center(
          child: Text(
            broker,
            style: TextStyle(
              color: isSel ? SpotifyTheme.green : SpotifyTheme.textSecondary,
              fontWeight: isSel ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
