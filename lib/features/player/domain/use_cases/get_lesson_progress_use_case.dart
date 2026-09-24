import '../entities/lesson_progress.dart';
import '../repositories/progress_repository.dart';

/// Retrieves the saved watch progress for a lesson.
class GetLessonProgressUseCase {
  const GetLessonProgressUseCase(this._progressRepository);

  final ProgressRepository _progressRepository;

  LessonProgress call(String lessonId) {
    final position = _progressRepository.getPosition(lessonId);
    final completed = _progressRepository.isCompleted(lessonId);
    return LessonProgress(
      lessonId: lessonId,
      positionSec: position,
      isCompleted: completed,
    );
  }
}
