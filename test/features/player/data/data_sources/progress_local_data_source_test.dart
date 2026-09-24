import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mini_offline_lms/features/player/data/data_sources/progress_data_source.dart';

void main() {
  late SharedPreferences prefs;
  late ProgressLocalDataSource dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'position_lesson-1': 45,
      'completed_lesson-1': true,
      'preferred_playback_speed': 1.5,
    });
    prefs = await SharedPreferences.getInstance();
    dataSource = ProgressLocalDataSource(prefs);
  });

  group('Position', () {
    test('should retrieve saved position when key exists', () {
      // Act
      final position = dataSource.getPosition('lesson-1');

      // Assert
      expect(position, equals(45));
    });

    test('should return 0 when position key does not exist', () {
      // Act
      final position = dataSource.getPosition('unknown-lesson');

      // Assert
      expect(position, equals(0));
    });

    test('should persist position accurately to storage', () async {
      // Act
      await dataSource.savePosition('lesson-2', 120);

      // Assert
      expect(prefs.getInt('position_lesson-2'), equals(120));
      expect(dataSource.getPosition('lesson-2'), equals(120));
    });
  });

  group('Completion', () {
    test('should return true when completed flag exists and is true', () {
      // Act
      final isCompleted = dataSource.isCompleted('lesson-1');

      // Assert
      expect(isCompleted, isTrue);
    });

    test('should return false when completed flag does not exist', () {
      // Act
      final isCompleted = dataSource.isCompleted('unknown-lesson');

      // Assert
      expect(isCompleted, isFalse);
    });

    test('should persist completed flag to storage', () async {
      // Act
      await dataSource.markCompleted('lesson-2');

      // Assert
      expect(prefs.getBool('completed_lesson-2'), isTrue);
      expect(dataSource.isCompleted('lesson-2'), isTrue);
    });
  });

  group('Playback Speed', () {
    test('should return saved playback speed when key exists', () {
      // Act
      final speed = dataSource.getPlaybackSpeed();

      // Assert
      expect(speed, equals(1.5));
    });

    test(
      'should return 1.0 default when playback speed is not saved',
      () async {
        // Arrange
        await prefs.remove('preferred_playback_speed');

        // Act
        final speed = dataSource.getPlaybackSpeed();

        // Assert
        expect(speed, equals(1.0));
      },
    );

    test('should persist preferred playback speed to storage', () async {
      // Act
      await dataSource.savePlaybackSpeed(2.0);

      // Assert
      expect(prefs.getDouble('preferred_playback_speed'), equals(2.0));
      expect(dataSource.getPlaybackSpeed(), equals(2.0));
    });
  });
}
