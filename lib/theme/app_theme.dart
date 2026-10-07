import 'package:flutter/material.dart';

class AppTheme {
  // Gamer-focused Dark Palette
  static const Color background = Color(0xFF0B0E14);
  static const Color surface = Color(0xFF141923);
  static const Color surfaceElevated = Color(0xFF1C2230);
  static const Color surfaceBorder = Color(0xFF283145);

  // Neon & Accent Colors
  static const Color neonGreen = Color(0xFF00FF87);
  static const Color neonGreenDark = Color(0xFF00B359);
  static const Color neonCyan = Color(0xFF00E5FF);
  static const Color accentPurple = Color(0xFF7C4DFF);

  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);
  static const Color priceCrossed = Color(0xFF64748B);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonCyan,
        surface: surface,
        onPrimary: Colors.black,
        onSurface: textPrimary,
      ),
      fontFamily: 'Roboto',
      appBarTheme: const AppBarTheme(
        backgroundColor: background,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: const BorderSide(color: surfaceBorder, width: 1),
        ),
      ),
    );
  }
}
