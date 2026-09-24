import 'package:flutter_test/flutter_test.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/continue_watching.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/course.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/lesson.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/section.dart';

void main() {
  group('ContinueWatching - Resolution', () {
    const notStartedLesson = Lesson(
      id: 'l1',
      title: 'Not Started',
      durationSec: 100,
      video: 'v1.mp4',
      lastPositionSec: 0,
    );

    const inProgressLesson1 = Lesson(
      id: 'l2',
      title: 'In Progress 1',
      durationSec: 100,
      video: 'v2.mp4',
      lastPositionSec: 45,
    );

    const inProgressLesson2 = Lesson(
      id: 'l3',
      title: 'In Progress 2',
      durationSec: 100,
      video: 'v3.mp4',
      lastPositionSec: 20,
    );

    const completedLesson = Lesson(
      id: 'l4',
      title: 'Completed',
      durationSec: 100,
      video: 'v4.mp4',
      isCompleted: true,
      lastPositionSec: 95,
    );

    test('should return null when courses list is empty', () {
      // Arrange
      final courses = <Course>[];

      // Act
      final result = ContinueWatching.fromCourses(courses);

      // Assert
      expect(result, isNull);
    });

    test('should return null when no lessons are in progress', () {
      // Arrange
      const course = Course(
        id: 'c1',
        title: 'Course 1',
        instructor: 'Dr. Test',
        thumbnail: 'thumb.png',
        sections: [
          Section(
            id: 's1',
            title: 'Section 1',
            lessons: [notStartedLesson, completedLesson],
          ),
        ],
      );

      // Act
      final result = ContinueWatching.fromCourses([course]);

      // Assert
      expect(result, isNull);
    });

    test('should return the first in-progress lesson across multiple sections and courses', () {
      // Arrange
      const course1 = Course(
        id: 'c1',
        title: 'Course 1',
        instructor: 'Dr. Test 1',
        thumbnail: 'thumb1.png',
        sections: [
          Section(id: 'c1-s1', title: 'C1 S1', lessons: [completedLesson]),
          Section(id: 'c1-s2', title: 'C1 S2', lessons: [inProgressLesson1]),
        ],
      );

      const course2 = Course(
        id: 'c2',
        title: 'Course 2',
        instructor: 'Dr. Test 2',
        thumbnail: 'thumb2.png',
        sections: [
          Section(id: 'c2-s1', title: 'C2 S1', lessons: [inProgressLesson2]),
        ],
      );

      // Act
      final result = ContinueWatching.fromCourses([course1, course2]);

      // Assert
      expect(result, isNotNull);
      expect(result!.course.id, equals('c1'));
      expect(result.section.id, equals('c1-s2'));
      expect(result.lesson.id, equals('l2'));
    });
  });
}
