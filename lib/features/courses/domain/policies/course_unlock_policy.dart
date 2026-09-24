import '../entities/course.dart';
import '../entities/lesson.dart';
import '../entities/section.dart';

/// Pure domain policy enforcing lesson completion threshold and sequential unlocking rules.
abstract class CourseUnlockPolicy {
  /// Completion threshold ratio (90% per specification).
  static const double completionThreshold = 0.9;

  /// Applies progress and unlocking to a list of courses.
  static List<Course> applyProgressToCourses({
    required List<Course> courses,
    required bool Function(String lessonId) isCompleted,
    required int Function(String lessonId) getPosition,
  }) {
    return courses
        .map(
          (course) => applyProgressToCourse(
            course: course,
            isCompleted: isCompleted,
            getPosition: getPosition,
          ),
        )
        .toList();
  }

  /// Applies progress and unlocking to a single course.
  static Course applyProgressToCourse({
    required Course course,
    required bool Function(String lessonId) isCompleted,
    required int Function(String lessonId) getPosition,
  }) {
    final updatedSections = course.sections.map((section) {
      return _applyProgressToSection(
        section: section,
        isCompleted: isCompleted,
        getPosition: getPosition,
      );
    }).toList();

    return course.copyWith(sections: updatedSections);
  }

  static Section _applyProgressToSection({
    required Section section,
    required bool Function(String lessonId) isCompleted,
    required int Function(String lessonId) getPosition,
  }) {
    var previousCompleted = true; // First lesson in section is always unlocked
    final updatedLessons = <Lesson>[];

    for (final lesson in section.lessons) {
      final position = getPosition(lesson.id);
      final completed = _isLessonCompleted(
        lesson: lesson,
        position: position,
        isAlreadyCompleted: isCompleted(lesson.id),
      );

      final isLocked = !previousCompleted;
      previousCompleted = completed;

      updatedLessons.add(
        lesson.copyWith(
          isCompleted: completed,
          isLocked: isLocked,
          lastPositionSec: position,
        ),
      );
    }

    return section.copyWith(lessons: updatedLessons);
  }

  static bool _isLessonCompleted({
    required Lesson lesson,
    required int position,
    required bool isAlreadyCompleted,
  }) {
    if (isAlreadyCompleted) return true;
    return lesson.durationSec > 0 &&
        position >= (lesson.durationSec * completionThreshold);
  }
}
