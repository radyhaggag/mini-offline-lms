import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_offline_lms/core/error/result.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/course.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/lesson.dart';
import 'package:mini_offline_lms/features/courses/domain/entities/section.dart';
import 'package:mini_offline_lms/features/courses/domain/repositories/courses_repository.dart';
import 'package:mini_offline_lms/features/player/domain/repositories/progress_repository.dart';
import 'package:mini_offline_lms/features/player/domain/use_cases/get_next_lesson_use_case.dart';

class MockCoursesRepository extends Mock implements CoursesRepository {}

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockCoursesRepository mockCoursesRepository;
  late MockProgressRepository mockProgressRepository;
  late GetNextLessonUseCase useCase;

  setUp(() {
    mockCoursesRepository = MockCoursesRepository();
    mockProgressRepository = MockProgressRepository();
    useCase = GetNextLessonUseCase(
      coursesRepository: mockCoursesRepository,
      progressRepository: mockProgressRepository,
    );
  });

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

  const testCourse = Course(
    id: 'c1',
    title: 'Course 1',
    instructor: 'Dr. Test',
    thumbnail: 'thumb.png',
    sections: [
      Section(id: 's1', title: 'Section 1', lessons: [lesson1, lesson2]),
      Section(id: 's2', title: 'Section 2', lessons: [lesson3]),
    ],
  );

  test(
    'should return next sequential lesson within the same section',
    () async {
      // Arrange
      when(() => mockCoursesRepository.getCourseById('c1'))
          .thenAnswer((_) async => const Success(testCourse));
      when(() => mockProgressRepository.isCompleted(any())).thenReturn(false);
      when(() => mockProgressRepository.getPosition(any())).thenReturn(0);

      // Act
      final result = await useCase(courseId: 'c1', currentLessonId: 'l1');

      // Assert
      expect(result, isA<Success<Lesson?>>());
      final nextLesson = (result as Success<Lesson?>).data;
      expect(nextLesson, isNotNull);
      expect(nextLesson!.id, equals('l2'));
    },
  );

  test('should return next lesson across section boundaries when current is last in section', () async {
    // Arrange
    when(() => mockCoursesRepository.getCourseById('c1'))
        .thenAnswer((_) async => const Success(testCourse));
    when(() => mockProgressRepository.isCompleted(any())).thenReturn(false);
    when(() => mockProgressRepository.getPosition(any())).thenReturn(0);

    // Act
    final result = await useCase(courseId: 'c1', currentLessonId: 'l2');

    // Assert
    expect(result, isA<Success<Lesson?>>());
    final nextLesson = (result as Success<Lesson?>).data;
    expect(nextLesson, isNotNull);
    expect(nextLesson!.id, equals('l3'));
  });

  test(
    'should return null when current lesson is the last in the course',
    () async {
      // Arrange
      when(() => mockCoursesRepository.getCourseById('c1'))
          .thenAnswer((_) async => const Success(testCourse));
      when(() => mockProgressRepository.isCompleted(any())).thenReturn(false);
      when(() => mockProgressRepository.getPosition(any())).thenReturn(0);

      // Act
      final result = await useCase(courseId: 'c1', currentLessonId: 'l3');

      // Assert
      expect(result, isA<Success<Lesson?>>());
      final nextLesson = (result as Success<Lesson?>).data;
      expect(nextLesson, isNull);
    },
  );

  test('should propagate Failure when course retrieval fails', () async {
    // Arrange
    when(() => mockCoursesRepository.getCourseById('invalid'))
        .thenAnswer((_) async => const Failure('coursesLoadError'));

    // Act
    final result = await useCase(courseId: 'invalid', currentLessonId: 'l1');

    // Assert
    expect(result, isA<Failure<Lesson?>>());
    expect((result as Failure<Lesson?>).message, equals('coursesLoadError'));
  });
}
