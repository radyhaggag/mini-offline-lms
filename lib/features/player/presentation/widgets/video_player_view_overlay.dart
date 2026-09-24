part of 'video_player_view.dart';

/// Presentation layer rendering the video player surface and interactive controls overlay.
class _VideoPlayerViewOverlay extends StatelessWidget {
  const _VideoPlayerViewOverlay({required this.state});

  final VideoPlayerViewState state;

  @override
  Widget build(BuildContext context) {
    final controller = state._controller!;
    final value = controller.value;
    final aspectRatio = value.aspectRatio > 0 ? value.aspectRatio : 16 / 9;

    return AspectRatio(
      aspectRatio: aspectRatio,
      child: GestureDetector(
        onTap: state._toggleControls,
        behavior: .opaque,
        child: Stack(
          fit: .expand,
          children: [
            VideoPlayer(controller),
            PlayerControlsOverlay(
              isVisible: state._showControls,
              isPlaying: value.isPlaying,
              position: value.position,
              duration: value.duration,
              playbackSpeed: state.widget.playbackSpeed,
              isFullscreen: state.widget.isFullscreen,
              title: state.widget.lessonTitle,
              seekingPosition: state._seekingPosition,
              onPlayPause: state._onPlayPause,
              onSeekStart: () => state._controlsTimer?.cancel(),
              onSeekChange: state.onSeekingPositionChanged,
              onSeekEnd: state._onSeekEnd,
              onSpeedChanged: state.widget.onSpeedChanged,
              onToggleFullscreen: state.widget.onToggleFullscreen,
            ),
          ],
        ),
      ),
    );
  }
}
