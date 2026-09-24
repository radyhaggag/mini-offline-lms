import '../../../domain/entities/course.dart';

/// States for the course details view.
sealed class CourseDetailsState {
  const CourseDetailsState();
}

final class CourseDetailsInitial extends CourseDetailsState {
  const CourseDetailsInitial();
}

final class CourseDetailsLoading extends CourseDetailsState {
  const CourseDetailsLoading();
}

final class CourseDetailsLoaded extends CourseDetailsState {
  const CourseDetailsLoaded(this.course);

  final Course course;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseDetailsLoaded &&
          runtimeType == other.runtimeType &&
          course == other.course;

  @override
  int get hashCode => course.hashCode;
}

final class CourseDetailsError extends CourseDetailsState {
  const CourseDetailsError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseDetailsError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
