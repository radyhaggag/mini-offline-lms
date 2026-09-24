import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/duration_extensions.dart';
import '../../domain/entities/lesson.dart';
import 'lesson_status_badge.dart';

/// Interactive list tile representing a lesson with sequential unlock behavior.
class LessonTile extends StatelessWidget {
  const LessonTile({super.key, required this.lesson, required this.onTap});

  final Lesson lesson;
  final ValueChanged<Lesson> onTap;

  void _handleTap(BuildContext context) {
    if (lesson.isLocked) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(context.tr('lessonLocked')),
            behavior: .floating,
            duration: const Duration(seconds: 2),
            shape: RoundedRectangleBorder(borderRadius: .circular(12)),
          ),
        );
      return;
    }
    onTap(lesson);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final (icon, iconColor, bgIconColor) = switch (lesson) {
      _ when lesson.isLocked => (
        Icons.lock_rounded,
        colors.onSurfaceVariant,
        colors.surfaceContainerHighest.withValues(alpha: 0.5),
      ),
      _ when lesson.isCompleted => (
        Icons.check_rounded,
        colors.primary,
        colors.primaryContainer.withValues(alpha: 0.8),
      ),
      _ when lesson.status == LessonStatus.inProgress => (
        Icons.play_arrow_rounded,
        colors.onTertiaryContainer,
        colors.tertiaryContainer,
      ),
      _ => (
        Icons.play_arrow_outlined,
        colors.onSurfaceVariant,
        colors.surfaceContainerHighest.withValues(alpha: 0.4),
      ),
    };

    final content = ListTile(
      contentPadding: const .symmetric(horizontal: 16, vertical: 4),
      onTap: () => _handleTap(context),
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: bgIconColor,
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        lesson.title,
        style: texts.bodyMedium?.copyWith(
          fontWeight: lesson.isCompleted ? .normal : .w600,
          color: lesson.isLocked ? colors.onSurfaceVariant : colors.onSurface,
        ),
      ),
      subtitle: Padding(
        padding: const .only(top: 4),
        child: Row(
          spacing: 8,
          children: [
            Row(
              spacing: 4,
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 13,
                  color: colors.onSurfaceVariant,
                ),
                Text(
                  lesson.durationSec.seconds.toFormattedString(),
                  style: texts.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            LessonStatusBadge(lesson: lesson),
          ],
        ),
      ),
      trailing: Icon(
        Icons.adaptive.arrow_forward,
        size: 16,
        color: lesson.isLocked
            ? colors.outlineVariant.withValues(alpha: 0.5)
            : colors.onSurfaceVariant,
      ),
    );

    if (lesson.isLocked) {
      return Opacity(opacity: 0.65, child: content);
    }
    return content;
  }
}
