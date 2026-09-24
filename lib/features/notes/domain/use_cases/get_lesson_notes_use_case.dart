import '../../../../core/error/result.dart';
import '../entities/lesson_note.dart';
import '../repositories/notes_repository.dart';

/// Use case that fetches all notes saved for a specific lesson.
class GetLessonNotesUseCase {
  const GetLessonNotesUseCase(this._notesRepository);

  final NotesRepository _notesRepository;

  Future<Result<List<LessonNote>>> call(String lessonId) =>
      _notesRepository.getNotes(lessonId);
}
