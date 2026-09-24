/// Pure domain entity representing a single study note on a lesson.
class LessonNote {
  const LessonNote({
    required this.id,
    required this.lessonId,
    required this.content,
    required this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String lessonId;
  final String content;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LessonNote copyWith({
    String? id,
    String? lessonId,
    String? content,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LessonNote(
      id: id ?? this.id,
      lessonId: lessonId ?? this.lessonId,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonNote &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          lessonId == other.lessonId &&
          content == other.content &&
          createdAt == other.createdAt &&
          updatedAt == other.updatedAt;

  @override
  int get hashCode => Object.hash(id, lessonId, content, createdAt, updatedAt);
}
