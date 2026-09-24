import '../../../../core/error/result.dart';
import '../entities/course.dart';

/// Abstract contract for courses repository.
abstract class CoursesRepository {
  /// Fetches all courses with populated progress and sequential unlock state.
  Future<Result<List<Course>>> getCourses();

  /// Fetches a single course by its ID with populated progress and unlock state.
  Future<Result<Course>> getCourseById(String id);

  /// Searches courses matching [query] with populated progress and unlock state.
  Future<Result<List<Course>>> searchCourses(String query);
}
