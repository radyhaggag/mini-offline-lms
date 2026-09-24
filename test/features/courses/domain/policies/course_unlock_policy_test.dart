import 'package:flutter_test/flutter_test.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/course.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/lesson.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/section.dart';
import 'package:mini_offline_lms/features/courses/domain/policies/course_unlock_policy.dart';

void main() {
  group('CourseUnlockPolicy - 90% Completion Rule', () {
    test('should mark lesson as completed when watched duration reaches exactly 90%', () {
      // Arrange
      const durationSec = 100;
      const positionSec = 90;

      // Act
      final result = CourseUnlockPolicy.isLessonCompleted(
        positionSec: positionSec,
        durationSec: durationSec,
      );

      // Assert
      expect(result, isTrue);
    });

    test(
      'should mark lesson as completed when watched duration exceeds 90%',
      () {
        // Arrange
        const durationSec = 100;
        const positionSec = 95;

        // Act
        final result = CourseUnlockPolicy.isLessonCompleted(
          positionSec: positionSec,
          durationSec: durationSec,
        );

        // Assert
        expect(result, isTrue);
      },
    );

    test(
      'should not mark lesson as completed when watched duration is under 90%',
      () {
        // Arrange
        const durationSec = 100;
        const positionSec = 89;

        // Act
        final result = CourseUnlockPolicy.isLessonCompleted(
          positionSec: positionSec,
          durationSec: durationSec,
        );

        // Assert
        expect(result, isFalse);
      },
    );

    test('should return true when isAlreadyCompleted is true even if position is zero', () {
      // Arrange
      const durationSec = 100;
      const positionSec = 0;

      // Act
      final result = CourseUnlockPolicy.isLessonCompleted(
        positionSec: positionSec,
        durationSec: durationSec,
        isAlreadyCompleted: true,
      );

      // Assert
      expect(result, isTrue);
    });

    test('should return false when duration is zero or negative', () {
      // Arrange
      const durationSec = 0;
      const positionSec = 10;

      // Act
      final result = CourseUnlockPolicy.isLessonCompleted(
        positionSec: positionSec,
        durationSec: durationSec,
      );

      // Assert
      expect(result, isFalse);
    });
  });

  group('CourseUnlockPolicy - Sequential Unlock Rule', () {
    const lesson1 = Lesson(
      id: 'l1',
      title: 'Lesson 1',
      durationSec: 100,
      video: 'v1.mp4',
    );
    const lesson2 = Lesson(
      id: 'l2',
      title: 'Lesson 2',
      durationSec: 100,
      video: 'v2.mp4',
    );
    const lesson3 = Lesson(
      id: 'l3',
      title: 'Lesson 3',
      durationSec: 100,
      video: 'v3.mp4',
    );

    const testSection = Section(
      id: 's1',
      title: 'Section 1',
      lessons: [lesson1, lesson2, lesson3],
    );

    const testCourse = Course(
      id: 'c1',
      title: 'Course 1',
      instructor: 'Dr. Test',
      thumbnail: 'thumb.png',
      sections: [testSection],
    );

    test('should keep first lesson unlocked when section has not started', () {
      // Arrange
      bool isCompleted(String id) => false;
      int getPosition(String id) => 0;

      // Act
      final updatedCourse = CourseUnlockPolicy.applyProgressToCourse(
        course: testCourse,
        isCompleted: isCompleted,
        getPosition: getPosition,
      );

      // Assert
      final lessons = updatedCourse.sections.first.lessons;
      expect(lessons[0].isLocked, isFalse);
      expect(lessons[1].isLocked, isTrue);
      expect(lessons[2].isLocked, isTrue);
    });

    test('should unlock second lesson when first lesson is completed', () {
      // Arrange
      bool isCompleted(String id) => id == 'l1';
      int getPosition(String id) => id == 'l1' ? 95 : 0;

      // Act
      final updatedCourse = CourseUnlockPolicy.applyProgressToCourse(
        course: testCourse,
        isCompleted: isCompleted,
        getPosition: getPosition,
      );

      // Assert
      final lessons = updatedCourse.sections.first.lessons;
      expect(lessons[0].isLocked, isFalse);
      expect(lessons[0].isCompleted, isTrue);
      expect(lessons[1].isLocked, isFalse);
      expect(lessons[2].isLocked, isTrue);
    });

    test(
      'should unlock all lessons when all previous lessons are completed',
      () {
        // Arrange
        bool isCompleted(String id) => true;
        int getPosition(String id) => 100;

        // Act
        final updatedCourse = CourseUnlockPolicy.applyProgressToCourse(
          course: testCourse,
          isCompleted: isCompleted,
          getPosition: getPosition,
        );

        // Assert
        final lessons = updatedCourse.sections.first.lessons;
        expect(lessons[0].isLocked, isFalse);
        expect(lessons[1].isLocked, isFalse);
        expect(lessons[2].isLocked, isFalse);
        expect(lessons.every((lesson) => lesson.isCompleted), isTrue);
      },
    );

    test(
      'should always unlock the first lesson of each section independently',
      () {
        // Arrange
        const section2Lesson1 = Lesson(
          id: 's2-l1',
          title: 'Section 2 Lesson 1',
          durationSec: 100,
          video: 'v4.mp4',
        );
        const section2 = Section(
          id: 's2',
          title: 'Section 2',
          lessons: [section2Lesson1],
        );
        final multiSectionCourse = testCourse.copyWith(
          sections: [testSection, section2],
        );

        // Act
        final updatedCourse = CourseUnlockPolicy.applyProgressToCourse(
          course: multiSectionCourse,
          isCompleted: (_) => false,
          getPosition: (_) => 0,
        );

        // Assert
        expect(updatedCourse.sections[0].lessons[0].isLocked, isFalse);
        expect(updatedCourse.sections[1].lessons[0].isLocked, isFalse);
      },
    );
  });
}
