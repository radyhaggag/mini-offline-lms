import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/result.dart';
import '../../../domain/entities/continue_watching.dart';
import '../../../domain/use_cases/get_courses_use_case.dart';
import 'courses_list_state.dart';

/// Cubit managing the state of the courses list screen.
class CoursesListCubit extends Cubit<CoursesListState> {
  CoursesListCubit(this._getCoursesUseCase) : super(const CoursesListInitial());

  final GetCoursesUseCase _getCoursesUseCase;

  /// Loads courses and resolves the "Continue Watching" item if available.
  Future<void> loadCourses() async {
    emit(const CoursesListLoading());
    final result = await _getCoursesUseCase();
    switch (result) {
      case Success(:final data):
        final continueWatching = ContinueWatching.fromCourses(data);
        emit(
          CoursesListLoaded(courses: data, continueWatching: continueWatching),
        );
      case Failure(:final message):
        emit(CoursesListError(message));
    }
  }
}
