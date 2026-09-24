import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/app_routes.dart';
import '../../../notes/presentation/widgets/lesson_notes_section.dart';
import '../cubit/player_cubit.dart';
import '../cubit/player_state.dart';
import 'lesson_info_section.dart';
import 'next_lesson_button.dart';
import 'video_player_view.dart';

/// Scrollable body displayed when the player has successfully loaded the lesson.
class PlayerLoadedBody extends StatelessWidget {
  const PlayerLoadedBody({
    super.key,
    required this.state,
    required this.playerKey,
    required this.isFullscreen,
    required this.courseId,
    required this.onToggleFullscreen,
  });

  final PlayerLoaded state;
  final GlobalKey<VideoPlayerViewState> playerKey;
  final bool isFullscreen;
  final String courseId;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PlayerCubit>();

    final playerView = VideoPlayerView(
      key: playerKey,
      videoAssetPath: state.lesson.video,
      lessonTitle: state.lesson.title,
      initialPositionSec: state.initialPositionSec,
      playbackSpeed: state.playbackSpeed,
      isFullscreen: isFullscreen,
      onProgressUpdate: (positionSeconds, totalDurationSeconds) {
        cubit.saveProgress(
          positionSeconds: positionSeconds,
          totalDurationSeconds: totalDurationSeconds,
        );
      },
      onSpeedChanged: cubit.setPlaybackSpeed,
      onToggleFullscreen: onToggleFullscreen,
    );

    if (isFullscreen) {
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
              await playerKey.currentState?.pause();
              if (context.mounted) {
                await context.push(
                  AppRoutes.lessonPlayerPath(courseId, nextLesson.id),
                );
              }
            },
          ),
          LessonNotesSection(lessonId: state.lesson.id),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
