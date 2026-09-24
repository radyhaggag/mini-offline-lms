import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/lesson_note_model.dart';

/// Contract for lesson notes local storage.
abstract class NotesDataSource {
  /// Fetches all saved notes for [lessonId].
  Future<List<LessonNoteModel>> getNotes(String lessonId);

  /// Persists the list of [notes] for [lessonId].
  Future<void> saveNotes({
    required String lessonId,
    required List<LessonNoteModel> notes,
  });
}

/// Local implementation of [NotesDataSource] using [SharedPreferences].
class NotesLocalDataSource implements NotesDataSource {
  const NotesLocalDataSource(this._prefs);

  final SharedPreferences _prefs;
  static const _keyPrefix = 'lesson_notes_list_';

  String _buildKey(String lessonId) => '$_keyPrefix$lessonId';

  @override
  Future<List<LessonNoteModel>> getNotes(String lessonId) async {
    final rawJson = _prefs.getString(_buildKey(lessonId));
    if (rawJson == null || rawJson.isEmpty) return const [];

    try {
      final decoded = jsonDecode(rawJson) as List<Object?>? ?? const [];
      return decoded
          .whereType<Map<String, Object?>>()
          .map(LessonNoteModel.fromJson)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  @override
  Future<void> saveNotes({
    required String lessonId,
    required List<LessonNoteModel> notes,
  }) async {
    final encoded = jsonEncode(notes.map((note) => note.toJson()).toList());
    await _prefs.setString(_buildKey(lessonId), encoded);
  }
}
