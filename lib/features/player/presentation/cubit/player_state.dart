import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/lesson.dart';

/// Base state for [PlayerCubit].
sealed class PlayerState {
  const PlayerState();
}

/// Initial uninitialized state.
final class PlayerInitial extends PlayerState {
  const PlayerInitial();
}

/// State while loading course and lesson data.
final class PlayerLoading extends PlayerState {
  const PlayerLoading();
}

/// State when video data and initial progress are loaded.
final class PlayerLoaded extends PlayerState {
  const PlayerLoaded({
    required this.course,
    required this.lesson,
    required this.initialPositionSec,
    required this.isCompleted,
    required this.playbackSpeed,
    this.nextLesson,
  });

  final Course course;
  final Lesson lesson;
  final int initialPositionSec;
  final bool isCompleted;
  final double playbackSpeed;
  final Lesson? nextLesson;

  PlayerLoaded copyWith({
    Course? course,
    Lesson? lesson,
    int? initialPositionSec,
    bool? isCompleted,
    double? playbackSpeed,
    Lesson? Function()? nextLesson,
  }) {
    return PlayerLoaded(
      course: course ?? this.course,
      lesson: lesson ?? this.lesson,
      initialPositionSec: initialPositionSec ?? this.initialPositionSec,
      isCompleted: isCompleted ?? this.isCompleted,
      playbackSpeed: playbackSpeed ?? this.playbackSpeed,
      nextLesson: nextLesson != null ? nextLesson() : this.nextLesson,
    );
  }
}

/// State when an error occurs while preparing the player.
final class PlayerError extends PlayerState {
  const PlayerError(this.message);
  final String message;
}
