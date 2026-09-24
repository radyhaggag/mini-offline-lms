import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_offline_lms/core/error/result.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/course.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/lesson.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/section.dart';
import 'package:mini_offline_lms/features/courses/domain/repositories/courses_repository.dart';
import 'package:mini_offline_lms/features/courses/domain/use_cases/get_course_details_use_case.dart';
import 'package:mini_offline_lms/features/player/domain/repositories/progress_repository.dart';

class MockCoursesRepository extends Mock implements CoursesRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockCoursesRepository mockCoursesRepository;
  late MockProgressRepository mockProgressRepository;
  late GetCourseDetailsUseCase useCase;

  setUp(() {
    mockCoursesRepository = MockCoursesRepository();
    mockProgressRepository = MockProgressRepository();
    useCase = GetCourseDetailsUseCase(
      coursesRepository: mockCoursesRepository,
      progressRepository: mockProgressRepository,
    );
  });

  const testLesson1 = Lesson(
    id: 'l1',
    title: 'Lesson 1',
    durationSec: 100,
    video: 'v1.mp4',
  );
  const testLesson2 = Lesson(
    id: 'l2',
    title: 'Lesson 2',
    durationSec: 100,
    video: 'v2.mp4',
  );

  const testCourse = Course(
    id: 'c1',
    title: 'Course 1',
    instructor: 'Dr. Test',
    thumbnail: 'thumb.png',
    sections: [
      Section(
        id: 's1',
        title: 'Section 1',
        lessons: [testLesson1, testLesson2],
      ),
    ],
  );

  test(
    'should return Success with evaluated course when course exists',
    () async {
      // Arrange
      when(() => mockCoursesRepository.getCourseById('c1'))
          .thenAnswer((_) async => const Success(testCourse));
      when(() => mockProgressRepository.isCompleted('l1')).thenReturn(false);
      when(() => mockProgressRepository.isCompleted('l2')).thenReturn(false);
      when(() => mockProgressRepository.getPosition('l1')).thenReturn(10);
      when(() => mockProgressRepository.getPosition('l2')).thenReturn(0);

      // Act
      final result = await useCase('c1');

      // Assert
      expect(result, isA<Success<Course>>());
      final course = (result as Success<Course>).data;
      expect(course.id, equals('c1'));
      final lessons = course.sections.first.lessons;
      expect(lessons[0].isLocked, isFalse);
      expect(lessons[1].isLocked, isTrue);
      expect(lessons[0].lastPositionSec, equals(10));
      verify(() => mockCoursesRepository.getCourseById('c1')).called(1);
    },
  );

  test('should propagate Failure when course retrieval fails', () async {
    // Arrange
    when(() => mockCoursesRepository.getCourseById('non-existent'))
        .thenAnswer((_) async => const Failure('coursesLoadError'));

    // Act
    final result = await useCase('non-existent');

    // Assert
    expect(result, isA<Failure<Course>>());
    expect((result as Failure<Course>).message, equals('coursesLoadError'));
    verify(() => mockCoursesRepository.getCourseById('non-existent')).called(1);
  });
}
