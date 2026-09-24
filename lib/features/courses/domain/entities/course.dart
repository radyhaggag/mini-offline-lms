import 'package:flutter/foundation.dart';

import 'section.dart';

/// Pure domain entity representing a course.
class Course {
  const Course({
    required this.id,
    required this.title,
    required this.instructor,
    required this.thumbnail,
    required this.sections,
  });

  final String id;
  final String title;
  final String instructor;
  final String thumbnail;
  final List<Section> sections;

  int get totalLessonsCount =>
      sections.fold(0, (sum, section) => sum + section.totalLessonsCount);

  int get completedLessonsCount =>
      sections.fold(0, (sum, section) => sum + section.completedLessonsCount);

  /// Course progress percentage (0.0 to 100.0).
  double get progressPercentage {
    if (totalLessonsCount == 0) return 0.0;
    return (completedLessonsCount / totalLessonsCount) * 100;
  }

  Course copyWith({
    String? id,
    String? title,
    String? instructor,
    String? thumbnail,
    List<Section>? sections,
  }) {
    return Course(
      id: id ?? this.id,
      title: title ?? this.title,
      instructor: instructor ?? this.instructor,
      thumbnail: thumbnail ?? this.thumbnail,
      sections: sections ?? this.sections,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Course &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          title == other.title &&
          instructor == other.instructor &&
          thumbnail == other.thumbnail &&
          listEquals(sections, other.sections);

  @override
  int get hashCode =>
      Object.hash(id, title, instructor, thumbnail, Object.hashAll(sections));
}
