import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'player_controls_overlay.dart';
import 'video_error_view.dart';

part 'video_player_view_overlay.dart';

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

  final String videoAssetPath;
  final String lessonTitle;
  final int initialPositionSec;
  final double playbackSpeed;
  final bool isFullscreen;
  final void Function(int positionSeconds, int totalDurationSeconds)
  onProgressUpdate;
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
    setState(() {
      _hasError = false;
      _isInitialized = false;
    });
    try {
      final controller = VideoPlayerController.asset(widget.videoAssetPath);
      await controller.initialize();
      if (!mounted || _isDeactivated) {
        return unawaited(controller.dispose());
      }
      final initialPosition = widget.initialPositionSec;
      final totalDuration = controller.value.duration.inSeconds;
      if (initialPosition > 0 && initialPosition < totalDuration) {
        await controller.seekTo(Duration(seconds: initialPosition));
      }
      await controller.setPlaybackSpeed(widget.playbackSpeed);
      controller.addListener(_videoListener);
      _controller = controller;
      setState(() => _isInitialized = true);
      await controller.play();
      _resetControlsTimer();
    } catch (_) {
      if (mounted && !_isDeactivated) {
        setState(() => _hasError = true);
      }
    }
  }

  void _updateProgress(VideoPlayerController controller) {
    final value = controller.value;
    widget.onProgressUpdate(value.position.inSeconds, value.duration.inSeconds);
  }

  void _videoListener() {
    if (_isDeactivated || !mounted) return;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final positionSeconds = controller.value.position.inSeconds;
    final durationSeconds = controller.value.duration.inSeconds;
    if ((positionSeconds - _lastSavedSec).abs() >= 3 ||
        (durationSeconds > 0 && positionSeconds >= durationSeconds * 0.9)) {
      _lastSavedSec = positionSeconds;
      _updateProgress(controller);
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

  void onSeekingPositionChanged(Duration target) =>
      setState(() => _seekingPosition = target);

  /// Pauses playback and reports current progress.
  Future<void> pause() async {
    final controller = _controller;
    if (controller != null && controller.value.isPlaying) {
      await controller.pause();
      _updateProgress(controller);
      if (mounted && !_isDeactivated) setState(() => _showControls = true);
    }
  }

  void _onPlayPause() {
    final controller = _controller;
    if (controller == null) return;
    if (controller.value.isPlaying) return unawaited(pause());
    controller.play();
    _resetControlsTimer();
  }

  void _onSeekEnd(Duration target) {
    if (_isDeactivated || !mounted) return;
    setState(() => _seekingPosition = null);
    final controller = _controller;
    if (controller != null) {
      controller.seekTo(target);
      _updateProgress(controller);
    }
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
    final controller = _controller;
    if (controller != null && controller.value.isInitialized) {
      controller.removeListener(_videoListener);
      controller.pause();
      _updateProgress(controller);
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
    if (_hasError) return VideoErrorPlaceholder(onRetry: _initController);
    if (!_isInitialized || _controller == null) {
      return const VideoLoadingPlaceholder();
    }
    return _VideoPlayerViewOverlay(state: this);
  }
}
