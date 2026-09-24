import 'package:flutter/foundation.dart';

import '../../domain/entities/lesson_note.dart';

/// States for the lesson notes list feature.
sealed class LessonNotesState {
  const LessonNotesState();
}

final class LessonNotesInitial extends LessonNotesState {
  const LessonNotesInitial();
}

final class LessonNotesLoading extends LessonNotesState {
  const LessonNotesLoading();
}

final class LessonNotesLoaded extends LessonNotesState {
  const LessonNotesLoaded({
    required this.lessonId,
    required this.notes,
    this.isAdding = false,
  });

  final String lessonId;
  final List<LessonNote> notes;
  final bool isAdding;

  LessonNotesLoaded copyWith({
    String? lessonId,
    List<LessonNote>? notes,
    bool? isAdding,
  }) {
    return LessonNotesLoaded(
      lessonId: lessonId ?? this.lessonId,
      notes: notes ?? this.notes,
      isAdding: isAdding ?? this.isAdding,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonNotesLoaded &&
          runtimeType == other.runtimeType &&
          lessonId == other.lessonId &&
          listEquals(notes, other.notes) &&
          isAdding == other.isAdding;

  @override
  int get hashCode => Object.hash(lessonId, Object.hashAll(notes), isAdding);
}

final class LessonNotesError extends LessonNotesState {
  const LessonNotesError(this.message);

  final String message;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LessonNotesError &&
          runtimeType == other.runtimeType &&
          message == other.message;

  @override
  int get hashCode => message.hashCode;
}
