import 'package:flutter_test/flutter_test.dart';
import 'package:mini_offline_lms/features/courses/data/models/course_model.dart';
import 'package:mini_offline_lms/features/courses/data/models/lesson_model.dart';
import 'package:mini_offline_lms/features/courses/data/models/section_model.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/course.dart';

void main() {
  group('CourseModel', () {
    const testJson = {
      'id': 'anatomy-101',
      'title': 'مقدمة في التشريح',
      'instructor': 'د. سارة أحمد',
      'thumbnail': 'assets/images/anatomy.png',
      'sections': [
        {
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
        },
      ],
    };

    test('should be a subclass of Course domain entity', () {
      // Arrange & Act
      final model = CourseModel.fromJson(testJson);

      // Assert
      expect(model, isA<Course>());
    });

    test('should parse correctly from valid JSON map', () {
      // Arrange & Act
      final model = CourseModel.fromJson(testJson);

      // Assert
      expect(model.id, equals('anatomy-101'));
      expect(model.title, equals('مقدمة في التشريح'));
      expect(model.instructor, equals('د. سارة أحمد'));
      expect(model.thumbnail, equals('assets/images/anatomy.png'));
      expect(model.sections.length, equals(1));
      expect(model.sections.first.lessons.length, equals(1));
      expect(model.sections.first.lessons.first.durationSec, equals(76));
    });

    test('should serialize correctly to JSON map matching input', () {
      // Arrange
      const model = CourseModel(
        id: 'c1',
        title: 'Title',
        instructor: 'Instructor',
        thumbnail: 'thumb.png',
        sections: [
          SectionModel(
            id: 's1',
            title: 'Sec Title',
            lessons: [
              LessonModel(
                id: 'l1',
                title: 'Les Title',
                durationSec: 100,
                video: 'v.mp4',
              ),
            ],
          ),
        ],
      );

      // Act
      final json = model.toJson();

      // Assert
      expect(json['id'], equals('c1'));
      expect(json['title'], equals('Title'));
      expect(json['instructor'], equals('Instructor'));
      expect(json['thumbnail'], equals('thumb.png'));
      final sections = json['sections'] as List;
      expect(sections.length, equals(1));
    });
  });
}
