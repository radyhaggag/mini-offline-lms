import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/duration_extensions.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/lesson.dart';

/// Informational section below the video displaying title, course metadata, and completion status.
class LessonInfoSection extends StatelessWidget {
  const LessonInfoSection({
    super.key,
    required this.course,
    required this.lesson,
    required this.isCompleted,
  });

  final Course course;
  final Lesson lesson;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return Padding(
      padding: const .all(16),
      child: Column(
        crossAxisAlignment: .start,
        spacing: 12,
        children: [
          Row(
            crossAxisAlignment: .start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,
                  children: [
                    Text(
                      lesson.title,
                      style: texts.titleLarge?.copyWith(fontWeight: .bold),
                    ),
                    Text(
                      course.title,
                      style: texts.bodyMedium?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              _CompletionBadge(isCompleted: isCompleted),
            ],
          ),
          Row(
            spacing: 16,
            children: [
              Row(
                spacing: 4,
                children: [
                  Icon(
                    Icons.schedule_rounded,
                    size: 16,
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
              Row(
                spacing: 4,
                children: [
                  Icon(
                    Icons.person_outline_rounded,
                    size: 16,
                    color: colors.onSurfaceVariant,
                  ),
                  Text(
                    course.instructor,
                    style: texts.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CompletionBadge extends StatelessWidget {
  const _CompletionBadge({required this.isCompleted});

  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final bgColor = isCompleted
        ? colors.primaryContainer
        : colors.surfaceContainerHighest;
    final fgColor = isCompleted
        ? colors.onPrimaryContainer
        : colors.onSurfaceVariant;
    final icon = isCompleted
        ? Icons.check_circle_rounded
        : Icons.timelapse_rounded;
    final label = isCompleted
        ? context.tr('completed')
        : context.tr('inProgress');

    return Container(
      padding: const .symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: bgColor, borderRadius: .circular(20)),
      child: Row(
        mainAxisSize: .min,
        spacing: 4,
        children: [
          Icon(icon, size: 14, color: fgColor),
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
