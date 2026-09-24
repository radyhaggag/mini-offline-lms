import '../../../../core/error/result.dart';
import '../repositories/notes_repository.dart';

/// Use case that deletes a specific note from a lesson.
class DeleteLessonNoteUseCase {
  const DeleteLessonNoteUseCase(this._notesRepository);

  final NotesRepository _notesRepository;

  Future<Result<void>> call({
    required String lessonId,
    required String noteId,
  }) => _notesRepository.deleteNote(lessonId: lessonId, noteId: noteId);
}
