import 'package:flutter/material.dart';

import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: .fromSeed(seedColor: AppColors.seedColor, brightness: .light),
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(elevation: 1, margin: .all(8)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: .circular(12)),
      contentPadding: const .symmetric(horizontal: 16, vertical: 12),
    ),
  );

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    colorScheme: .fromSeed(seedColor: AppColors.seedColor, brightness: .dark),
    fontFamily: 'Cairo',
    appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
    cardTheme: const CardThemeData(elevation: 1, margin: .all(8)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(borderRadius: .circular(12)),
      contentPadding: const .symmetric(horizontal: 16, vertical: 12),
    ),
  );
}
