import '../../domain/entities/lesson_note.dart';

/// Data model extending [LessonNote] domain entity with JSON serialization.
class LessonNoteModel extends LessonNote {
  const LessonNoteModel({
    required super.id,
    required super.lessonId,
    required super.content,
    required super.createdAt,
    super.updatedAt,
  });

  factory LessonNoteModel.fromJson(Map<String, Object?> json) {
    final updatedAtRaw = json['updatedAt'] as String?;
    return LessonNoteModel(
      id: json['id'] as String? ?? '',
      lessonId: json['lessonId'] as String? ?? '',
      content: json['content'] as String? ?? '',
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(),
      updatedAt: updatedAtRaw != null ? DateTime.tryParse(updatedAtRaw) : null,
    );
  }

  factory LessonNoteModel.fromEntity(LessonNote entity) {
    return LessonNoteModel(
      id: entity.id,
      lessonId: entity.lessonId,
      content: entity.content,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'lessonId': lessonId,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}
