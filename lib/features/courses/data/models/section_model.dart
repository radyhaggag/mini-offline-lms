import '../../domain/entities/section.dart';
import 'lesson_model.dart';

/// Data model representing a section, extending [Section] domain entity.
class SectionModel extends Section {
  const SectionModel({
    required super.id,
    required super.title,
    required super.lessons,
  });

  factory SectionModel.fromJson(Map<String, Object?> json) {
    final rawLessons = json['lessons'] as List<Object?>? ?? const [];
    return SectionModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      lessons: rawLessons
          .whereType<Map<String, Object?>>()
          .map(LessonModel.fromJson)
          .toList(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'lessons': [
        for (final lesson in lessons)
          if (lesson is LessonModel)
            lesson.toJson()
          else
            LessonModel(
              id: lesson.id,
              title: lesson.title,
              durationSec: lesson.durationSec,
              video: lesson.video,
            ).toJson(),
      ],
    };
  }
}
