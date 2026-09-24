import 'package:flutter_test/flutter_test.dart';
import 'package:mini_offline_lms/features/courses/data/models/lesson_model.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/lesson.dart';

void main() {
  group('LessonModel', () {
    const testJson = {
      'id': 'les-1',
      'title': 'Lesson 1',
      'durationSec': 76,
      'video': 'assets/videos/lesson1.mp4',
    };

    test('should be a subclass of Lesson domain entity', () {
      // Arrange & Act
      final model = LessonModel.fromJson(testJson);

      // Assert
      expect(model, isA<Lesson>());
    });

    test('should parse correctly from valid JSON map', () {
      // Arrange & Act
      final model = LessonModel.fromJson(testJson);

      // Assert
      expect(model.id, equals('les-1'));
      expect(model.title, equals('Lesson 1'));
      expect(model.durationSec, equals(76));
      expect(model.video, equals('assets/videos/lesson1.mp4'));
    });

    test('should serialize correctly to JSON map', () {
      // Arrange
      const model = LessonModel(
        id: 'les-1',
        title: 'Lesson 1',
        durationSec: 76,
        video: 'assets/videos/lesson1.mp4',
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], equals('les-1'));
      expect(json['title'], equals('Lesson 1'));
      expect(json['durationSec'], equals(76));
      expect(json['video'], equals('assets/videos/lesson1.mp4'));
    });
  });
}
