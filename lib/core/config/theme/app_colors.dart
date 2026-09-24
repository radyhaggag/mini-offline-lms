import 'package:flutter/material.dart';

/// Centralized color constants for theme generation.
/// Widgets should reference colors via `context.colorScheme`.
abstract class AppColors {
  /// Medical Teal seed color.
  static const seedColor = Color(0xFF007A78);

  // Light theme foundation (Slate 50)
  static const backgroundLight = Color(0xFFF8FAFC);
  static const surfaceLight = Color(0xFFFFFFFF);

  // Dark theme foundation (Slate 900 & Slate 800)
  static const backgroundDark = Color(0xFF0B132B);
  static const surfaceDark = Color(0xFF1C2541);
}
