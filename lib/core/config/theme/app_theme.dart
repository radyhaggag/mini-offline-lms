import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Application theme definitions for light and dark modes.
abstract class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: .fromSeed(
      seedColor: AppColors.seedColor,
      brightness: .light,
      surface: AppColors.surfaceLight,
    ),
    scaffoldBackgroundColor: AppColors.backgroundLight,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backgroundLight,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.surfaceLight,
      margin: .zero,
    ),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: .circular(12)),
      contentPadding: const .symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    colorScheme: .fromSeed(
      seedColor: AppColors.seedColor,
      brightness: .dark,
      surface: AppColors.surfaceDark,
    ),
    scaffoldBackgroundColor: AppColors.backgroundDark,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: AppColors.backgroundDark,
      centerTitle: false,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,
      color: AppColors.surfaceDark,
      margin: .zero,
    ),
    dividerTheme: const DividerThemeData(thickness: 1, space: 1),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: .circular(12)),
      contentPadding: const .symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
