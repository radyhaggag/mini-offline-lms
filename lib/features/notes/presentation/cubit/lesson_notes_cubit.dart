import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/result.dart';
import '../../domain/use_cases/add_lesson_note_use_case.dart';
import '../../domain/use_cases/delete_lesson_note_use_case.dart';
import '../../domain/use_cases/get_lesson_notes_use_case.dart';
import '../../domain/use_cases/update_lesson_note_use_case.dart';
import 'lesson_notes_state.dart';

/// Cubit managing a list of notes for a lesson with add, edit, and delete actions.
class LessonNotesCubit extends Cubit<LessonNotesState> {
  LessonNotesCubit(
    this._getLessonNotesUseCase,
    this._addLessonNoteUseCase,
    this._deleteLessonNoteUseCase,
    this._updateLessonNoteUseCase,
  ) : super(const LessonNotesInitial());

  final GetLessonNotesUseCase _getLessonNotesUseCase;
  final AddLessonNoteUseCase _addLessonNoteUseCase;
  final DeleteLessonNoteUseCase _deleteLessonNoteUseCase;
  final UpdateLessonNoteUseCase _updateLessonNoteUseCase;

  /// Loads all notes saved for [lessonId].
  Future<void> loadNotes(String lessonId) async {
    emit(const LessonNotesLoading());
    final result = await _getLessonNotesUseCase(lessonId);
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        emit(LessonNotesLoaded(lessonId: lessonId, notes: data));
      case Failure(:final message):
        emit(LessonNotesError(message));
    }
  }

  /// Adds a new note with [content] to [lessonId].
  Future<void> addNote({
    required String lessonId,
    required String content,
  }) async {
    final current = state;
    if (current is LessonNotesLoaded) {
      emit(current.copyWith(isAdding: true));
    }

    final result = await _addLessonNoteUseCase(
      lessonId: lessonId,
      content: content,
    );
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        if (state is LessonNotesLoaded) {
          final loaded = state as LessonNotesLoaded;
          emit(
            loaded.copyWith(notes: [data, ...loaded.notes], isAdding: false),
          );
        }
      case Failure(:final message):
        emit(LessonNotesError(message));
    }
  }

  /// Updates content of an existing note with [noteId].
  Future<void> updateNote({
    required String lessonId,
    required String noteId,
    required String newContent,
  }) async {
    final current = state;
    if (current is! LessonNotesLoaded) return;

    final result = await _updateLessonNoteUseCase(
      lessonId: lessonId,
      noteId: noteId,
      newContent: newContent,
    );
    if (isClosed) return;

    switch (result) {
      case Success(:final data):
        final updated = current.notes.map((note) {
          return note.id == noteId ? data : note;
        }).toList();
        emit(current.copyWith(notes: updated));
      case Failure(:final message):
        emit(LessonNotesError(message));
    }
  }

  /// Deletes note with [noteId] from [lessonId].
  Future<void> deleteNote({
    required String lessonId,
    required String noteId,
  }) async {
    final current = state;
    if (current is! LessonNotesLoaded) return;

    final updated = current.notes.where((note) => note.id != noteId).toList();
    emit(current.copyWith(notes: updated));

    final result = await _deleteLessonNoteUseCase(
      lessonId: lessonId,
      noteId: noteId,
    );
    if (isClosed) return;

    if (result is Failure) {
      emit(LessonNotesError(result.message));
    }
  }
}
