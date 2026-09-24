/// Pure domain entity representing progress for a lesson.
class LessonProgress {
  const LessonProgress({
    required this.lessonId,
    required this.positionSec,
    required this.isCompleted,
  });

  final String lessonId;
  final int positionSec;
  final bool isCompleted;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonProgress &&
          runtimeType == other.runtimeType &&
          lessonId == other.lessonId &&
          positionSec == other.positionSec &&
          isCompleted == other.isCompleted;

  @override
  int get hashCode => Object.hash(lessonId, positionSec, isCompleted);
}
