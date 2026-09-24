/// Status of a lesson reflecting watch progress.
enum LessonStatus { notStarted, inProgress, completed }

/// Pure domain entity representing a lesson in a course.
class Lesson {
  const Lesson({
    required this.id,
    required this.title,
    required this.durationSec,
    required this.video,
    this.isCompleted = false,
    this.isLocked = false,
    this.lastPositionSec = 0,
  });

  final String id;
  final String title;
  final int durationSec;
  final String video;
  final bool isCompleted;
  final bool isLocked;
  final int lastPositionSec;

  /// Derived status based on completion flag and last watched position.
  LessonStatus get status {
    if (isCompleted) return .completed;
    if (lastPositionSec > 0) return .inProgress;
    return .notStarted;
  }

  Lesson copyWith({
    String? id,
    String? title,
    int? durationSec,
    String? video,
    bool? isCompleted,
    bool? isLocked,
    int? lastPositionSec,
  }) {
    return Lesson(
      id: id ?? this.id,
      title: title ?? this.title,
      durationSec: durationSec ?? this.durationSec,
      video: video ?? this.video,
      isCompleted: isCompleted ?? this.isCompleted,
      isLocked: isLocked ?? this.isLocked,
      lastPositionSec: lastPositionSec ?? this.lastPositionSec,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Lesson &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          durationSec == other.durationSec &&
          video == other.video &&
          isCompleted == other.isCompleted &&
          isLocked == other.isLocked &&
          lastPositionSec == other.lastPositionSec;

  @override
  int get hashCode => Object.hash(
    id,
    title,
    durationSec,
    video,
    isCompleted,
    isLocked,
    lastPositionSec,
  );
}
