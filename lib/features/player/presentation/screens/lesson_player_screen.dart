import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/app_routes.dart';
import '../../../../core/config/theme/app_colors.dart';
import '../../../../core/widgets/app_loader.dart';
import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';
import '../widgets/lesson_info_section.dart';
import '../widgets/next_lesson_button.dart';
import '../widgets/video_error_view.dart';
import '../widgets/video_player_view.dart';

/// Screen presenting the offline video player, controls, and sequential next-lesson flow.
class LessonPlayerScreen extends StatefulWidget {
  const LessonPlayerScreen({
    super.key,
    required this.courseId,
    required this.lessonId,
  });

  final String courseId;
  final String lessonId;

  @override
  State<LessonPlayerScreen> createState() => _LessonPlayerScreenState();
}

class _LessonPlayerScreenState extends State<LessonPlayerScreen> {
  final _playerKey = GlobalKey<VideoPlayerViewState>();
  bool _isFullscreen = false;

  @override
  void dispose() {
    _restorePortrait();
    super.dispose();
  }

  void _restorePortrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
    if (_isFullscreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      _restorePortrait();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_isFullscreen,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        if (_isFullscreen) _toggleFullscreen();
      },
      child: Scaffold(
        backgroundColor: _isFullscreen ? AppColors.backgroundDark : null,
        appBar: _isFullscreen
            ? null
            : AppBar(
                title: BlocBuilder<PlayerCubit, PlayerState>(
                  buildWhen: (prev, curr) => curr is PlayerLoaded,
                  builder: (context, state) => Text(
                    state is PlayerLoaded
                        ? state.lesson.title
                        : context.tr('lesson'),
                  ),
                ),
              ),
        body: BlocBuilder<PlayerCubit, PlayerState>(
          builder: (context, state) => switch (state) {
            PlayerInitial() || PlayerLoading() => const AppLoader(),
            PlayerError(:final message) => VideoErrorView(
              message: context.tr(message),
              onRetry: () => context.read<PlayerCubit>().init(
                courseId: widget.courseId,
                lessonId: widget.lessonId,
              ),
            ),
            PlayerLoaded() => _buildLoadedBody(context, state),
          },
        ),
      ),
    );
  }

  Widget _buildLoadedBody(BuildContext context, PlayerLoaded state) {
    final cubit = context.read<PlayerCubit>();
    final playerView = VideoPlayerView(
      key: _playerKey,
      videoAssetPath: state.lesson.video,
      lessonTitle: state.lesson.title,
      initialPositionSec: state.initialPositionSec,
      playbackSpeed: state.playbackSpeed,
      isFullscreen: _isFullscreen,
      onProgressUpdate: (positionSeconds, totalDurationSeconds) {
        cubit.saveProgress(
          positionSeconds: positionSeconds,
          totalDurationSeconds: totalDurationSeconds,
        );
      },
      onSpeedChanged: cubit.setPlaybackSpeed,
      onToggleFullscreen: _toggleFullscreen,
    );

    if (_isFullscreen) {
      return Center(child: playerView);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: .stretch,
        children: [
          playerView,
          LessonInfoSection(
            course: state.course,
            lesson: state.lesson,
            isCompleted: state.isCompleted,
          ),
          NextLessonButton(
            nextLesson: state.nextLesson,
            isCurrentLessonCompleted: state.isCompleted,
            onTap: (nextLesson) async {
              await _playerKey.currentState?.pause();
              if (context.mounted) {
                await context.push(
                  AppRoutes.lessonPlayerPath(widget.courseId, nextLesson.id),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
