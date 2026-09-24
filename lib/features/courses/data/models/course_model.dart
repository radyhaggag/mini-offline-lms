import '../../domain/entities/course.dart';
import 'section_model.dart';

/// Data model representing a course, extending [Course] domain entity.
class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.title,
    required super.instructor,
    required super.thumbnail,
    required super.sections,
  });

  factory CourseModel.fromJson(Map<String, Object?> json) {
    final rawSections = json['sections'] as List<Object?>? ?? const [];
    return CourseModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      instructor: json['instructor'] as String? ?? '',
      thumbnail: json['thumbnail'] as String? ?? '',
      sections: rawSections
          .whereType<Map<String, Object?>>()
          .map(SectionModel.fromJson)
          .toList(),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'title': title,
      'instructor': instructor,
      'thumbnail': thumbnail,
      'sections': [
        for (final section in sections)
          if (section is SectionModel)
            section.toJson()
          else
            SectionModel(
              id: section.id,
              title: section.title,
              lessons: section.lessons,
            ).toJson(),
      ],
    };
  }
}
