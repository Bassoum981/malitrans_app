import 'package:flutter/material.dart';

abstract final class AppColors {
  static const navy = Color(0xFF0B1B2F);
  static const navySoft = Color(0xFF132B47);
  static const coral = Color(0xFFFF795C);
  static const mint = Color(0xFFB9E8C2);
  static const paper = Color(0xFFF4F7FB);
  static const ink = Color(0xFF10253D);
  static const muted = Color(0xFF60748A);
}

abstract final class AppTheme {
  static ThemeData get light => _buildTheme(
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.paper,
    surfaceColor: Colors.white,
    foregroundColor: AppColors.ink,
  );

  static ThemeData get dark => _buildTheme(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.navy,
    surfaceColor: AppColors.navySoft,
    foregroundColor: Colors.white,
  );

  static ThemeData _buildTheme({
    required Brightness brightness,
    required Color scaffoldBackgroundColor,
    required Color surfaceColor,
    required Color foregroundColor,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.coral,
      brightness: brightness,
      surface: surfaceColor,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme.copyWith(
        primary: AppColors.coral,
        onPrimary: Colors.white,
        secondary: AppColors.mint,
        surface: surfaceColor,
      ),
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      fontFamily: 'Arial',
      appBarTheme: AppBarTheme(
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: foregroundColor,
        elevation: 0,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.dark
            ? Colors.white.withValues(alpha: .06)
            : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: foregroundColor.withValues(alpha: .16)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide(color: foregroundColor.withValues(alpha: .16)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: AppColors.coral, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 17,
        ),
      ),
    );
  }
}
