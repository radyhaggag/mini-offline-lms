import '../repositories/progress_repository.dart';

/// Use case that persists the preferred playback speed.
class SavePlaybackSpeedUseCase {
  const SavePlaybackSpeedUseCase(this._progressRepository);

  final ProgressRepository _progressRepository;

  Future<void> call(double speed) =>
      _progressRepository.savePlaybackSpeed(speed);
}
