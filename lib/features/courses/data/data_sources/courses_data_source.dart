import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/course_model.dart';

/// Abstract contract for courses data source.
abstract class CoursesDataSource {
  /// Loads all courses from local bundle or storage.
  Future<List<CourseModel>> getCourses();
}

/// Offline implementation of [CoursesDataSource] reading bundled JSON.
class CoursesLocalDataSource implements CoursesDataSource {
  const CoursesLocalDataSource({this.bundle});

  final AssetBundle? bundle;

  static const _coursesAssetPath = 'assets/data/courses.json';

  @override
  Future<List<CourseModel>> getCourses() async {
    final effectiveBundle = bundle ?? rootBundle;
    final jsonString = await effectiveBundle.loadString(_coursesAssetPath);
    final data = jsonDecode(jsonString) as Map<String, Object?>;
    final coursesList = data['courses'] as List<Object?>? ?? const [];
    return coursesList
        .whereType<Map<String, Object?>>()
        .map(CourseModel.fromJson)
        .toList();
  }
}
