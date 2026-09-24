import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/result.dart';
import '../../../domain/entities/continue_watching.dart';
import '../../../domain/entities/course.dart';
import '../../../domain/use_cases/get_courses_use_case.dart';
import '../../../domain/use_cases/search_courses_use_case.dart';
import 'courses_list_state.dart';

/// Cubit managing the state of the courses list screen.
class CoursesListCubit extends Cubit<CoursesListState> {
  CoursesListCubit(this._getCoursesUseCase, this._searchCoursesUseCase)
    : super(const CoursesListInitial());

  final GetCoursesUseCase _getCoursesUseCase;
  final SearchCoursesUseCase _searchCoursesUseCase;

  List<Course> _allCourses = const [];
  ContinueWatching? _cachedContinueWatching;

  /// Loads courses and resolves the "Continue Watching" item if available.
  Future<void> loadCourses() async {
    emit(const CoursesListLoading());
    final result = await _getCoursesUseCase();
    switch (result) {
      case Success(:final data):
        _allCourses = data;
        _cachedContinueWatching = ContinueWatching.fromCourses(data);
        emit(
          CoursesListLoaded(
            courses: data,
            continueWatching: _cachedContinueWatching,
          ),
        );
      case Failure(:final message):
        emit(CoursesListError(message));
    }
  }

  /// Searches courses via [SearchCoursesUseCase] matching [query].
  Future<void> searchCourses(String query) async {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) {
      emit(
        CoursesListLoaded(
          courses: _allCourses,
          continueWatching: _cachedContinueWatching,
          searchQuery: '',
        ),
      );
      return;
    }

    final result = await _searchCoursesUseCase(trimmedQuery);
    switch (result) {
      case Success(:final data):
        emit(
          CoursesListLoaded(
            courses: data,
            continueWatching: _cachedContinueWatching,
            searchQuery: trimmedQuery,
          ),
        );
      case Failure(:final message):
        emit(CoursesListError(message));
    }
  }
}
