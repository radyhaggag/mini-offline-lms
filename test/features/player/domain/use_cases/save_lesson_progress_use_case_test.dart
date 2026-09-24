import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_offline_lms/features/player/domain/repositories/progress_repository.dart';
import 'package:mini_offline_lms/features/player/domain/use_cases/save_lesson_progress_use_case.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockProgressRepository;
  late SaveLessonProgressUseCase useCase;

  setUp(() {
    mockProgressRepository = MockProgressRepository();
    useCase = SaveLessonProgressUseCase(mockProgressRepository);
  });

  test('should persist position and mark completed when watched position reaches 90%', () async {
    // Arrange
    const lessonId = 'lesson-1';
    const positionSeconds = 90;
    const totalDurationSeconds = 100;

    when(() => mockProgressRepository.savePosition(lessonId, positionSeconds))
        .thenAnswer((_) async {});
    when(() => mockProgressRepository.isCompleted(lessonId)).thenReturn(false);
    when(() => mockProgressRepository.markCompleted(lessonId))
        .thenAnswer((_) async {});

    // Act
    final result = await useCase(
      lessonId: lessonId,
      positionSeconds: positionSeconds,
      totalDurationSeconds: totalDurationSeconds,
    );

    // Assert
    expect(result.lessonId, equals(lessonId));
    expect(result.positionSec, equals(positionSeconds));
    expect(result.isCompleted, isTrue);
    verify(() => mockProgressRepository.savePosition(lessonId, positionSeconds))
        .called(1);
    verify(() => mockProgressRepository.markCompleted(lessonId)).called(1);
  });

  test('should persist position without marking completed when watched position is under 90%', () async {
    // Arrange
    const lessonId = 'lesson-1';
    const positionSeconds = 50;
    const totalDurationSeconds = 100;

    when(() => mockProgressRepository.savePosition(lessonId, positionSeconds))
        .thenAnswer((_) async {});
    when(() => mockProgressRepository.isCompleted(lessonId)).thenReturn(false);

    // Act
    final result = await useCase(
      lessonId: lessonId,
      positionSeconds: positionSeconds,
      totalDurationSeconds: totalDurationSeconds,
    );

    // Assert
    expect(result.lessonId, equals(lessonId));
    expect(result.positionSec, equals(positionSeconds));
    expect(result.isCompleted, isFalse);
    verify(() => mockProgressRepository.savePosition(lessonId, positionSeconds))
        .called(1);
    verifyNever(() => mockProgressRepository.markCompleted(any()));
  });

  test(
    'should not re-mark as completed when lesson was already marked completed',
    () async {
      // Arrange
      const lessonId = 'lesson-1';
      const positionSeconds = 10;
      const totalDurationSeconds = 100;

      when(() => mockProgressRepository.savePosition(lessonId, positionSeconds))
          .thenAnswer((_) async {});
      when(() => mockProgressRepository.isCompleted(lessonId)).thenReturn(true);

      // Act
      final result = await useCase(
        lessonId: lessonId,
        positionSeconds: positionSeconds,
        totalDurationSeconds: totalDurationSeconds,
      );

      // Assert
      expect(result.isCompleted, isTrue);
      verify(
        () => mockProgressRepository.savePosition(lessonId, positionSeconds),
      ).called(1);
      verifyNever(() => mockProgressRepository.markCompleted(any()));
    },
  );
}
