import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../services/statement_parser_service.dart';
import '../theme/spotify_theme.dart';
import '../models/portfolio_asset.dart';
import '../services/stock_directory_service.dart';

class AddAssetModal extends StatefulWidget {
  final PortfolioProvider provider;
  final AssetMarket? targetMarket;

  const AddAssetModal({
    super.key,
    required this.provider,
    this.targetMarket,
  });

  static Future<void> show(
    BuildContext context,
    PortfolioProvider provider, {
    AssetMarket? targetMarket,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AddAssetModal(
        provider: provider,
        targetMarket: targetMarket,
      ),
    );
  }

  @override
  State<AddAssetModal> createState() => _AddAssetModalState();
}

class _AddAssetModalState extends State<AddAssetModal> {
  final _formKey = GlobalKey<FormState>();

  final _symbolController = TextEditingController();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _buyPriceController = TextEditingController();
  final _currentPriceController = TextEditingController();

  DateTime _selectedDate = DateTime.now();
  AssetMarket? _selectedMarket;
  bool _isAutoDetected = true;
  List<StockSuggestion> _suggestions = [];

  @override
  void initState() {
    super.initState();
    if (widget.targetMarket != null) {
      _selectedMarket = widget.targetMarket;
      _isAutoDetected = false;
    }
    _symbolController.addListener(_onSymbolChanged);
  }

  @override
  void dispose() {
    _symbolController.dispose();
    _nameController.dispose();
    _quantityController.dispose();
    _buyPriceController.dispose();
    _currentPriceController.dispose();
    super.dispose();
  }

  void _onSymbolChanged() {
    final sym = _symbolController.text.trim();
    if (sym.isNotEmpty) {
      // Eğer sekme kısıtlaması varsa sadece o piyasadaki hisseleri öner
      final marketFilter = widget.targetMarket ?? _selectedMarket;
      final results = StockDirectoryService.search(sym, marketFilter: marketFilter);
      setState(() {
        _suggestions = results;
      });

      if (_isAutoDetected && widget.targetMarket == null) {
        final detected = StatementParserService.detectMarket(sym, 'TRY');
        setState(() {
          _selectedMarket = detected;
        });
      }
    } else {
      setState(() {
        _suggestions = [];
      });
    }
  }

  void _selectSuggestion(StockSuggestion suggestion) {
    setState(() {
      _symbolController.text = suggestion.symbol;
      _nameController.text = suggestion.name;
      _selectedMarket = suggestion.market;
      _isAutoDetected = false;
      _suggestions = []; // Menüyü kapat
    });
  }

