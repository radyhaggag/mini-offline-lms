import '../../../../core/error/result.dart';
import '../entities/lesson_note.dart';

/// Abstract contract for lesson notes data operations.
abstract class NotesRepository {
  /// Retrieves all notes saved for [lessonId].
  Future<Result<List<LessonNote>>> getNotes(String lessonId);

  /// Creates and persists a new note for [lessonId].
  Future<Result<LessonNote>> addNote({
    required String lessonId,
    required String content,
  });

  /// Deletes a specific note with [noteId] from [lessonId].
  Future<Result<void>> deleteNote({
    required String lessonId,
    required String noteId,
  });

  /// Updates content of an existing note with [noteId] for [lessonId].
  Future<Result<LessonNote>> updateNote({
    required String lessonId,
    required String noteId,
    required String newContent,
  });
}
