import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/config/router/app_routes.dart';
import '../../../../core/utils/extensions/context_extensions.dart';
import '../../../../core/widgets/app_empty_view.dart';
import '../../../../core/widgets/app_error_view.dart';
import '../../../../core/widgets/app_language_toggle.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../../core/widgets/app_theme_toggle.dart';
import '../../domain/entities/continue_watching.dart';
import '../../domain/entities/course.dart';
import '../cubit/courses_list/courses_list_cubit.dart';
import '../cubit/courses_list/courses_list_state.dart';
import '../widgets/continue_watching_card.dart';
import '../widgets/course_card.dart';

/// Screen displaying all available courses and an active "Continue Watching" card.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  Future<void> _navigateToCourse(BuildContext context, Course course) async {
    await context.push(AppRoutes.courseDetailsPath(course.id));
    if (context.mounted) {
      context.read<CoursesListCubit>().loadCourses();
    }
  }

  Future<void> _resumeLesson(
    BuildContext context,
    ContinueWatching item,
  ) async {
    await context.push(
      AppRoutes.lessonPlayerPath(item.course.id, item.lesson.id),
    );
    if (context.mounted) {
      context.read<CoursesListCubit>().loadCourses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('appTitle'),
          style: texts.titleLarge?.copyWith(
            fontWeight: .bold,
            color: colors.primary,
          ),
        ),
        actions: const [AppThemeToggle(), AppLanguageToggle()],
      ),
      body: BlocBuilder<CoursesListCubit, CoursesListState>(
        builder: (context, state) => switch (state) {
          CoursesListInitial() || CoursesListLoading() => const AppLoader(),
          CoursesListError(:final message) => AppErrorView(
            message: context.tr(message),
            onRetry: () => context.read<CoursesListCubit>().loadCourses(),
          ),
          CoursesListLoaded(:final courses, :final continueWatching) =>
            courses.isEmpty
                ? AppEmptyView(message: context.tr('noCourses'))
                : RefreshIndicator(
                    onRefresh: () =>
                        context.read<CoursesListCubit>().loadCourses(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const .all(16),
                      child: Column(
                        crossAxisAlignment: .stretch,
                        spacing: 20,
                        children: [
                          Column(
                            crossAxisAlignment: .start,
                            spacing: 4,
                            children: [
                              Text(
                                context.tr('welcome'),
                                style: texts.headlineSmall?.copyWith(
                                  fontWeight: .bold,
                                ),
                              ),
                              Text(
                                context.tr('welcomeSubtitle'),
                                style: texts.bodyMedium?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                          ?continueWatching != null
                              ? ContinueWatchingCard(
                                  item: continueWatching,
                                  onResume: (item) =>
                                      _resumeLesson(context, item),
                                )
                              : null,
                          Text(
                            context.tr('courses'),
                            style: texts.titleMedium?.copyWith(
                              fontWeight: .bold,
                            ),
                          ),
                          for (final course in courses)
                            CourseCard(
                              course: course,
                              onTap: (course) =>
                                  _navigateToCourse(context, course),
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
