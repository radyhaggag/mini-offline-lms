import '../../domain/repositories/progress_repository.dart';
import '../data_sources/progress_data_source.dart';

/// Implementation of [ProgressRepository] delegating to [ProgressDataSource].
class ProgressRepositoryImpl implements ProgressRepository {
  const ProgressRepositoryImpl(this._dataSource);

  final ProgressDataSource _dataSource;

  @override
  Future<void> savePosition(String lessonId, int positionSeconds) =>
      _dataSource.savePosition(lessonId, positionSeconds);

  @override
  int getPosition(String lessonId) => _dataSource.getPosition(lessonId);

  @override
  Future<void> markCompleted(String lessonId) =>
      _dataSource.markCompleted(lessonId);

  @override
  bool isCompleted(String lessonId) => _dataSource.isCompleted(lessonId);

  @override
  Future<void> savePlaybackSpeed(double speed) =>
      _dataSource.savePlaybackSpeed(speed);

  @override
  double getPlaybackSpeed() => _dataSource.getPlaybackSpeed();
}
