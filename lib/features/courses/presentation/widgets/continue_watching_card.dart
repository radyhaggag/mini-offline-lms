import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/duration_extensions.dart';
import '../../domain/entities/continue_watching.dart';

/// Featured card showing the student's in-progress lesson ready to resume.
class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({
    super.key,
    required this.item,
    required this.onResume,
  });

  final ContinueWatching item;
  final ValueChanged<ContinueWatching> onResume;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final durationSec = item.lesson.durationSec;
    final positionSec = item.lesson.lastPositionSec;
    final progressFraction = durationSec > 0
        ? (positionSec / durationSec).clamp(0.0, 1.0)
        : 0.0;
    final percentText = '${(progressFraction * 100).round()}%';
    final timeText =
        '${positionSec.seconds.toFormattedString()} / ${durationSec.seconds.toFormattedString()}';

    return Container(
      decoration: BoxDecoration(
        borderRadius: .circular(20),
        gradient: LinearGradient(
          begin: .topLeft,
          end: .bottomRight,
          colors: [
            colors.primaryContainer.withValues(alpha: 0.7),
            colors.primaryContainer.withValues(alpha: 0.2),
          ],
        ),
        border: Border.all(color: colors.primary.withValues(alpha: 0.3)),
      ),
      clipBehavior: .antiAlias,
      child: InkWell(
        onTap: () => onResume(item),
        borderRadius: .circular(20),
        child: Padding(
          padding: const .all(18),
          child: Column(
            crossAxisAlignment: .start,
            spacing: 14,
            children: [
              Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  Container(
                    padding: const .symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      borderRadius: .circular(12),
                    ),
                    child: Row(
                      spacing: 6,
                      children: [
                        Icon(
                          Icons.play_arrow_rounded,
                          size: 16,
                          color: colors.onPrimary,
                        ),
                        Text(
                          context.tr('continueWatching'),
                          style: texts.labelSmall?.copyWith(
                            color: colors.onPrimary,
                            fontWeight: .bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    spacing: 4,
                    children: [
                      Text(
                        context.tr('resume'),
                        style: texts.labelMedium?.copyWith(
                          color: colors.primary,
                          fontWeight: .bold,
                        ),
                      ),
                      Icon(
                        Icons.adaptive.arrow_forward,
                        size: 14,
                        color: colors.primary,
                      ),
                    ],
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: .start,
                spacing: 4,
                children: [
                  Text(
                    item.course.title,
                    style: texts.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: .w600,
                    ),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                  Text(
                    item.lesson.title,
                    style: texts.titleMedium?.copyWith(fontWeight: .bold),
                    maxLines: 1,
                    overflow: .ellipsis,
                  ),
                ],
              ),
              Column(
                spacing: 6,
                children: [
                  ClipRRect(
                    borderRadius: .circular(6),
                    child: LinearProgressIndicator(
                      value: progressFraction,
                      minHeight: 7,
                      backgroundColor: colors.surfaceContainerHighest,
                      color: colors.primary,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: .spaceBetween,
                    children: [
                      Text(
                        timeText,
                        style: texts.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: .w500,
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
