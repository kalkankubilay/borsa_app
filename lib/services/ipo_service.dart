import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ipo_item.dart';

class IpoService {
  static const String _cacheKey = 'cached_safe_upcoming_ipos_v3';

  // Kendi GitHub deponuzdaki raw JSON linki (Kendi deponuzu pushladığınızda bu URL kullanılır)
  static const String _remoteJsonUrl =
      'https://raw.githubusercontent.com/kalkankubilay/borsa_app/main/data/halka_arzlar.json';

  /// 1. Aşama: Uygulama paketi içindeki yerel asset dosyasını oku
  static Future<List<IpoItem>> loadBundledAssetIpos() async {
    try {
      final jsonString = await rootBundle.loadString('data/halka_arzlar.json');
      final List list = jsonDecode(jsonString);
      return list.map((e) => IpoItem.fromJson(e)).toList();
    } catch (_) {
      return [];
    }
  }

  /// 2. Aşama: Cihaz hafızasındaki önbelleği veya asset dosyasını getir (Anında açılış)
  static Future<List<IpoItem>> getCachedOrFallbackIpos() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null && raw.isNotEmpty) {
        final List list = jsonDecode(raw);
        final cached = list.map((e) => IpoItem.fromJson(e)).toList();
        if (cached.isNotEmpty) return cached;
      }
    } catch (_) {}

    // Hafızada yoksa uygulama içindeki json dosyasından yükle
    return await loadBundledAssetIpos();
  }

  /// 3. Aşama: Doğrudan kendi deponuzdan temiz JSON verisini çek ve önbelleğe kaydet
  static Future<List<IpoItem>> fetchLiveIpos() async {
    try {
      final res = await http.get(
        Uri.parse(_remoteJsonUrl),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 5));

      if (res.statusCode == 200) {
        final List list = jsonDecode(utf8.decode(res.bodyBytes));
        final ipos = list.map((e) => IpoItem.fromJson(e)).toList();

        if (ipos.isNotEmpty) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_cacheKey, jsonEncode(ipos.map((e) => e.toJson()).toList()));
          return ipos;
        }
      }
    } catch (_) {}

    // Uzak depoya erişilemezse yerel / önbellek verilerini kullan
    return await getCachedOrFallbackIpos();
  }
}
