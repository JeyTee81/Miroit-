import 'package:flutter/material.dart';

class AppTheme {
  // Couleurs du design
  static const Color primaryDark = Color(0xFF2C2C2C); // Gris foncé sidebar
  static const Color primaryLight = Color(0xFFF5F5F5); // Gris clair contenu
  static const Color activeItemBg = Color(0xFF3A3A3A); // Fond item actif
  static const Color activeTabBg = Color(0xFF4A4A4A); // Fond tab actif
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF1A1A1A);
  static const Color textGrey = Color(0xFF6B6B6B);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryDark,
      brightness: Brightness.light,
      primary: primaryDark,
      surface: primaryLight,
    ),
    scaffoldBackgroundColor: primaryLight,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: primaryDark,
      foregroundColor: textWhite,
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: primaryLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    ),
  );
}

