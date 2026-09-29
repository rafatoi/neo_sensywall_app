import 'package:flutter/material.dart';
import 'package:neo_sensywall_app/src/app/theme/app_colors.dart';

abstract final class AppTheme {
  static ThemeData get light => _build(
    brightness: Brightness.light,
    colorScheme: const ColorScheme.light(
      primary: AppColors.lightPrimary,
      onPrimary: AppColors.lightOnPrimary,
      primaryContainer: AppColors.lightPrimaryContainer,
      onPrimaryContainer: Color(0xFF001F25),
      secondary: AppColors.lightSecondary,
      secondaryContainer: AppColors.lightSecondary,
      surface: AppColors.lightBackground,
      onSurface: AppColors.lightOnBackground,
    ),
  );

  static ThemeData get dark => _build(
    brightness: Brightness.dark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.darkPrimary,
      onPrimary: AppColors.darkOnPrimary,
      primaryContainer: AppColors.darkPrimaryContainer,
      onPrimaryContainer: Color(0xFFB4EBFF),
      secondary: AppColors.darkSecondary,
      surface: AppColors.darkBackground,
      onSurface: AppColors.darkOnBackground,
    ),
  );

  static ThemeData _build({
    required Brightness brightness,
    required ColorScheme colorScheme,
  }) {
    return ThemeData(
      brightness: brightness,
      colorScheme: colorScheme,
      useMaterial3: true,
      scaffoldBackgroundColor: colorScheme.surface,
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontSize: 16, height: 1.5, letterSpacing: 0.5),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.primaryContainer,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
