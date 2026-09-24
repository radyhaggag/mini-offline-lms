import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/app_routes.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../domain/entities/lesson.dart';
import '../cubit/course_details/course_details_cubit.dart';
import '../cubit/course_details/course_details_state.dart';
import '../widgets/course_header.dart';
import '../widgets/section_card.dart';

/// Screen displaying detailed sections and lessons of a specific course.
class CourseDetailsScreen extends StatelessWidget {
  const CourseDetailsScreen({super.key, required this.courseId});

  final String courseId;

  Future<void> _onLessonTap(BuildContext context, Lesson lesson) async {
    await context.push(AppRoutes.lessonPlayerPath(courseId, lesson.id));
    if (context.mounted) {
      context.read<CourseDetailsCubit>().loadCourse(courseId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(context.tr('courseDetails'))),
      body: BlocBuilder<CourseDetailsCubit, CourseDetailsState>(
        builder: (context, state) => switch (state) {
          CourseDetailsInitial() || CourseDetailsLoading() => const AppLoader(),
          CourseDetailsError(:final message) => AppErrorView(
            message: context.tr(message),
            onRetry: () =>
                context.read<CourseDetailsCubit>().loadCourse(courseId),
          ),
          CourseDetailsLoaded(:final course) => RefreshIndicator(
            onRefresh: () =>
                context.read<CourseDetailsCubit>().loadCourse(courseId),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const .only(bottom: 24),
              child: Column(
                crossAxisAlignment: .stretch,
                children: [
                  CourseHeader(course: course),
                  if (course.sections.isEmpty || course.totalLessonsCount == 0)
                    Padding(
                      padding: const .all(24),
                      child: AppEmptyView(
                        message: context.tr('noLessons'),
                        icon: Icons.video_library_outlined,
                      ),
                    )
                  else
                    for (final section in course.sections)
                      SectionCard(
                        section: section,
                        onLessonTap: (lesson) => _onLessonTap(context, lesson),
                      ),
                ],
              ),
            ),
          ),
        },
      ),
    );
  }
}
