import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_offline_lms/core/error/result.dart';
import 'package:mini_offline_lms/features/courses/data/data_sources/courses_data_source.dart';
import 'package:mini_offline_lms/features/courses/data/models/course_model.dart';
import 'package:mini_offline_lms/features/courses/data/repositories/courses_repository_impl.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/course.dart';

class MockCoursesDataSource extends Mock implements CoursesDataSource {}

void main() {
  late MockCoursesDataSource mockDataSource;
  late CoursesRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockCoursesDataSource();
    repository = CoursesRepositoryImpl(mockDataSource);
  });

  const testCourse = CourseModel(
    id: 'c1',
    title: 'Course 1',
    instructor: 'Dr. Test',
    thumbnail: 'thumb.png',
    sections: [],
  );

  group('getCourses', () {
    test(
      'should return Success with courses when data source returns list',
      () async {
        // Arrange
        when(() => mockDataSource.getCourses())
            .thenAnswer((_) async => [testCourse]);

        // Act
        final result = await repository.getCourses();

        // Assert
        expect(result, isA<Success<List<Course>>>());
        final data = (result as Success<List<Course>>).data;
        expect(data.length, equals(1));
        expect(data.first.id, equals('c1'));
        verify(() => mockDataSource.getCourses()).called(1);
      },
    );

    test(
      'should return Failure with localization key when data source throws',
      () async {
        // Arrange
        when(() => mockDataSource.getCourses())
            .thenThrow(Exception('Disk read failed'));

        // Act
        final result = await repository.getCourses();

        // Assert
        expect(result, isA<Failure<List<Course>>>());
        expect(
          (result as Failure<List<Course>>).message,
          equals('coursesLoadError'),
        );
      },
    );
  });

  group('getCourseById', () {
    test('should return Success with matching course when ID exists', () async {
      // Arrange
      when(() => mockDataSource.getCourses())
          .thenAnswer((_) async => [testCourse]);

      // Act
      final result = await repository.getCourseById('c1');

      // Assert
      expect(result, isA<Success<Course>>());
      final data = (result as Success<Course>).data;
      expect(data.id, equals('c1'));
    });

    test(
      'should return Failure when matching course ID does not exist',
      () async {
        // Arrange
        when(() => mockDataSource.getCourses())
            .thenAnswer((_) async => [testCourse]);

        // Act
        final result = await repository.getCourseById('non-existent');

        // Assert
        expect(result, isA<Failure<Course>>());
        expect((result as Failure<Course>).message, equals('coursesLoadError'));
      },
    );

    test('should return Failure when data source throws', () async {
      // Arrange
      when(() => mockDataSource.getCourses()).thenThrow(Exception('Error'));

      // Act
      final result = await repository.getCourseById('c1');

      // Assert
      expect(result, isA<Failure<Course>>());
      expect((result as Failure<Course>).message, equals('coursesLoadError'));
    });
  });
}
