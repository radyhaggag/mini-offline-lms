import '../../../../core/error/result.dart';
import '../entities/lesson_note.dart';
import '../repositories/notes_repository.dart';

/// Use case that updates an existing note for a lesson.
class UpdateLessonNoteUseCase {
  const UpdateLessonNoteUseCase(this._notesRepository);

  final NotesRepository _notesRepository;

  Future<Result<LessonNote>> call({
    required String lessonId,
    required String noteId,
    required String newContent,
  }) => _notesRepository.updateNote(
    lessonId: lessonId,
    noteId: noteId,
    newContent: newContent,
  );
}
