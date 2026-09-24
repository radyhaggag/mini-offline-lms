import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_offline_lms/features/courses/data/data_sources/courses_data_source.dart';

class MockAssetBundle extends Mock implements AssetBundle {}

void main() {
  late MockAssetBundle mockBundle;
  late CoursesLocalDataSource dataSource;

  setUp(() {
    mockBundle = MockAssetBundle();
    dataSource = CoursesLocalDataSource(bundle: mockBundle);
  });

  const testJsonString = '''
  {
    "courses": [
      {
        "id": "c1",
        "title": "Course 1",
        "instructor": "Dr. Test",
        "thumbnail": "thumb.png",
        "sections": [
          {
            "id": "s1",
            "title": "Section 1",
            "lessons": [
              {
                "id": "l1",
                "title": "Lesson 1",
                "durationSec": 90,
                "video": "v1.mp4"
              }
            ]
          }
        ]
      }
    ]
  }
  ''';

  test('should load and parse courses list from asset bundle', () async {
    // Arrange
    when(() => mockBundle.loadString('assets/data/courses.json'))
        .thenAnswer((_) async => testJsonString);

    // Act
    final courses = await dataSource.getCourses();

    // Assert
    expect(courses.length, equals(1));
    expect(courses.first.id, equals('c1'));
    expect(courses.first.sections.first.lessons.first.durationSec, equals(90));
    verify(() => mockBundle.loadString('assets/data/courses.json')).called(1);
  });

  test('should return empty list when json has empty courses array', () async {
    // Arrange
    when(() => mockBundle.loadString('assets/data/courses.json'))
        .thenAnswer((_) async => '{"courses": []}');

    // Act
    final courses = await dataSource.getCourses();

    // Assert
    expect(courses, isEmpty);
  });

  test('should throw exception when asset bundle fails to load', () async {
    // Arrange
    when(() => mockBundle.loadString('assets/data/courses.json'))
        .thenThrow(Exception('Asset not found'));

    // Act & Assert
    expect(() => dataSource.getCourses(), throwsA(isA<Exception>()));
  });
}
