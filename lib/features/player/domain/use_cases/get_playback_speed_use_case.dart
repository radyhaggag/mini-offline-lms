import '../repositories/progress_repository.dart';

/// Use case that retrieves the saved playback speed preference.
class GetPlaybackSpeedUseCase {
  const GetPlaybackSpeedUseCase(this._progressRepository);

  final ProgressRepository _progressRepository;

  double call() => _progressRepository.getPlaybackSpeed();
}
