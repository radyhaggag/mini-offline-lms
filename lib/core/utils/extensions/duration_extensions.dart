extension DurationFormatting on Duration {
  /// Formats duration as 'mm:ss' or 'h:mm:ss' depending on length.
  String toFormattedString() {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

extension IntToDuration on int {
  /// Converts seconds (int) to Duration.
  Duration get seconds => Duration(seconds: this);
}
