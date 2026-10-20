/// Light brand theme: navy + gold on clean light surfaces.
library;

import 'package:flutter/material.dart';

class AppTheme {
  static const navy = Color(0xFF1A237E);
  static const navyDark = Color(0xFF0D1330);
  static const gold = Color(0xFFFFB300);
  static const goldLight = Color(0xFFFFD54F);

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: navy,
      primary: navy,
      secondary: gold,
      brightness: Brightness.light,
    );
    return ThemeData(
      colorScheme: scheme,
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFF6F7FB),
      appBarTheme: const AppBarTheme(
        backgroundColor: navy,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: gold,
          foregroundColor: navyDark,
          textStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9DCE8)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD9DCE8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: navy, width: 2),
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
