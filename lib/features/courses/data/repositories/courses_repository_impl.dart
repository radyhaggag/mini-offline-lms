import '../../../../core/error/result.dart';
import '../../domain/entities/course.dart';
import '../../domain/repositories/courses_repository.dart';
import '../data_sources/courses_data_source.dart';

/// Implementation of [CoursesRepository] solely responsible for courses data retrieval.
class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl(this._coursesDataSource);

  final CoursesDataSource _coursesDataSource;

  @override
  Future<Result<List<Course>>> getCourses() async {
    try {
      final courses = await _coursesDataSource.getCourses();
      return Success(courses);
    } catch (_) {
      return const Failure('coursesLoadError');
    }
  }

  @override
  Future<Result<Course>> getCourseById(String id) async {
    try {
      final courses = await _coursesDataSource.getCourses();
      final course = courses.where((course) => course.id == id).firstOrNull;
      if (course == null) {
        return const Failure('coursesLoadError');
      }
      return Success(course);
    } catch (_) {
      return const Failure('coursesLoadError');
    }
  }
}
