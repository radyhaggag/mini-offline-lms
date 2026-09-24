import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_offline_lms/features/player/domain/repositories/progress_repository.dart';
import 'package:mini_offline_lms/features/player/domain/use_cases/get_lesson_progress_use_case.dart';

class MockProgressRepository extends Mock implements ProgressRepository {}

void main() {
  late MockProgressRepository mockProgressRepository;
  late GetLessonProgressUseCase useCase;

  setUp(() {
    mockProgressRepository = MockProgressRepository();
    useCase = GetLessonProgressUseCase(mockProgressRepository);
  });

  test('should return LessonProgress entity with position and completion from repository', () {
    // Arrange
    const lessonId = 'lesson-1';
    when(() => mockProgressRepository.getPosition(lessonId)).thenReturn(42);
    when(() => mockProgressRepository.isCompleted(lessonId)).thenReturn(true);

    // Act
    final progress = useCase(lessonId);

    // Assert
    expect(progress.lessonId, equals(lessonId));
    expect(progress.positionSec, equals(42));
    expect(progress.isCompleted, isTrue);
    verify(() => mockProgressRepository.getPosition(lessonId)).called(1);
    verify(() => mockProgressRepository.isCompleted(lessonId)).called(1);
  });
}
