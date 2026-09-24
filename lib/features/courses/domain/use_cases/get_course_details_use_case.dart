import '../../../../core/error/result.dart';
import '../../../player/domain/repositories/progress_repository.dart';
import '../entities/course.dart';
import '../policies/course_unlock_policy.dart';
import '../repositories/courses_repository.dart';

/// Use case that fetches a specific course by ID with evaluated progress and unlock state.
class GetCourseDetailsUseCase {
  const GetCourseDetailsUseCase({
    required this.coursesRepository,
    required this.progressRepository,
  });

  final CoursesRepository coursesRepository;
  final ProgressRepository progressRepository;

  Future<Result<Course>> call(String courseId) async {
    final result = await coursesRepository.getCourseById(courseId);

    return switch (result) {
      Success(:final data) => Success(
        CourseUnlockPolicy.applyProgressToCourse(
          course: data,
          isCompleted: progressRepository.isCompleted,
          getPosition: progressRepository.getPosition,
        ),
      ),
      Failure(:final message) => Failure(message),
    };
  }
}
