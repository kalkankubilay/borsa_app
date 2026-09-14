import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import '../providers/portfolio_provider.dart';
import '../services/statement_parser_service.dart';
import '../theme/spotify_theme.dart';
import '../models/portfolio_asset.dart';

class StatementImportModal extends StatefulWidget {
  final PortfolioProvider provider;

  const StatementImportModal({super.key, required this.provider});

  static Future<void> show(BuildContext context, PortfolioProvider provider) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatementImportModal(provider: provider),
    );
  }

  @override
  State<StatementImportModal> createState() => _StatementImportModalState();
}

class _StatementImportModalState extends State<StatementImportModal> {
  bool _isLoading = false;
  String? _fileName;
  ParsedStatementResult? _parsedResult;
  String? _errorMessage;

  Future<void> _pickAndParsePdf() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (files.isNotEmpty) {
        final file = files.first;
        _fileName = file.name;

        final Uint8List bytes = await file.readAsBytes();
        final parsed = StatementParserService.parsePdfBytes(bytes);
        setState(() {
          _parsedResult = parsed;
          _isLoading = false;
        });
        return;
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'PDF ayrıştırılırken hata oluştu: $e';
        _isLoading = false;
      });
    }
  }

  /// Örnek Midas ekstresini doğrudan simüle edip test edebilmek için demo yükleyici
  void _loadSampleMidasData() {
    const sampleText = '''
PORTFÖY ÖZETİ (31/08/23)
TTKOM - Türk Telekomünikasyo... 5 16,81 TRY 44,35 TRY 128,40 TRY
THYAO - Türk Hava Yolları 4 187,57 TRY 229,72 TRY 980,00 TRY
SISE - Türkiye Şişe ve Cam... 24 43,42 TRY 187,92 TRY 1230,00 TRY
TUPRS - Türkiye Petrol Rafin... 2 106,50 TRY 69,20 TRY 282,20 TRY
ASELS - Aselsan 6 26,40 TRY 72,72 TRY 231,12 TRY

YATIRIM İŞLEMLERİ (01/08/23 - 31/08/23)
07/08/23 10:36:40 Piyasa Emri TUPRS Alış Gerçekleşti TRY 2 - 2 106,50 0,09 213,00
''';

    final parsed = StatementParserService.parseMidasText(sampleText);
    setState(() {
      _fileName = 'Ornek_Midas_Ekstresi.pdf';
      _parsedResult = parsed;
    });
  }

  void _applyToPortfolio() {
    if (_parsedResult != null) {
      widget.provider.importStatementAssets(
        _parsedResult!.summaryAssets,
        _parsedResult!.transactions,
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
                '${_parsedResult!.summaryAssets.length} adet hisse portföyünüze aktarıldı!',
                style: const TextStyle(color: SpotifyTheme.textPrimary),
              ),
            ],
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'tr_TR', symbol: '₺', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: SpotifyTheme.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(top: BorderSide(color: SpotifyTheme.border, width: 1.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
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

          // Modal Title
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ekstre Yükle & Ayrıştır',
                    style: TextStyle(
                      color: SpotifyTheme.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Midas ve Ziraat Borsa PDF Desteği',
                    style: TextStyle(
                      color: SpotifyTheme.textMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded, color: SpotifyTheme.textSecondary),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Upload Area or Parsed Overview
          if (_parsedResult == null) ...[
            GestureDetector(
              onTap: _isLoading ? null : _pickAndParsePdf,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                decoration: BoxDecoration(
                  color: SpotifyTheme.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: SpotifyTheme.border, style: BorderStyle.solid),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: SpotifyTheme.green.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: _isLoading
                          ? const Padding(
                              padding: EdgeInsets.all(14),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: SpotifyTheme.green,
                              ),
                            )
                          : const Icon(Icons.picture_as_pdf_rounded, color: SpotifyTheme.green, size: 28),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'PDF Ekstrenizi Seçin',
                      style: TextStyle(
                        color: SpotifyTheme.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Midas veya Ziraat PDF dosyasını buraya yükleyin',
                      style: TextStyle(color: SpotifyTheme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            // Demo Button
            Center(
              child: TextButton.icon(
                onPressed: _loadSampleMidasData,
                icon: const Icon(Icons.flash_on_rounded, color: SpotifyTheme.gold, size: 16),
                label: const Text(
                  'Örnek Midas Ekstresini Test Et',
                  style: TextStyle(color: SpotifyTheme.gold, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: SpotifyTheme.red, fontSize: 12),
                ),
              ),
          ] else ...[
            // Successfully Parsed Info
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: SpotifyTheme.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: SpotifyTheme.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_rounded, color: SpotifyTheme.green, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileName ?? 'Ekstre',
                          style: const TextStyle(
                            color: SpotifyTheme.textPrimary,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                        Text(
                          '${_parsedResult!.summaryAssets.length} Hisse Pozisyonu • ${_parsedResult!.transactions.length} İşlem Ayrıştırıldı',
                          style: const TextStyle(color: SpotifyTheme.textMuted, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _parsedResult = null;
                        _fileName = null;
                      });
                    },
                    child: const Text('Değiştir', style: TextStyle(color: SpotifyTheme.textSecondary, fontSize: 12)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 14),
            const Text(
              'Ayrıştırılan Pozisyonlar (Önizleme):',
              style: TextStyle(
                color: SpotifyTheme.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),

            // Asset List Preview
            Expanded(
              child: ListView.builder(
                itemCount: _parsedResult!.summaryAssets.length,
                itemBuilder: (context, index) {
                  final asset = _parsedResult!.summaryAssets[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: SpotifyTheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: SpotifyTheme.border),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: SpotifyTheme.surfaceElevated,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            asset.market == AssetMarket.tr ? '🇹🇷 BIST' : '🇺🇸 ABD',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: SpotifyTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                asset.symbol,
                                style: const TextStyle(
                                  color: SpotifyTheme.textPrimary,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              Text(
                                '${asset.quantity} Adet • Maliyet: ${currencyFormatter.format(asset.buyPrice)}',
                                style: const TextStyle(color: SpotifyTheme.textMuted, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          currencyFormatter.format(asset.totalCurrentValue),
                          style: const TextStyle(
                            color: SpotifyTheme.green,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),
            // Apply Button
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: SpotifyTheme.green,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  elevation: 0,
                ),
                onPressed: _applyToPortfolio,
                child: const Text(
                  'Portföyüme Aktar',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
