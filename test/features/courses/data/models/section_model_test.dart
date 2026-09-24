import 'package:flutter_test/flutter_test.dart';
import 'package:mini_offline_lms/features/courses/data/models/lesson_model.dart';
import 'package:mini_offline_lms/features/courses/data/models/section_model.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/section.dart';

void main() {
  group('SectionModel', () {
    const testJson = {
      'id': 'sec-1',
      'title': 'Section 1',
      'lessons': [
        {
          'id': 'les-1',
          'title': 'Lesson 1',
          'durationSec': 76,
          'video': 'assets/videos/lesson1.mp4',
        },
      ],
    };

    test('should be a subclass of Section domain entity', () {
      // Arrange & Act
      final model = SectionModel.fromJson(testJson);

      // Assert
      expect(model, isA<Section>());
    });

    test('should parse correctly from valid JSON map', () {
      // Arrange & Act
      final model = SectionModel.fromJson(testJson);

      // Assert
      expect(model.id, equals('sec-1'));
      expect(model.title, equals('Section 1'));
      expect(model.lessons.length, equals(1));
      expect(model.lessons.first.id, equals('les-1'));
    });

    test('should serialize correctly to JSON map', () {
      // Arrange
      const model = SectionModel(
        id: 's1',
        title: 'Title',
        lessons: [
          LessonModel(id: 'l1', title: 'L1', durationSec: 50, video: 'v.mp4'),
        ],
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], equals('s1'));
      expect(json['title'], equals('Title'));
      final lessons = json['lessons'] as List;
      expect(lessons.length, equals(1));
    });
  });
}
