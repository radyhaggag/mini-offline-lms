import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mini_offline_lms/features/player/data/data_sources/progress_data_source.dart';
import 'package:mini_offline_lms/features/player/data/repositories/progress_repository_impl.dart';

class MockProgressDataSource extends Mock implements ProgressDataSource {}

void main() {
  late MockProgressDataSource mockDataSource;
  late ProgressRepositoryImpl repository;

  setUp(() {
    mockDataSource = MockProgressDataSource();
    repository = ProgressRepositoryImpl(mockDataSource);
  });

  test('should delegate savePosition to data source', () async {
    // Arrange
    when(() => mockDataSource.savePosition('l1', 50)).thenAnswer((_) async {});

    // Act
    await repository.savePosition('l1', 50);

    // Assert
    verify(() => mockDataSource.savePosition('l1', 50)).called(1);
  });

  test('should delegate getPosition to data source', () {
    // Arrange
    when(() => mockDataSource.getPosition('l1')).thenReturn(50);

    // Act
    final result = repository.getPosition('l1');

    // Assert
    expect(result, equals(50));
    verify(() => mockDataSource.getPosition('l1')).called(1);
  });

  test('should delegate markCompleted to data source', () async {
    // Arrange
    when(() => mockDataSource.markCompleted('l1')).thenAnswer((_) async {});

    // Act
    await repository.markCompleted('l1');

    // Assert
    verify(() => mockDataSource.markCompleted('l1')).called(1);
  });

  test('should delegate isCompleted to data source', () {
    // Arrange
    when(() => mockDataSource.isCompleted('l1')).thenReturn(true);

    // Act
    final result = repository.isCompleted('l1');

    // Assert
    expect(result, isTrue);
    verify(() => mockDataSource.isCompleted('l1')).called(1);
  });

  test('should delegate savePlaybackSpeed to data source', () async {
    // Arrange
    when(() => mockDataSource.savePlaybackSpeed(1.5)).thenAnswer((_) async {});

    // Act
    await repository.savePlaybackSpeed(1.5);

    // Assert
    verify(() => mockDataSource.savePlaybackSpeed(1.5)).called(1);
  });

  test('should delegate getPlaybackSpeed to data source', () {
    // Arrange
    when(() => mockDataSource.getPlaybackSpeed()).thenReturn(1.25);

    // Act
    final result = repository.getPlaybackSpeed();

    // Assert
    expect(result, equals(1.25));
    verify(() => mockDataSource.getPlaybackSpeed()).called(1);
  });
}
