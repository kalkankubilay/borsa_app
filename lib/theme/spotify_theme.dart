import 'package:flutter/material.dart';

class SpotifyTheme {
  // Deep Spotify Dark Colors
  static const Color background = Color(0xFF121212);
  static const Color surface = Color(0xFF181818);
  static const Color surfaceElevated = Color(0xFF242424);
  static const Color activePill = Color(0xFFFFFFFF);
  static const Color inactivePill = Color(0xFF282828);
  
  static const Color border = Color(0xFF2E2E2E);
  static const Color borderLight = Color(0x1FFFFFFF);

  // Accents
  static const Color green = Color(0xFF1DB954); // Spotify Emerald
  static const Color greenTint = Color(0x201DB954);
  static const Color red = Color(0xFFF15E6C);   // Loss crimson
  static const Color redTint = Color(0x20F15E6C);
  
  static const Color gold = Color(0xFFF59E0B);
  static const Color blue = Color(0xFF3B82F6);
  static const Color turquoise = Color(0xFF06B6D4);

  // Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFA7A7A7);
  static const Color textMuted = Color(0xFF727272);

  static ThemeData get themeData {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        background: background,
        surface: surface,
        primary: green,
        secondary: blue,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
