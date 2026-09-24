/// Abstract domain repository interface for watch progress tracking.
abstract class ProgressRepository {
  Future<void> savePosition(String lessonId, int positionSeconds);
  int getPosition(String lessonId);
  Future<void> markCompleted(String lessonId);
  bool isCompleted(String lessonId);
  Future<void> savePlaybackSpeed(double speed);
  double getPlaybackSpeed();
}
