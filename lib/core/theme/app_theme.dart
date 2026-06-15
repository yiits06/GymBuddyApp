import 'package:flutter/material.dart';

class AppTheme {
  static const Color neonLime = Color(0xFFD4FF00);
  static const Color darkBackground = Color(0xFF121212);
  static const Color surfaceCard = Color(0xFF1E1E1E);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      primaryColor: neonLime,
      colorScheme: const ColorScheme.dark(
        primary: neonLime,
        surface: surfaceCard,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A1A1A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonLime, width: 1.5),
        ),
      ),
    );
  }
}
