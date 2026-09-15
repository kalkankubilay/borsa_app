import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/portfolio_asset.dart';
import '../models/trade_transaction.dart';
import '../models/dividend_income.dart';

class MockPortfolioData {
  static const double usdToTry = 34.25;

  static List<PortfolioAsset> assets = [
    // --- TR Borsası (BIST) ---
    PortfolioAsset(
      id: '1',
      symbol: 'THYAO',
      name: 'Türk Hava Yolları',
      market: AssetMarket.tr,
      quantity: 45,
      buyPrice: 265.40,
      currentPrice: 310.20,
      buyDate: DateTime(2024, 1, 15),
    ),
    PortfolioAsset(
      id: '2',
      symbol: 'ASELS',
      name: 'Aselsan Elektronik',
      market: AssetMarket.tr,
      quantity: 120,
      buyPrice: 54.20,
      currentPrice: 68.30,
      buyDate: DateTime(2024, 2, 10),
    ),
    PortfolioAsset(
      id: '3',
      symbol: 'TUPRS',
      name: 'Tüpraş Rafinerileri',
      market: AssetMarket.tr,
      quantity: 85,
      buyPrice: 162.00,
      currentPrice: 186.00,
      buyDate: DateTime(2024, 3, 5),
    ),
    PortfolioAsset(
      id: '4',
      symbol: 'BIMAS',
      name: 'BİM Mağazalar',
      market: AssetMarket.tr,
      quantity: 30,
      buyPrice: 520.00,
      currentPrice: 495.00,
      buyDate: DateTime(2024, 4, 1),
    ),

    // --- ABD Borsası (US Stocks) ---
    PortfolioAsset(
      id: '5',
      symbol: 'AAPL',
      name: 'Apple Inc.',
      market: AssetMarket.us,
      quantity: 25,
      buyPrice: 175.50,
      currentPrice: 224.20,
      buyDate: DateTime(2023, 11, 20),
    ),
    PortfolioAsset(
      id: '6',
      symbol: 'NVDA',
      name: 'NVIDIA Corporation',
      market: AssetMarket.us,
      quantity: 40,
      buyPrice: 88.00,
      currentPrice: 128.50,
      buyDate: DateTime(2024, 1, 10),
    ),
    PortfolioAsset(
      id: '7',
      symbol: 'MSFT',
      name: 'Microsoft Corp.',
      market: AssetMarket.us,
      quantity: 15,
      buyPrice: 390.00,
      currentPrice: 425.00,
      buyDate: DateTime(2024, 2, 18),
    ),

    // --- Altın & Emtia (Gold) ---
    PortfolioAsset(
      id: '8',
      symbol: 'ALTIN.G',
      name: 'Fiziki Has Gram Altın',
      market: AssetMarket.gold,
      quantity: 65,
      buyPrice: 2450.00,
      currentPrice: 2890.00,
      buyDate: DateTime(2023, 10, 5),
      unitLabel: 'Gram',
    ),
    PortfolioAsset(
      id: '9',
      symbol: 'ALTINS1',
      name: 'Darphane Altın Sertifikası',
      market: AssetMarket.gold,
      quantity: 3500,
      buyPrice: 24.10,
      currentPrice: 29.35,
      buyDate: DateTime(2024, 3, 12),
      unitLabel: 'Pay',
    ),
  ];
}

class PortfolioProvider extends ChangeNotifier {
  static const String _storageKey = 'saved_portfolio_assets';
  static const String _dividendStorageKey = 'saved_portfolio_dividends';
  static const String _initializedKey = 'portfolio_initialized';

  List<PortfolioAsset> _assets = [];
  final List<TradeTransaction> _transactions = [];
  List<DividendIncome> _dividends = [];
  bool _hideBalance = false;
  String _selectedCurrency = 'TRY'; // 'TRY' veya 'USD'

  PortfolioProvider() {
    _loadFromStorage();
  }

  List<PortfolioAsset> get assets => _assets;
  List<TradeTransaction> get transactions => _transactions;
  List<DividendIncome> get dividends => _dividends;
  bool get hideBalance => _hideBalance;
  String get selectedCurrency => _selectedCurrency;

  Future<void> _loadFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isInitialized = prefs.getBool(_initializedKey) ?? false;

