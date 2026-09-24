import 'package:flutter_test/flutter_test.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/course.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/lesson.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/section.dart';

void main() {
  group('Course - Progress Calculation', () {
    const completedLesson = Lesson(
      id: 'l1',
      title: 'Completed',
      durationSec: 100,
      video: 'v1.mp4',
      isCompleted: true,
    );
    const uncompletedLesson = Lesson(
      id: 'l2',
      title: 'Uncompleted',
      durationSec: 100,
      video: 'v2.mp4',
      isCompleted: false,
    );

    test('should return 0.0 percent when course has zero lessons', () {
      // Arrange
      const emptyCourse = Course(
        id: 'c-empty',
        title: 'Empty Course',
        instructor: 'Dr. Test',
        thumbnail: 'thumb.png',
        sections: [],
      );

      // Act
      final progress = emptyCourse.progressPercentage;

      // Assert
      expect(progress, equals(0.0));
      expect(emptyCourse.totalLessonsCount, equals(0));
      expect(emptyCourse.completedLessonsCount, equals(0));
    });

    test('should return 0.0 percent when no lessons are completed', () {
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
            lessons: [uncompletedLesson, uncompletedLesson],
          ),
        ],
      );

      // Act
      final progress = course.progressPercentage;

      // Assert
      expect(progress, equals(0.0));
      expect(course.totalLessonsCount, equals(2));
      expect(course.completedLessonsCount, equals(0));
    });

    test(
      'should return 50.0 percent when exactly half of lessons are completed',
      () {
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
              lessons: [completedLesson, uncompletedLesson],
            ),
          ],
        );

        // Act
        final progress = course.progressPercentage;

        // Assert
        expect(progress, equals(50.0));
        expect(course.totalLessonsCount, equals(2));
        expect(course.completedLessonsCount, equals(1));
      },
    );

    test('should return 100.0 percent when all lessons are completed across multiple sections', () {
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
            lessons: [completedLesson, completedLesson],
          ),
          Section(id: 's2', title: 'Section 2', lessons: [completedLesson]),
        ],
      );

      // Act
      final progress = course.progressPercentage;

      // Assert
      expect(progress, equals(100.0));
      expect(course.totalLessonsCount, equals(3));
      expect(course.completedLessonsCount, equals(3));
    });

    test('should correctly aggregate total and completed lessons across multiple sections', () {
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
            lessons: [completedLesson, uncompletedLesson],
          ),
          Section(
            id: 's2',
            title: 'Section 2',
            lessons: [uncompletedLesson, uncompletedLesson],
          ),
        ],
      );

      // Act
      final progress = course.progressPercentage;

      // Assert
      expect(course.totalLessonsCount, equals(4));
      expect(course.completedLessonsCount, equals(1));
      expect(progress, equals(25.0));
    });
  });
}
