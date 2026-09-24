import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/utils/extensions/duration_extensions.dart';

/// Bottom bar of video player overlay: slider, timestamps, speed, and fullscreen button.
class PlayerBottomControls extends StatelessWidget {
  const PlayerBottomControls({
    super.key,
    required this.currentPos,
    required this.duration,
    required this.currentSec,
    required this.maxSec,
    required this.playbackSpeed,
    required this.isFullscreen,
    required this.onSeekStart,
    required this.onSeekChange,
    required this.onSeekEnd,
    required this.onSpeedTap,
    required this.onToggleFullscreen,
  });

  final Duration currentPos;
  final Duration duration;
  final double currentSec;
  final double maxSec;
  final double playbackSpeed;
  final bool isFullscreen;
  final VoidCallback onSeekStart;
  final ValueChanged<Duration> onSeekChange;
  final ValueChanged<Duration> onSeekEnd;
  final VoidCallback onSpeedTap;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final timeStyle = texts.bodySmall?.copyWith(
      color: colors.onSurface,
      fontWeight: .w600,
      shadows: [
        Shadow(color: colors.shadow.withValues(alpha: 0.8), blurRadius: 4),
      ],
    );

    return Padding(
      padding: const .fromLTRB(16, 0, 16, 6),
      child: Column(
        mainAxisSize: .min,
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3.5,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: colors.primary,
              inactiveTrackColor: colors.onSurface.withValues(alpha: 0.35),
              thumbColor: colors.primary,
            ),
            child: Slider(
              value: maxSec > 0 ? currentSec : 0.0,
              max: maxSec > 0 ? maxSec : 1.0,
              onChangeStart: (_) => onSeekStart(),
              onChanged: (val) => onSeekChange(Duration(seconds: val.round())),
              onChangeEnd: (val) => onSeekEnd(Duration(seconds: val.round())),
            ),
          ),
          Row(
            spacing: 6,
            children: [
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(currentPos.toFormattedString(), style: timeStyle),
              ),
              Text('/', style: timeStyle),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(duration.toFormattedString(), style: timeStyle),
              ),
              const Spacer(),
              TextButton(
                onPressed: onSpeedTap,
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  foregroundColor: colors.onSurface,
                  padding: const .symmetric(horizontal: 8),
                ),
                child: Text(
                  '${playbackSpeed}x',
                  style: texts.labelLarge?.copyWith(
                    fontWeight: .bold,
                    color: colors.onSurface,
                    shadows: [
                      Shadow(
                        color: colors.shadow.withValues(alpha: 0.8),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
              ),
              IconButton(
                onPressed: onToggleFullscreen,
                iconSize: 22,
                visualDensity: VisualDensity.compact,
                icon: Icon(
                  isFullscreen
                      ? Icons.fullscreen_exit_rounded
                      : Icons.fullscreen_rounded,
                  color: colors.onSurface,
                  shadows: [
                    Shadow(
                      color: colors.shadow.withValues(alpha: 0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
