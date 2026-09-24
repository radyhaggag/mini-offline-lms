import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'player_controls_overlay.dart';
import 'video_error_view.dart';

/// Single, unified video player widget managing playback, controls, and progress.
class VideoPlayerView extends StatefulWidget {
  const VideoPlayerView({
    super.key,
    required this.videoAssetPath,
    required this.lessonTitle,
    required this.initialPositionSec,
    required this.playbackSpeed,
    required this.isFullscreen,
    required this.onProgressUpdate,
    required this.onSpeedChanged,
    required this.onToggleFullscreen,
  });

  final String videoAssetPath, lessonTitle;
  final int initialPositionSec;
  final double playbackSpeed;
  final bool isFullscreen;
  final void Function(int pos, int dur) onProgressUpdate;
  final ValueChanged<double> onSpeedChanged;
  final VoidCallback onToggleFullscreen;

  @override
  State<VideoPlayerView> createState() => VideoPlayerViewState();
}

class VideoPlayerViewState extends State<VideoPlayerView> {
  VideoPlayerController? _controller;
  bool _isInitialized = false,
      _hasError = false,
      _showControls = true,
      _isDeactivated = false;
  Timer? _controlsTimer;
  Duration? _seekingPosition;
  int _lastSavedSec = -1;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  Future<void> _initController() async {
    setState(() => _hasError = _isInitialized = false);
    try {
      final c = VideoPlayerController.asset(widget.videoAssetPath);
      await c.initialize();
      if (!mounted || _isDeactivated) return unawaited(c.dispose());
      final pos = widget.initialPositionSec, dur = c.value.duration.inSeconds;
      if (pos > 0 && pos < dur) await c.seekTo(Duration(seconds: pos));
      await c.setPlaybackSpeed(widget.playbackSpeed);
      _controller = c..addListener(_videoListener);
      setState(() => _isInitialized = true);
      await c.play();
      _resetControlsTimer();
    } catch (_) {
      if (mounted && !_isDeactivated) setState(() => _hasError = true);
    }
  }

  void _updateProgress(VideoPlayerController c) {
    final v = c.value;
    widget.onProgressUpdate(v.position.inSeconds, v.duration.inSeconds);
  }

  void _videoListener() {
    if (_isDeactivated || !mounted) return;
    final c = _controller;
    if (c == null || !c.value.isInitialized) return;
    final pos = c.value.position.inSeconds, dur = c.value.duration.inSeconds;
    if ((pos - _lastSavedSec).abs() >= 3 || (dur > 0 && pos >= dur * 0.9)) {
      _lastSavedSec = pos;
      _updateProgress(c);
    }
    if (mounted && !_isDeactivated) setState(() {});
  }

  void _resetControlsTimer() {
    _controlsTimer?.cancel();
    if (_isDeactivated || _controller?.value.isPlaying != true) return;
    _controlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isDeactivated && _controller?.value.isPlaying == true) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _resetControlsTimer();
  }

  /// Pauses playback and reports current progress.
  Future<void> pause() async {
    final c = _controller;
    if (c != null && c.value.isPlaying) {
      await c.pause();
      _updateProgress(c);
      if (mounted && !_isDeactivated) setState(() => _showControls = true);
    }
  }

  void _onPlayPause() {
    final c = _controller;
    if (c == null) return;
    if (c.value.isPlaying) return unawaited(pause());
    c.play();
    _resetControlsTimer();
  }

  void _onSeekEnd(Duration target) {
    if (_isDeactivated || !mounted) return;
    setState(() => _seekingPosition = null);
    final c = _controller?..seekTo(target);
    if (c != null) _updateProgress(c);
    _resetControlsTimer();
  }

  @override
  void didUpdateWidget(covariant VideoPlayerView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.playbackSpeed != widget.playbackSpeed) {
      _controller?.setPlaybackSpeed(widget.playbackSpeed);
    }
  }

  @override
  void deactivate() {
    _isDeactivated = true;
    _controlsTimer?.cancel();
    final c = _controller;
    if (c != null && c.value.isInitialized) {
      c.removeListener(_videoListener);
      c.pause();
      _updateProgress(c);
    }
    super.deactivate();
  }

  @override
  void activate() {
    super.activate();
    _isDeactivated = false;
    _controller?.addListener(_videoListener);
  }

  @override
  void dispose() {
    _isDeactivated = true;
    _controlsTimer?.cancel();
    _controller?.removeListener(_videoListener);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = _controller;
    if (_hasError) return VideoErrorPlaceholder(onRetry: _initController);
    if (!_isInitialized || c == null) return const VideoLoadingPlaceholder();
    return AspectRatio(
      aspectRatio: c.value.aspectRatio > 0 ? c.value.aspectRatio : 16 / 9,
      child: GestureDetector(
        onTap: _toggleControls,
        behavior: .opaque,
        child: Stack(
          fit: .expand,
          children: [
            VideoPlayer(c),
            PlayerControlsOverlay(
              isVisible: _showControls,
              isPlaying: c.value.isPlaying,
              position: c.value.position,
              duration: c.value.duration,
              playbackSpeed: widget.playbackSpeed,
              isFullscreen: widget.isFullscreen,
              title: widget.lessonTitle,
              seekingPosition: _seekingPosition,
              onPlayPause: _onPlayPause,
              onSeekStart: () => _controlsTimer?.cancel(),
              onSeekChange: (val) => setState(() => _seekingPosition = val),
              onSeekEnd: _onSeekEnd,
              onSpeedChanged: widget.onSpeedChanged,
              onToggleFullscreen: widget.onToggleFullscreen,
            ),
          ],
        ),
      ),
    );
  }
}
