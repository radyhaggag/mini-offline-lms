import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/course.dart';

/// Thumbnail banner widget for course cards with illustration and metadata badges.
class CourseThumbnail extends StatelessWidget {
  const CourseThumbnail({
    super.key,
    required this.course,
    required this.lessonsCountText,
  });

  final Course course;
  final String lessonsCountText;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return SizedBox(
      height: 180,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            course.thumbnail,
            fit: .cover,
            width: double.infinity,
            height: double.infinity,
            alignment: .center,
            errorBuilder: (_, _, _) => Container(
              color: colors.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  Icons.school_outlined,
                  size: 56,
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: .topCenter,
                end: .bottomCenter,
                colors: [
                  colors.surface.withValues(alpha: 0.3),
                  Colors.transparent,
                  colors.surface.withValues(alpha: 0.45),
                ],
                stops: const [0.0, 0.45, 1.0],
              ),
            ),
          ),
          Positioned.directional(
            textDirection: Directionality.of(context),
            top: 12,
            start: 12,
            child: Container(
              padding: const .symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: colors.surface.withValues(alpha: 0.9),
                borderRadius: .circular(12),
                border: Border.all(
                  color: colors.outlineVariant.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                context.tr('healthSciences'),
                style: texts.labelSmall?.copyWith(
                  color: colors.primary,
                  fontWeight: .bold,
                ),
              ),
            ),
          ),
          if (course.totalLessonsCount > 0)
            Positioned.directional(
              textDirection: Directionality.of(context),
              bottom: 12,
              end: 12,
              child: Container(
                padding: const .symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: colors.surface.withValues(alpha: 0.9),
                  borderRadius: .circular(12),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  spacing: 4,
                  children: [
                    Icon(
                      Icons.play_lesson_outlined,
                      size: 13,
                      color: colors.onSurfaceVariant,
                    ),
                    Text(
                      lessonsCountText,
                      style: texts.labelSmall?.copyWith(
                        color: colors.onSurfaceVariant,
                        fontWeight: .w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
