import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_loader.dart';

/// Friendly error view displayed when video loading fails.
class VideoErrorView extends StatelessWidget {
  const VideoErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisSize: .min,
          spacing: 16,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: colors.errorContainer.withValues(alpha: 0.6),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 36,
                color: colors.error,
              ),
            ),
            Text(
              message,
              style: texts.titleMedium?.copyWith(
                fontWeight: .bold,
                color: colors.onErrorContainer,
              ),
              textAlign: .center,
            ),
            FilledButton.tonalIcon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('retry')),
            ),
          ],
        ),
      ),
    );
  }
}

/// 16:9 dark placeholder for video player during loading or error states.
class VideoPlaceholder extends StatelessWidget {
  const VideoPlaceholder({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: Container(color: AppColors.backgroundDark, child: child),
    );
  }
}

/// Placeholder shown while the video is initializing.
class VideoLoadingPlaceholder extends StatelessWidget {
  const VideoLoadingPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return const VideoPlaceholder(child: Center(child: AppLoader()));
  }
}

/// Placeholder shown when video loading encounters an error.
class VideoErrorPlaceholder extends StatelessWidget {
  const VideoErrorPlaceholder({super.key, required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return VideoPlaceholder(
      child: VideoErrorView(
        message: context.tr('videoLoadError'),
        onRetry: onRetry,
      ),
    );
  }
}
