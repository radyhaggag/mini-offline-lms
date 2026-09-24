import 'package:flutter/foundation.dart';

import 'lesson.dart';

/// Pure domain entity representing a section of lessons within a course.
class Section {
  const Section({required this.id, required this.title, required this.lessons});

  final String id;
  final String title;
  final List<Lesson> lessons;

  int get totalLessonsCount => lessons.length;

  int get completedLessonsCount =>
      lessons.where((lesson) => lesson.isCompleted).length;

  /// Returns the first in-progress lesson in this section, if any.
  Lesson? get inProgressLesson =>
      lessons.where((lesson) => lesson.status == .inProgress).firstOrNull;

  Section copyWith({String? id, String? title, List<Lesson>? lessons}) {
    return Section(
      id: id ?? this.id,
      title: title ?? this.title,
      lessons: lessons ?? this.lessons,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Section &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          listEquals(lessons, other.lessons);

  @override
  int get hashCode => Object.hash(id, title, Object.hashAll(lessons));
}
