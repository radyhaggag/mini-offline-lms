import 'course.dart';
import 'lesson.dart';
import 'section.dart';

/// Represents an in-progress lesson ready to be resumed.
class ContinueWatching {
  const ContinueWatching({
    required this.course,
    required this.section,
    required this.lesson,
  });

  final Course course;
  final Section section;
  final Lesson lesson;

  /// Finds the first in-progress lesson across all courses.
  /// Decomposed into single-loop helpers for readability.
  static ContinueWatching? fromCourses(List<Course> courses) {
    for (final course in courses) {
      final item = _findInProgressInCourse(course);
      if (item != null) return item;
    }
    return null;
  }

  static ContinueWatching? _findInProgressInCourse(Course course) {
    for (final section in course.sections) {
      final lesson = section.inProgressLesson;
      if (lesson != null) {
        return ContinueWatching(
          course: course,
          section: section,
          lesson: lesson,
        );
      }
    }
    return null;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContinueWatching &&
          runtimeType == other.runtimeType &&
          course == other.course &&
          section == other.section &&
          lesson == other.lesson;

  @override
  int get hashCode => Object.hash(course, section, lesson);
}
