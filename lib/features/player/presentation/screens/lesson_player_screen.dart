import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/di/service_locator.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../data/data_sources/progress_data_source.dart';

/// Temporary player screen with interactive simulation controls for testing unlock rules.
class LessonPlayerScreen extends StatelessWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  Future<void> _simulateInProgress(BuildContext context) async {
    final progressSource = sl<ProgressDataSource>();
    await progressSource.savePosition(lessonId, 50);
    if (context.mounted) {
      context.pop();
    }
  }

  Future<void> _simulateCompleted(BuildContext context) async {
    final progressSource = sl<ProgressDataSource>();
    await progressSource.savePosition(lessonId, 120);
    await progressSource.markCompleted(lessonId);
    if (context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(context.tr('lesson'))),
      body: Center(
        child: Padding(
          padding: const .all(24),
          child: Column(
            mainAxisAlignment: .center,
            spacing: 20,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: colors.primaryContainer.withValues(alpha: 0.6),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow_rounded,
                  size: 48,
                  color: colors.primary,
                ),
              ),
              Column(
                spacing: 6,
                children: [
                  Text(
                    lessonId,
                    style: texts.titleLarge?.copyWith(fontWeight: .bold),
                    textAlign: .center,
                  ),
                  Text(
                    courseId,
                    style: texts.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                    textAlign: .center,
                  ),
                ],
              ),
              Card(
                elevation: 0,
                color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: .circular(16),
                  side: BorderSide(
                    color: colors.outlineVariant.withValues(alpha: 0.3),
                  ),
                ),
                child: Padding(
                  padding: const .all(16),
                  child: Column(
                    spacing: 12,
                    children: [
                      FilledButton.tonalIcon(
                        onPressed: () => _simulateInProgress(context),
                        icon: const Icon(Icons.timelapse_rounded),
                        label: Text(context.tr('inProgress')),
                      ),
                      FilledButton.icon(
                        onPressed: () => _simulateCompleted(context),
                        icon: const Icon(Icons.check_circle_rounded),
                        label: Text(context.tr('completed')),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
