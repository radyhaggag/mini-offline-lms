import 'package:flutter_test/flutter_test.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/lesson.dart';

void main() {
  group('Lesson - Status Evaluation', () {
    test('should return notStarted status when lesson is not completed and position is zero', () {
      // Arrange
      const lesson = Lesson(
        id: 'l1',
        title: 'Lesson 1',
        durationSec: 100,
        video: 'v1.mp4',
        isCompleted: false,
        lastPositionSec: 0,
      );

      // Act
      final status = lesson.status;

      // Assert
      expect(status, equals(LessonStatus.notStarted));
    });

    test('should return inProgress status when lesson is not completed but position is positive', () {
      // Arrange
      const lesson = Lesson(
        id: 'l1',
        title: 'Lesson 1',
        durationSec: 100,
        video: 'v1.mp4',
        isCompleted: false,
        lastPositionSec: 45,
      );

      // Act
      final status = lesson.status;

      // Assert
      expect(status, equals(LessonStatus.inProgress));
    });

    test('should return completed status when isCompleted is true regardless of position', () {
      // Arrange
      const lesson = Lesson(
        id: 'l1',
        title: 'Lesson 1',
        durationSec: 100,
        video: 'v1.mp4',
        isCompleted: true,
        lastPositionSec: 20,
      );

      // Act
      final status = lesson.status;

      // Assert
      expect(status, equals(LessonStatus.completed));
    });
  });
}
