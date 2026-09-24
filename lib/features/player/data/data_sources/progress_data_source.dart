import 'package:shared_preferences/shared_preferences.dart';

/// Abstract contract for lesson progress persistence.
abstract class ProgressDataSource {
  Future<void> savePosition(String lessonId, int positionSeconds);
  int getPosition(String lessonId);
  Future<void> markCompleted(String lessonId);
  bool isCompleted(String lessonId);
  Future<void> savePlaybackSpeed(double speed);
  double getPlaybackSpeed();
}

/// SharedPreferences-backed implementation of [ProgressDataSource].
class ProgressLocalDataSource implements ProgressDataSource {
  const ProgressLocalDataSource(this._prefs);

  final SharedPreferences _prefs;

  static const _positionPrefix = 'position_';
  static const _completedPrefix = 'completed_';
  static const _speedKey = 'preferred_playback_speed';

  @override
  Future<void> savePosition(String lessonId, int positionSeconds) async {
    await _prefs.setInt('$_positionPrefix$lessonId', positionSeconds);
  }

  @override
  int getPosition(String lessonId) =>
      _prefs.getInt('$_positionPrefix$lessonId') ?? 0;

  @override
  Future<void> markCompleted(String lessonId) async {
    await _prefs.setBool('$_completedPrefix$lessonId', true);
  }

  @override
  bool isCompleted(String lessonId) =>
      _prefs.getBool('$_completedPrefix$lessonId') ?? false;

  @override
  Future<void> savePlaybackSpeed(double speed) async {
    await _prefs.setDouble(_speedKey, speed);
  }

  @override
  double getPlaybackSpeed() => _prefs.getDouble(_speedKey) ?? 1.0;
}