      if (!isInitialized) {
        // İlk açılışta mock verilerle başla ve kaydet
        _assets = List.from(MockPortfolioData.assets);
        // Örnek BIST temettü gelirleri
        _dividends = [
          DividendIncome(
            id: 'div_tuprs_1',
            symbol: 'TUPRS',
            companyName: 'Tüpraş Rafinerileri',
            amount: 875.50,
            currency: 'TRY',
            date: DateTime(2024, 3, 28),
            broker: 'Midas',
            note: '1. Taksit Temettü Ödemesi',
          ),
          DividendIncome(
            id: 'div_thyao_1',
            symbol: 'THYAO',
            companyName: 'Türk Hava Yolları',
            amount: 420.00,
            currency: 'TRY',
            date: DateTime(2024, 4, 15),
            broker: 'Midas',
            note: 'Nakit Kâr Payı Dağıtımı',
          ),
          DividendIncome(
            id: 'div_asels_1',
            symbol: 'ASELS',
            companyName: 'Aselsan Elektronik',
            amount: 215.80,
            currency: 'TRY',
            date: DateTime(2024, 5, 22),
            broker: 'Ziraat',
            note: 'Nakit Kâr Payı',
          ),
        ];
        await prefs.setBool(_initializedKey, true);
        await _saveToStorage();
        await _saveDividendsToStorage();
      } else {
        // Daha önce açılmış; kullanıcının kaydettiği veya sildiği listeyi yükle
        final savedJson = prefs.getString(_storageKey);
        if (savedJson != null && savedJson.isNotEmpty) {
          final List<dynamic> decoded = jsonDecode(savedJson);
          _assets = decoded.map((item) => PortfolioAsset.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          _assets = [];
        }

        final divJson = prefs.getString(_dividendStorageKey);
        if (divJson != null && divJson.isNotEmpty) {
          final List<dynamic> divDecoded = jsonDecode(divJson);
          _dividends = divDecoded.map((item) => DividendIncome.fromJson(item as Map<String, dynamic>)).toList();
        } else {
          _dividends = [];
        }
      }
    } catch (e) {
      _assets = [];
      _dividends = [];
    }
    notifyListeners();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_assets.map((a) => a.toJson()).toList());
      await prefs.setString(_storageKey, jsonString);
      await prefs.setBool(_initializedKey, true);
    } catch (_) {}
  }

  Future<void> _saveDividendsToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_dividends.map((d) => d.toJson()).toList());
      await prefs.setString(_dividendStorageKey, jsonString);
    } catch (_) {}
  }

  /// Yeni temettü geliri ekleme (Manuel veya ekstre)
  void addDividend({
    required String symbol,
    required String companyName,
    required double amount,
    String currency = 'TRY',
    required DateTime date,
    String broker = 'Midas',
    String note = '',
  }) {
    _dividends.insert(
      0,
      DividendIncome(
        id: 'div_${DateTime.now().millisecondsSinceEpoch}',
        symbol: symbol.trim().toUpperCase(),
        companyName: companyName.trim().isNotEmpty ? companyName.trim() : symbol.trim().toUpperCase(),
        amount: amount,
        currency: currency,
        date: date,
        broker: broker,
        note: note,
      ),
    );
    _saveDividendsToStorage();
    notifyListeners();
  }

  /// Temettü kaydını silme
  void removeDividend(String id) {
    _dividends.removeWhere((d) => d.id == id);
    _saveDividendsToStorage();
    notifyListeners();
  }

  /// Toplam Temettü Geliri (TRY Cinsinden)
  double get totalDividendIncomeTry {
    return _dividends.fold(0.0, (sum, d) {
      final amt = d.currency == 'USD' ? d.amount * MockPortfolioData.usdToTry : d.amount;
      return sum + amt;
    });
  }

  void toggleHideBalance() {
    _hideBalance = !_hideBalance;
    notifyListeners();
  }

  void setCurrency(String curr) {
    _selectedCurrency = curr;
    notifyListeners();
  }

  /// Manuel olarak yeni bir alım işlemi ekler (aynı hisse varsa ağırlıklı ortalama maliyet hesaplar)
  void addManualAsset({
    required String symbol,
    required String name,
    required AssetMarket market,
    required double quantity,
    required double buyPrice,
    double? currentPrice,
    required DateTime buyDate,
    String unitLabel = 'Adet',
  }) {
    final cleanSymbol = symbol.trim().toUpperCase();
    final effectiveCurrentPrice = currentPrice ?? buyPrice;

    final existingIndex = _assets.indexWhere((a) => a.symbol.toUpperCase() == cleanSymbol);

    if (existingIndex >= 0) {
      // Mevcut pozisyon var: Ağırlıklı ortalama maliyeti ve yeni toplam adedi hesapla
      final existing = _assets[existingIndex];
      final newTotalQty = existing.quantity + quantity;
      final newTotalCost = existing.totalCost + (quantity * buyPrice);
      final newAvgBuyPrice = newTotalQty > 0 ? (newTotalCost / newTotalQty) : buyPrice;

      _assets[existingIndex] = PortfolioAsset(
        id: existing.id,
        symbol: existing.symbol,
        name: existing.name.isNotEmpty ? existing.name : name,
        market: market,
        quantity: newTotalQty,
        buyPrice: newAvgBuyPrice,
        currentPrice: effectiveCurrentPrice > 0 ? effectiveCurrentPrice : existing.currentPrice,
        buyDate: buyDate,
        unitLabel: existing.unitLabel,
      );
    } else {
      // Yeni pozisyon ekle
      _assets.add(
        PortfolioAsset(
          id: 'manual_${cleanSymbol}_${DateTime.now().millisecondsSinceEpoch}',
          symbol: cleanSymbol,
          name: name.isNotEmpty ? name : cleanSymbol,
          market: market,
          quantity: quantity,
          buyPrice: buyPrice,
          currentPrice: effectiveCurrentPrice,
          buyDate: buyDate,
          unitLabel: unitLabel,
        ),
      );
    }

    _saveToStorage();
    notifyListeners();
  }

  /// Ekstreden gelen özet hisseleri ve temettüleri mevcut portföye akıllıca entegre eder
  void importStatementAssets(
    List<PortfolioAsset> importedAssets,
    List<TradeTransaction> importedTxs, {
    List<DividendIncome> importedDividends = const [],
  }) {
    for (var imported in importedAssets) {
      final existingIndex = _assets.indexWhere((a) => a.symbol.toUpperCase() == imported.symbol.toUpperCase());
      if (existingIndex >= 0) {
        _assets[existingIndex] = imported;
      } else {
        _assets.add(imported);
      }
    }
    _transactions.addAll(importedTxs);
    if (importedDividends.isNotEmpty) {
      _dividends.insertAll(0, importedDividends);
      _saveDividendsToStorage();
    }
    _saveToStorage();
    notifyListeners();
  }

  /// Varlığın anlık güncel piyasa fiyatını günceller ve kaydeder
  void updateAssetCurrentPrice(String assetId, double newPrice) {
    final index = _assets.indexWhere((a) => a.id == assetId);
    if (index >= 0) {
      final old = _assets[index];
      _assets[index] = PortfolioAsset(
        id: old.id,
        symbol: old.symbol,
        name: old.name,
        market: old.market,
        quantity: old.quantity,
        buyPrice: old.buyPrice,
        currentPrice: newPrice,
        buyDate: old.buyDate,
        unitLabel: old.unitLabel,
      );
      _saveToStorage();
      notifyListeners();
    }
  }

  /// Tek bir varlığı portföyden siler ve kalıcı hafızaya yazar
  void removeAsset(String assetId) {
    _assets.removeWhere((a) => a.id == assetId);
    _saveToStorage();
    notifyListeners();
  }

  /// Tüm varlıkları sıfırlar (temiz portföy başlatmak için) ve kalıcı hafızaya yazar
  void clearAllAssets() {
    _assets.clear();
    _transactions.clear();
    _saveToStorage();
    notifyListeners();
  }

  // Belirli piyasaya ait varlıklar
  List<PortfolioAsset> assetsForMarket(AssetMarket? market) {
    if (market == null) return _assets;
    return _assets.where((a) => a.market == market).toList();
  }

  // Toplam Maliyet (TRY bazında konsolide)
  double get totalCostTry {
    return _assets.fold(0.0, (sum, asset) {
      final val = asset.totalCost;
      return sum + (asset.market == AssetMarket.us ? val * MockPortfolioData.usdToTry : val);
    });
  }

  // Toplam Piyasa Değeri (TRY bazında konsolide)
  double get totalCurrentValueTry {
    return _assets.fold(0.0, (sum, asset) {
      final val = asset.totalCurrentValue;
      return sum + (asset.market == AssetMarket.us ? val * MockPortfolioData.usdToTry : val);
    });
  }

  // Konsolide Kâr / Zarar
  double get totalProfitLossTry => totalCurrentValueTry - totalCostTry;

  // Konsolide Getiri Yüzdesi
  double get totalProfitLossPercentage {
    if (totalCostTry == 0) return 0.0;
    return (totalProfitLossTry / totalCostTry) * 100;
  }

  // Kategori Bazlı Değerler (TRY)
  double marketTotalValueTry(AssetMarket market) {
    return _assets.where((a) => a.market == market).fold(0.0, (sum, asset) {
      final val = asset.totalCurrentValue;
      return sum + (asset.market == AssetMarket.us ? val * MockPortfolioData.usdToTry : val);
    });
  }

  double marketTotalProfitLossTry(AssetMarket market) {
    final curVal = marketTotalValueTry(market);
    final costVal = _assets.where((a) => a.market == market).fold(0.0, (sum, asset) {
      final val = asset.totalCost;
      return sum + (asset.market == AssetMarket.us ? val * MockPortfolioData.usdToTry : val);
    });
    return curVal - costVal;
  }

  double marketProfitLossPercentage(AssetMarket market) {
    final costVal = _assets.where((a) => a.market == market).fold(0.0, (sum, asset) {
      final val = asset.totalCost;
      return sum + (asset.market == AssetMarket.us ? val * MockPortfolioData.usdToTry : val);
    });
    if (costVal == 0) return 0.0;
    return (marketTotalProfitLossTry(market) / costVal) * 100;
  }
}
