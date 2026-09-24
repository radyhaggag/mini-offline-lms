import '../../../../core/error/result.dart';
import '../../../courses/domain/entities/course.dart';
import '../../../courses/domain/entities/lesson.dart';
import '../../../courses/domain/policies/course_unlock_policy.dart';
import '../../../courses/domain/repositories/courses_repository.dart';
import '../repositories/progress_repository.dart';

/// Resolves the next sequential lesson in a course and verifies its unlock state.
class GetNextLessonUseCase {
  const GetNextLessonUseCase({
    required this.coursesRepository,
    required this.progressRepository,
  });

  final CoursesRepository coursesRepository;
  final ProgressRepository progressRepository;

  Future<Result<Lesson?>> call({
    required String courseId,
    required String currentLessonId,
  }) async {
    final result = await coursesRepository.getCourseById(courseId);

    return switch (result) {
      Success(:final data) => Success(
        fromCourse(course: data, currentLessonId: currentLessonId),
      ),
      Failure(:final message) => Failure(message),
    };
  }

  /// Resolves the next lesson from an existing course entity with applied progress.
  Lesson? fromCourse({
    required Course course,
    required String currentLessonId,
  }) {
    final evaluatedCourse = CourseUnlockPolicy.applyProgressToCourse(
      course: course,
      isCompleted: progressRepository.isCompleted,
      getPosition: progressRepository.getPosition,
    );

    final allLessons = [
      for (final section in evaluatedCourse.sections)
        for (final lesson in section.lessons) lesson,
    ];

    final currentIndex = allLessons.indexWhere(
      (lesson) => lesson.id == currentLessonId,
    );
    if (currentIndex == -1 || currentIndex >= allLessons.length - 1) {
      return null;
    }

    return allLessons[currentIndex + 1];
  }
}
