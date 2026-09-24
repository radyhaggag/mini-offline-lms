import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/duration_extensions.dart';
import '../../../courses/domain/entities/lesson.dart';

import '../../../../core/widgets/app_snack_bar.dart';

/// Card/button providing next lesson navigation respecting the sequential unlock policy.
class NextLessonButton extends StatelessWidget {
  const NextLessonButton({
    super.key,
    required this.nextLesson,
    required this.isCurrentLessonCompleted,
    required this.onTap,
  });

  final Lesson? nextLesson;
  final bool isCurrentLessonCompleted;
  final ValueChanged<Lesson> onTap;

  void _onLockedTap(BuildContext context) {
    AppSnackBar.showWarning(
      context,
      message: context.tr('completeCurrentLessonFirst'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;
    final lesson = nextLesson;

    if (lesson == null) {
      if (!isCurrentLessonCompleted) {
        return const SizedBox.shrink();
      }
      return Card(
        elevation: 0,
        color: colors.primaryContainer.withValues(alpha: 0.35),
        margin: const .symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: .circular(16),
          side: BorderSide(color: colors.primary.withValues(alpha: 0.2)),
        ),
        child: Padding(
          padding: const .all(16),
          child: Row(
            spacing: 12,
            children: [
              Icon(Icons.celebration_rounded, color: colors.primary, size: 28),
              Expanded(
                child: Text(
                  context.tr('courseCompleted'),
                  style: texts.bodyMedium?.copyWith(
                    fontWeight: .bold,
                    color: colors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final isLocked = lesson.isLocked;

    return Card(
      elevation: 0,
      color: isLocked
          ? colors.surfaceContainerHighest.withValues(alpha: 0.35)
          : colors.primaryContainer.withValues(alpha: 0.4),
      margin: const .symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: .circular(16),
        side: BorderSide(
          color: isLocked
              ? colors.outlineVariant.withValues(alpha: 0.25)
              : colors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: InkWell(
        onTap: isLocked ? () => _onLockedTap(context) : () => onTap(lesson),
        borderRadius: .circular(16),
        child: Padding(
          padding: const .all(16),
          child: Row(
            spacing: 12,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isLocked
                      ? colors.surfaceContainerHighest
                      : colors.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isLocked
                      ? Icons.lock_outline_rounded
                      : Icons.play_arrow_rounded,
                  color: isLocked ? colors.onSurfaceVariant : colors.onPrimary,
                  size: 24,
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: .start,
                  spacing: 4,
                  children: [
                    Text(
                      context.tr('nextLesson'),
                      style: texts.labelSmall?.copyWith(
                        color: isLocked
                            ? colors.onSurfaceVariant
                            : colors.primary,
                        fontWeight: .bold,
                      ),
                    ),
                    Text(
                      lesson.title,
                      style: texts.bodyMedium?.copyWith(
                        fontWeight: .w600,
                        color: isLocked
                            ? colors.onSurface.withValues(alpha: 0.6)
                            : colors.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      lesson.durationSec.seconds.toFormattedString(),
                      style: texts.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                isLocked ? Icons.lock_rounded : Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isLocked ? colors.onSurfaceVariant : colors.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
