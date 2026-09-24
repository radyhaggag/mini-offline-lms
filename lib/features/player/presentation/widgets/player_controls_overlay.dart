import 'package:flutter/material.dart';

import '../../../../core/config/theme/app_theme.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import 'playback_speed_selector.dart';
import 'player_bottom_controls.dart';
import 'player_top_controls.dart';

/// Overlay displaying playback controls: play/pause, seek slider, timestamps, speed, fullscreen.
class PlayerControlsOverlay extends StatelessWidget {
  const PlayerControlsOverlay({
    super.key,
    required this.isVisible,
    required this.isPlaying,
    required this.position,
    required this.duration,
    required this.playbackSpeed,
    required this.isFullscreen,
    required this.title,
    required this.onPlayPause,
    required this.onSeekStart,
    required this.onSeekChange,
    required this.onSeekEnd,
    required this.onSpeedChanged,
    required this.onToggleFullscreen,
    this.seekingPosition,
  });

  final bool isVisible;
  final bool isPlaying;
  final Duration position;
  final Duration duration;
  final double playbackSpeed;
  final bool isFullscreen;
  final String title;
  final VoidCallback onPlayPause;
  final VoidCallback onSeekStart;
  final ValueChanged<Duration> onSeekChange;
  final ValueChanged<Duration> onSeekEnd;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onToggleFullscreen;
  final Duration? seekingPosition;

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !isVisible,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 250),
          child: Theme(
            data: AppTheme.dark,
            child: Builder(
              builder: (themedContext) {
                final colors = themedContext.colorScheme;
                final currentPos = seekingPosition ?? position;
                final maxSec = duration.inSeconds.toDouble();
                final currentSec = currentPos.inSeconds.toDouble().clamp(
                  0.0,
                  maxSec > 0 ? maxSec : 1.0,
                );

                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: .topCenter,
                      end: .bottomCenter,
                      colors: [
                        colors.shadow.withValues(
                          alpha: isFullscreen ? 0.7 : 0.4,
                        ),
                        Colors.transparent,
                        Colors.transparent,
                        colors.shadow.withValues(alpha: 0.85),
                      ],
                      stops: const [0.0, 0.25, 0.55, 1.0],
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (isFullscreen)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: SafeArea(
                            bottom: false,
                            child: PlayerTopControls(
                              title: title,
                              onToggleFullscreen: onToggleFullscreen,
                            ),
                          ),
                        ),
                      Center(
                        child: _CenterPlayButton(
                          isPlaying: isPlaying,
                          onPlayPause: onPlayPause,
                          colors: colors,
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: SafeArea(
                          top: false,
                          left: isFullscreen,
                          right: isFullscreen,
                          bottom: isFullscreen,
                          child: PlayerBottomControls(
                            currentPos: currentPos,
                            duration: duration,
                            currentSec: currentSec,
                            maxSec: maxSec,
                            playbackSpeed: playbackSpeed,
                            isFullscreen: isFullscreen,
                            onSeekStart: onSeekStart,
                            onSeekChange: onSeekChange,
                            onSeekEnd: onSeekEnd,
                            onSpeedTap: () => PlaybackSpeedSelector.show(
                              themedContext,
                              currentSpeed: playbackSpeed,
                              onSpeedSelected: onSpeedChanged,
                            ),
                            onToggleFullscreen: onToggleFullscreen,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterPlayButton extends StatelessWidget {
  const _CenterPlayButton({
    required this.isPlaying,
    required this.onPlayPause,
    required this.colors,
  });

  final bool isPlaying;
  final VoidCallback onPlayPause;
  final ColorScheme colors;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPlayPause,
      iconSize: 52,
      icon: Container(
        padding: const .all(10),
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.6),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.3),
              blurRadius: 8,
            ),
          ],
        ),
        child: Icon(
          isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
          color: colors.onSurface,
          size: 36,
        ),
      ),
    );
  }
}