  // Hesaplanan toplam maliyet tutarı
  double get _calculatedTotalCost {
    final qty = double.tryParse(_quantityController.text.replaceAll(',', '.')) ?? 0.0;
    final price = double.tryParse(_buyPriceController.text.replaceAll(',', '.')) ?? 0.0;
    return qty * price;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final symbol = _symbolController.text.trim().toUpperCase();
    final name = _nameController.text.trim();
    final quantity = double.parse(_quantityController.text.replaceAll(',', '.'));
    final buyPrice = double.parse(_buyPriceController.text.replaceAll(',', '.'));

    double? curPrice;
    if (_currentPriceController.text.trim().isNotEmpty) {
      curPrice = double.tryParse(_currentPriceController.text.replaceAll(',', '.'));
    }

    final market = _selectedMarket ?? StatementParserService.detectMarket(symbol, 'TRY');

    widget.provider.addManualAsset(
      symbol: symbol,
      name: name.isNotEmpty ? name : symbol,
      market: market,
      quantity: quantity,
      buyPrice: buyPrice,
      currentPrice: curPrice ?? buyPrice,
      buyDate: _selectedDate,
      unitLabel: market == AssetMarket.gold ? 'Gram' : 'Adet',
    );

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: SpotifyTheme.surfaceElevated,
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: SpotifyTheme.green, size: 20),
            const SizedBox(width: 10),
            Text(
              '$symbol (${market.label}) portföyünüze eklendi!',
              style: const TextStyle(color: SpotifyTheme.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeMarket = _selectedMarket ?? AssetMarket.tr;
    final currencySymbol = activeMarket.currencySymbol;
    final dateFormatter = DateFormat('dd.MM.yyyy');

    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 18,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: SpotifyTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: SpotifyTheme.border, width: 1.2)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Center(
                child: Container(
                  width: 38,
                  height: 4,
                  decoration: BoxDecoration(
                    color: SpotifyTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Yeni Varlık Ekle',
                    style: TextStyle(
                      color: SpotifyTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: SpotifyTheme.textSecondary),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 1. Piyasa Seçici (Pill Segment) - Sadece 'Tümü' sekmesindeyken gösterilir
              if (widget.targetMarket == null) ...[
                const Text(
                  'Piyasa / Varlık Türü:',
                  style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Row(
                  children: AssetMarket.values.map((market) {
                    final isSelected = activeMarket == market;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedMarket = market;
                            _isAutoDetected = false;
                            _suggestions = StockDirectoryService.search(_symbolController.text, marketFilter: market);
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? SpotifyTheme.green.withOpacity(0.2) : SpotifyTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? SpotifyTheme.green : SpotifyTheme.border,
                              width: isSelected ? 1.5 : 1,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            market.label,
                            style: TextStyle(
                              color: isSelected ? SpotifyTheme.green : SpotifyTheme.textSecondary,
                              fontSize: 11,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ] else ...[
                // Belirli bir sekmedeyken kilitli piyasa rozeti
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: SpotifyTheme.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: SpotifyTheme.green, size: 16),
                      const SizedBox(width: 8),
                      Text(
                        'Eklenen Piyasa: ${widget.targetMarket!.label}',
                        style: const TextStyle(
                          color: SpotifyTheme.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // 2. Sembol & İsim
              Row(
                children: [
                  Expanded(
                    flex: 4,
                    child: _buildTextField(
                      controller: _symbolController,
                      label: 'Sembol / Kod',
                      hint: 'Örn: SISE, AAPL',
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Gereklidir' : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 6,
                    child: _buildTextField(
                      controller: _nameController,
                      label: 'Varlık Adı (Opsiyonel)',
                      hint: 'Örn: Şişecam',
                    ),
                  ),
                ],
              ),

              // Canlı Öneri Dropdown Listesi
              if (_suggestions.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  constraints: const BoxConstraints(maxHeight: 180),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.surfaceElevated,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SpotifyTheme.border),
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(color: SpotifyTheme.border, height: 1),
                    itemBuilder: (context, index) {
                      final item = _suggestions[index];
                      return ListTile(
                        dense: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                        title: Row(
                          children: [
                            Text(
                              item.symbol,
                              style: const TextStyle(
                                color: SpotifyTheme.textPrimary,
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: SpotifyTheme.surface,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                item.market == AssetMarket.tr
                                    ? 'BIST'
                                    : item.market == AssetMarket.us
                                        ? 'US'
                                        : 'ALTIN',
                                style: TextStyle(
                                  color: item.market == AssetMarket.tr
                                      ? SpotifyTheme.green
                                      : item.market == AssetMarket.us
                                          ? SpotifyTheme.blue
                                          : SpotifyTheme.gold,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        subtitle: Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: SpotifyTheme.textMuted, fontSize: 11),
                        ),
                        trailing: const Icon(Icons.north_west_rounded, size: 14, color: SpotifyTheme.textMuted),
                        onTap: () => _selectSuggestion(item),
                      );
                    },
                  ),
                ),
              ],
              const SizedBox(height: 14),

              // 3. Adet & Alış Fiyatı
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _quantityController,
                      label: activeMarket == AssetMarket.gold ? 'Miktar (Gram/Pay)' : 'Adet (Lot)',
                      hint: 'Örn: 50',
                      keyboardType: const TextInputKeypad(),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Gereklidir';
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Geçersiz';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _buyPriceController,
                      label: 'Alış Fiyatı ($currencySymbol)',
                      hint: 'Örn: 485.50',
                      keyboardType: const TextInputKeypad(),
                      onChanged: (_) => setState(() {}),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Gereklidir';
                        final n = double.tryParse(v.replaceAll(',', '.'));
                        if (n == null || n <= 0) return 'Geçersiz';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // 4. Güncel Fiyat & Alış Tarihi
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _currentPriceController,
                      label: 'Anlık Fiyat (Opsiyonel)',
                      hint: 'Boşsa alış fiyatı alınır',
                      keyboardType: const TextInputKeypad(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Alış Tarihi',
                          style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 6),
                        GestureDetector(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: _selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() {
                                _selectedDate = picked;
                              });
                            }
                          },
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: SpotifyTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: SpotifyTheme.border),
                            ),
                            alignment: Alignment.centerLeft,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  dateFormatter.format(_selectedDate),
                                  style: const TextStyle(color: SpotifyTheme.textPrimary, fontSize: 13),
                                ),
                                const Icon(Icons.calendar_today_rounded, color: SpotifyTheme.textMuted, size: 16),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // Otomatik Hesaplanan Toplam Tutar Özeti
              if (_calculatedTotalCost > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: SpotifyTheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: SpotifyTheme.border),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Toplam Alış Maliyeti:',
                        style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 13),
                      ),
                      Text(
                        NumberFormat.currency(locale: 'tr_TR', symbol: currencySymbol, decimalDigits: 2)
                            .format(_calculatedTotalCost),
                        style: const TextStyle(
                          color: SpotifyTheme.green,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 20),

              // Kaydet Butonu
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: SpotifyTheme.green,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                    elevation: 0,
                  ),
                  onPressed: _submit,
                  child: const Text(
                    'Portföyüme Ekle',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    ValueChanged<String>? onChanged,
    FormFieldValidator<String>? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: SpotifyTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          onChanged: onChanged,
          validator: validator,
          style: const TextStyle(color: SpotifyTheme.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: SpotifyTheme.textMuted, fontSize: 13),
            filled: true,
            fillColor: SpotifyTheme.surface,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SpotifyTheme.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SpotifyTheme.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: SpotifyTheme.green, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}

class TextInputKeypad extends TextInputType {
  const TextInputKeypad() : super.numberWithOptions(decimal: true);
}
