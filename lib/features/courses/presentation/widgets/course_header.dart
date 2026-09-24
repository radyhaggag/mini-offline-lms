import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/course.dart';

/// Top hero header for course details screen with illustration, stats, and progress.
class CourseHeader extends StatelessWidget {
  const CourseHeader({super.key, required this.course});

  final Course course;

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

    return Column(
      crossAxisAlignment: .start,
      children: [
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: .topCenter,
              end: .bottomCenter,
              colors: [
                colors.surfaceContainerHighest.withValues(alpha: 0.5),
                colors.surfaceContainerHighest.withValues(alpha: 0.15),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: const .symmetric(vertical: 12),
              child: Image.asset(
                course.thumbnail,
                fit: .contain,
                errorBuilder: (_, _, _) => Icon(
                  Icons.school_outlined,
                  size: 64,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const .all(16),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 14,
            children: [
              Text(
                course.title,
                style: texts.headlineSmall?.copyWith(fontWeight: .bold),
              ),
              Row(
                spacing: 8,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: colors.primaryContainer.withValues(
                      alpha: 0.7,
                    ),
                    child: Icon(Icons.person, size: 18, color: colors.primary),
                  ),
                  Text(
                    course.instructor,
                    style: texts.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: .w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const .all(14),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: .circular(16),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  spacing: 10,
                  children: [
                    Row(
                      mainAxisAlignment: .spaceBetween,
                      children: [
                        Row(
                          spacing: 6,
                          children: [
                            Icon(
                              Icons.play_lesson_outlined,
                              size: 16,
                              color: colors.primary,
                            ),
                            Text(
                              lessonsCountText,
                              style: texts.bodySmall?.copyWith(
                                color: colors.onSurface,
                                fontWeight: .w600,
                              ),
                            ),
                          ],
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
                        minHeight: 8,
                        backgroundColor: colors.surfaceContainerHighest,
                        color: colors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
