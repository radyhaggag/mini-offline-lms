import '../../../courses/domain/policies/course_unlock_policy.dart';
import '../entities/lesson_progress.dart';
import '../repositories/progress_repository.dart';

/// Persists lesson playback position and enforces the 90% completion rule.
class SaveLessonProgressUseCase {
  const SaveLessonProgressUseCase(this._progressRepository);

  final ProgressRepository _progressRepository;

  Future<LessonProgress> call({
    required String lessonId,
    required int positionSeconds,
    required int totalDurationSeconds,
  }) async {
    await _progressRepository.savePosition(lessonId, positionSeconds);

    var isCompleted = _progressRepository.isCompleted(lessonId);
    if (!isCompleted) {
      final reachedThreshold = CourseUnlockPolicy.isLessonCompleted(
        positionSec: positionSeconds,
        durationSec: totalDurationSeconds,
      );
      if (reachedThreshold) {
        await _progressRepository.markCompleted(lessonId);
        isCompleted = true;
      }
    }

    return LessonProgress(
      lessonId: lessonId,
      positionSec: positionSeconds,
      isCompleted: isCompleted,
    );
  }
}
