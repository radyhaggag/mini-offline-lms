import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/entities/section.dart';
import 'lesson_tile.dart';

/// Card grouping lessons under a clear section header.
class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.section,
    required this.onLessonTap,
  });

  final Section section;
  final ValueChanged<Lesson> onLessonTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final lessonsCountText = context.tr(
      'lessonCount',
      args: [section.totalLessonsCount.toString()],
    );

    return Card(
      elevation: 0,
      margin: const .symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(18),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.35)),
      ),
      clipBehavior: .antiAlias,
      child: Column(
        crossAxisAlignment: .start,
        children: [
          Container(
            padding: const .symmetric(horizontal: 16, vertical: 12),
            color: colors.surfaceContainerHighest.withValues(alpha: 0.3),
            child: Row(
              mainAxisAlignment: .spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    section.title,
                    style: texts.titleSmall?.copyWith(fontWeight: .bold),
                  ),
                ),
                Container(
                  padding: const .symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: colors.surface,
                    borderRadius: .circular(8),
                    border: Border.all(
                      color: colors.outlineVariant.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    lessonsCountText,
                    style: texts.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: .w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          for (var i = 0; i < section.lessons.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                thickness: 1,
                color: colors.outlineVariant.withValues(alpha: 0.2),
              ),
            LessonTile(lesson: section.lessons[i], onTap: onLessonTap),
          ],
        ],
      ),
    );
  }
}
