import '../../domain/entities/lesson.dart';

/// Data model representing a lesson, extending [Lesson] domain entity.
class LessonModel extends Lesson {
  const LessonModel({
    required super.id,
    required super.title,
    required super.durationSec,
    required super.video,
    super.isCompleted,
    super.isLocked,
    super.lastPositionSec,
  });

  factory LessonModel.fromJson(Map<String, Object?> json) {
    return LessonModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      durationSec: (json['durationSec'] as num?)?.toInt() ?? 0,
      video: json['video'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'durationSec': durationSec,
      'video': video,
    };
  }
}
