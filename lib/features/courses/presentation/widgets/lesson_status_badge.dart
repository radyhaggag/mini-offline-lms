import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/lesson.dart';

/// Pill badge indicating lesson status with color-coded label and icon.
class LessonStatusBadge extends StatelessWidget {
  const LessonStatusBadge({super.key, required this.lesson});

  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final (label, icon, bgColor, fgColor) = switch (lesson) {
      _ when lesson.isLocked => (
        context.tr('locked'),
        Icons.lock_rounded,
        colors.surfaceContainerHighest.withValues(alpha: 0.6),
        colors.onSurfaceVariant,
      ),
      _ when lesson.isCompleted => (
        context.tr('completed'),
        Icons.check_circle_rounded,
        colors.primaryContainer.withValues(alpha: 0.8),
        colors.primary,
      ),
      _ when lesson.status == .inProgress => (
        context.tr('inProgress'),
        Icons.timelapse_rounded,
        colors.tertiaryContainer.withValues(alpha: 0.8),
        colors.onTertiaryContainer,
      ),
      _ => (
        context.tr('notStarted'),
        Icons.radio_button_unchecked_rounded,
        colors.surfaceContainerHighest.withValues(alpha: 0.35),
        colors.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const .symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bgColor, borderRadius: .circular(8)),
      child: Row(
        mainAxisSize: .min,
        spacing: 4,
        children: [
          Icon(icon, size: 12, color: fgColor),
          Text(
            label,
            style: texts.labelSmall?.copyWith(
              color: fgColor,
              fontWeight: .bold,
            ),
          ),
        ],
      ),
    );
  }
}
