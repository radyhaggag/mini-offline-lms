import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/course.dart';
import 'course_thumbnail.dart';

/// Modern card displaying course thumbnail, title, instructor, and watch progress.
class CourseCard extends StatelessWidget {
  const CourseCard({super.key, required this.course, required this.onTap});

  final Course course;
  final ValueChanged<Course> onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final progressFraction = (course.progressPercentage / 100).clamp(0.0, 1.0);
    final percentText = context.tr(
      'completedPercent',
      args: [course.progressPercentage.round().toString()],
    );
    final lessonsCountText = context.tr(
      'lessonCount',
      args: [course.totalLessonsCount.toString()],
    );

    return Card(
      elevation: 0,
      clipBehavior: .antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: .circular(20),
        side: BorderSide(color: colors.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: InkWell(
        onTap: () => onTap(course),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            CourseThumbnail(course: course, lessonsCountText: lessonsCountText),
            Padding(
              padding: const .all(16),
              child: Column(
                crossAxisAlignment: .start,
                spacing: 12,
                children: [
                  Text(
                    course.title,
                    style: texts.titleMedium?.copyWith(fontWeight: .bold),
                    maxLines: 2,
                    overflow: .ellipsis,
                  ),
                  Row(
                    spacing: 8,
                    children: [
                      CircleAvatar(
                        radius: 14,
                        backgroundColor: colors.primaryContainer.withValues(
                          alpha: 0.6,
                        ),
                        child: Icon(
                          Icons.person,
                          size: 16,
                          color: colors.primary,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          course.instructor,
                          style: texts.bodyMedium?.copyWith(
                            color: colors.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: .ellipsis,
                        ),
                      ),
                    ],
                  ),
                  if (course.totalLessonsCount > 0)
                    Column(
                      spacing: 6,
                      children: [
                        Row(
                          mainAxisAlignment: .spaceBetween,
                          children: [
                            Text(
                              context.tr('progress'),
                              style: texts.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              percentText,
                              style: texts.bodySmall?.copyWith(
                                color: colors.primary,
                                fontWeight: .bold,
                              ),
                            ),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: .circular(4),
                          child: LinearProgressIndicator(
                            value: progressFraction,
                            minHeight: 6,
                            backgroundColor: colors.surfaceContainerHighest,
                            color: colors.primary,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
