import 'package:flutter/material.dart';

/// 악보 앱 — 종이(크림)와 잉크(짙은 남색) 느낌. 악보가 주인공이라 색은 절제한다.
class AppTheme {
  static const ink = Color(0xFF1F2A44);
  static const paper = Color(0xFFFBF8F1);
  static const accent = Color(0xFFC0533A); // 강조 — 붉은 연필

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(seedColor: ink, brightness: Brightness.light, surface: paper, primary: ink, tertiary: accent);
    return ThemeData(
      colorScheme: scheme,
      scaffoldBackgroundColor: paper,
      appBarTheme: const AppBarTheme(backgroundColor: paper, foregroundColor: ink, elevation: 0, centerTitle: false),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52))),
    );
  }

  static ThemeData dark() {
    final scheme = ColorScheme.fromSeed(seedColor: ink, brightness: Brightness.dark, tertiary: const Color(0xFFE88A6F));
    return ThemeData(
      colorScheme: scheme,
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(56), textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52))),
    );
  }
}
