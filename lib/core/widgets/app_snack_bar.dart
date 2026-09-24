import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';

/// Semantic types of messages displayed by [AppSnackBar].
enum AppSnackBarType { info, success, warning, error }

/// Unified, beautifully styled floating SnackBar matching the app theme.
abstract class AppSnackBar {
  /// Displays a floating snackbar with custom branding, icon, and dismiss action.
  static void show(
    BuildContext context, {
    required String message,
    AppSnackBarType type = AppSnackBarType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final (defaultIcon, accentColor) = switch (type) {
      .info => (Icons.info_outline_rounded, colors.primary),
      .success => (Icons.check_circle_outline_rounded, colors.primary),
      .warning => (Icons.lock_outline_rounded, colors.tertiary),
      .error => (Icons.error_outline_rounded, colors.error),
    };

    final effectiveIcon = icon ?? defaultIcon;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.transparent,
          elevation: 0,
          padding: .zero,
          duration: duration,
          margin: const .symmetric(horizontal: 16, vertical: 12),
          content: Container(
            padding: const .symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: colors.surfaceContainerHighest,
              borderRadius: .circular(16),
              border: Border.all(
                color: accentColor.withValues(alpha: 0.35),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              spacing: 12,
              children: [
                Container(
                  padding: const .all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(effectiveIcon, color: accentColor, size: 20),
                ),
                Expanded(
                  child: Text(
                    message,
                    style: texts.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: .w600,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
  }

  /// Convenience helper to display a warning SnackBar.
  static void showWarning(BuildContext context, {required String message}) =>
      show(context, message: message, type: .warning);

  /// Convenience helper to display an error SnackBar.
  static void showError(BuildContext context, {required String message}) =>
      show(context, message: message, type: .error);

  /// Convenience helper to display a success SnackBar.
  static void showSuccess(BuildContext context, {required String message}) =>
      show(context, message: message, type: .success);

  /// Convenience helper to display an informative SnackBar.
  static void showInfo(BuildContext context, {required String message}) =>
      show(context, message: message, type: .info);
}
