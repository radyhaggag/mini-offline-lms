import '../../../../core/error/result.dart';
import '../../../player/domain/repositories/progress_repository.dart';
import '../entities/course.dart';
import '../policies/course_unlock_policy.dart';
import '../repositories/courses_repository.dart';

/// Use case that fetches all courses and evaluates watch progress and unlock state.
class GetCoursesUseCase {
  const GetCoursesUseCase({
    required this.coursesRepository,
    required this.progressRepository,
  });

  final CoursesRepository coursesRepository;
  final ProgressRepository progressRepository;

  Future<Result<List<Course>>> call() async {
    final result = await coursesRepository.getCourses();

    return switch (result) {
      Success(:final data) => Success(
        CourseUnlockPolicy.applyProgressToCourses(
          courses: data,
          isCompleted: progressRepository.isCompleted,
          getPosition: progressRepository.getPosition,
        ),
      ),
      Failure(:final message) => Failure(message),
    };
  }
}
