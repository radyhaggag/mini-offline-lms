import 'package:flutter/foundation.dart';

import '../../../domain/entities/continue_watching.dart';
import '../../../domain/entities/course.dart';

/// States for the courses list view.
sealed class CoursesListState {
  const CoursesListState();
}

final class CoursesListInitial extends CoursesListState {
  const CoursesListInitial();
}

final class CoursesListLoading extends CoursesListState {
  const CoursesListLoading();
}

final class CoursesListLoaded extends CoursesListState {
  const CoursesListLoaded({
    required this.courses,
    this.continueWatching,
    this.searchQuery = '',
  });

  final List<Course> courses;
  final ContinueWatching? continueWatching;
  final String searchQuery;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoursesListLoaded &&
          runtimeType == other.runtimeType &&
          listEquals(courses, other.courses) &&
          continueWatching == other.continueWatching &&
          searchQuery == other.searchQuery;

  @override
  int get hashCode =>
      Object.hash(Object.hashAll(courses), continueWatching, searchQuery);
}

final class CoursesListError extends CoursesListState {
  const CoursesListError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoursesListError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
