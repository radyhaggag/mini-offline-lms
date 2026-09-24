import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../../courses/domain/use_cases/get_course_details_use_case.dart';
import '../../domain/use_cases/get_lesson_progress_use_case.dart';
import '../../domain/use_cases/get_next_lesson_use_case.dart';
import '../../domain/use_cases/get_playback_speed_use_case.dart';
import '../../domain/use_cases/save_lesson_progress_use_case.dart';
import '../../domain/use_cases/save_playback_speed_use_case.dart';
import 'player_state.dart';

/// Cubit managing lesson player data, watch progress, and speed preferences.
class PlayerCubit extends Cubit<PlayerState> {
  PlayerCubit({
    required this.getCourseDetailsUseCase,
    required this.getLessonProgressUseCase,
    required this.saveLessonProgressUseCase,
    required this.getNextLessonUseCase,
    required this.getPlaybackSpeedUseCase,
    required this.savePlaybackSpeedUseCase,
  }) : super(const PlayerInitial());

  final GetCourseDetailsUseCase getCourseDetailsUseCase;
  final GetLessonProgressUseCase getLessonProgressUseCase;
  final SaveLessonProgressUseCase saveLessonProgressUseCase;
  final GetNextLessonUseCase getNextLessonUseCase;
  final GetPlaybackSpeedUseCase getPlaybackSpeedUseCase;
  final SavePlaybackSpeedUseCase savePlaybackSpeedUseCase;

  /// Loads course data, target lesson, last saved position, and next lesson.
  Future<void> init({
    required String courseId,
    required String lessonId,
  }) async {
    emit(const PlayerLoading());

    final courseResult = await getCourseDetailsUseCase(courseId);
    if (isClosed) return;
    switch (courseResult) {
      case Success(:final data):
        final allLessons = [
          for (final section in data.sections)
            for (final lesson in section.lessons) lesson,
        ];
        final lesson = allLessons
            .where((candidate) => candidate.id == lessonId)
            .firstOrNull;
        if (lesson == null) {
          emit(const PlayerError('videoLoadError'));
          return;
        }

        final progress = getLessonProgressUseCase(lessonId);
        final speed = getPlaybackSpeedUseCase();
        final nextLessonResult = await getNextLessonUseCase(
          courseId: courseId,
          currentLessonId: lessonId,
        );
        if (isClosed) return;
        final nextLesson = switch (nextLessonResult) {
          Success(:final data) => data,
          _ => null,
        };

        emit(
          PlayerLoaded(
            course: data,
            lesson: lesson,
            initialPositionSec: progress.positionSec,
            isCompleted: progress.isCompleted,
            playbackSpeed: speed,
            nextLesson: nextLesson,
          ),
        );
      case Failure(:final message):
        emit(PlayerError(message));
    }
  }

  /// Persists watch position and updates completion and unlock state if threshold is reached.
  Future<void> saveProgress({
    required int positionSeconds,
    required int totalDurationSeconds,
  }) async {
    final currentState = state;
    if (currentState is! PlayerLoaded) return;

    final updated = await saveLessonProgressUseCase(
      lessonId: currentState.lesson.id,
      positionSeconds: positionSeconds,
      totalDurationSeconds: totalDurationSeconds,
    );
    if (isClosed) return;

    if (updated.isCompleted != currentState.isCompleted) {
      final nextLessonResult = await getNextLessonUseCase(
        courseId: currentState.course.id,
        currentLessonId: currentState.lesson.id,
      );
      if (isClosed) return;
      final nextLesson = switch (nextLessonResult) {
        Success(:final data) => data,
        _ => currentState.nextLesson,
      };

      emit(
        currentState.copyWith(
          isCompleted: updated.isCompleted,
          nextLesson: () => nextLesson,
        ),
      );
    }
  }

  /// Updates preferred playback speed in state and storage.
  Future<void> setPlaybackSpeed(double speed) async {
    final currentState = state;
    if (currentState is! PlayerLoaded) return;

    await savePlaybackSpeedUseCase(speed);
    if (isClosed) return;
    emit(currentState.copyWith(playbackSpeed: speed));
  }
}
