import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/result.dart';
import '../../../domain/use_cases/get_course_details_use_case.dart';
import 'course_details_state.dart';

/// Cubit managing the state of the course details screen.
class CourseDetailsCubit extends Cubit<CourseDetailsState> {
  CourseDetailsCubit(this._getCourseDetailsUseCase)
    : super(const CourseDetailsInitial());

  final GetCourseDetailsUseCase _getCourseDetailsUseCase;

  /// Loads course details by [courseId].
  Future<void> loadCourse(String courseId) async {
    emit(const CourseDetailsLoading());
    final result = await _getCourseDetailsUseCase(courseId);
    switch (result) {
      case Success(:final data):
        emit(CourseDetailsLoaded(data));
      case Failure(:final message):
        emit(CourseDetailsError(message));
    }
  }
}
