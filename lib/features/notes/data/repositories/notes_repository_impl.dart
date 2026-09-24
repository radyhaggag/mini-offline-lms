import '../../../../core/error/result.dart';
import '../../domain/entities/lesson_note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../data_sources/notes_data_source.dart';
import '../models/lesson_note_model.dart';

/// Concrete implementation of [NotesRepository] delegating to [NotesDataSource].
class NotesRepositoryImpl implements NotesRepository {
  const NotesRepositoryImpl(this._dataSource);

  final NotesDataSource _dataSource;

  @override
  Future<Result<List<LessonNote>>> getNotes(String lessonId) async {
    try {
      final notes = await _dataSource.getNotes(lessonId);
      return Success(notes);
    } catch (_) {
      return const Failure('noteLoadError');
    }
  }

  @override
  Future<Result<LessonNote>> addNote({
    required String lessonId,
    required String content,
  }) async {
    try {
      final existing = await _dataSource.getNotes(lessonId);
      final newNote = LessonNoteModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        lessonId: lessonId,
        content: content.trim(),
        createdAt: DateTime.now(),
      );

      final updated = [newNote, ...existing];
      await _dataSource.saveNotes(lessonId: lessonId, notes: updated);
      return Success(newNote);
    } catch (_) {
      return const Failure('noteSaveError');
    }
  }

  @override
  Future<Result<void>> deleteNote({
    required String lessonId,
    required String noteId,
  }) async {
    try {
      final existing = await _dataSource.getNotes(lessonId);
      final updated = existing.where((note) => note.id != noteId).toList();
      await _dataSource.saveNotes(lessonId: lessonId, notes: updated);
      return const Success(null);
    } catch (_) {
      return const Failure('noteSaveError');
    }
  }

  @override
  Future<Result<LessonNote>> updateNote({
    required String lessonId,
    required String noteId,
    required String newContent,
  }) async {
    try {
      final existing = await _dataSource.getNotes(lessonId);
      LessonNoteModel? updatedNote;

      final updated = existing.map((note) {
        if (note.id == noteId) {
          updatedNote = LessonNoteModel(
            id: note.id,
            lessonId: note.lessonId,
            content: newContent.trim(),
            createdAt: note.createdAt,
            updatedAt: DateTime.now(),
          );
          return updatedNote!;
        }
        return note;
      }).toList();

      if (updatedNote == null) {
        return const Failure('noteSaveError');
      }

      await _dataSource.saveNotes(lessonId: lessonId, notes: updated);
      return Success(updatedNote!);
    } catch (_) {
      return const Failure('noteSaveError');
    }
  }
}
