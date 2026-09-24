import '../../../../core/error/result.dart';
import '../entities/lesson_note.dart';
import '../repositories/notes_repository.dart';

/// Use case that creates and persists a new note for a specific lesson.
class AddLessonNoteUseCase {
  const AddLessonNoteUseCase(this._notesRepository);

  final NotesRepository _notesRepository;

  Future<Result<LessonNote>> call({
    required String lessonId,
    required String content,
  }) => _notesRepository.addNote(lessonId: lessonId, content: content);
}
