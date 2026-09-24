import 'dart:async';

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
import '../widgets/courses_search_bar.dart';

/// Screen displaying all available courses and an active "Continue Watching" card.
class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

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
          CoursesListLoaded(
            :final courses,
            :final continueWatching,
            :final searchQuery,
          ) =>
            courses.isEmpty && searchQuery.isEmpty
                ? AppEmptyView(message: context.tr('noCourses'))
                : _CoursesLoadedView(
                    courses: courses,
                    continueWatching: continueWatching,
                    searchQuery: searchQuery,
                  ),
        },
      ),
    );
  }
}

class _CoursesLoadedView extends StatefulWidget {
  const _CoursesLoadedView({
    required this.courses,
    required this.continueWatching,
    required this.searchQuery,
  });

  final List<Course> courses;
  final ContinueWatching? continueWatching;
  final String searchQuery;

  @override
  State<_CoursesLoadedView> createState() => _CoursesLoadedViewState();
}

class _CoursesLoadedViewState extends State<_CoursesLoadedView> {
  late final TextEditingController _searchController;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(text: widget.searchQuery);
  }

  @override
  void didUpdateWidget(covariant _CoursesLoadedView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.searchQuery != oldWidget.searchQuery &&
        widget.searchQuery != _searchController.text) {
      _searchController.text = widget.searchQuery;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 250), () {
      if (mounted) {
        context.read<CoursesListCubit>().searchCourses(query);
      }
    });
  }

  void _onClearSearch() {
    _debounceTimer?.cancel();
    _searchController.clear();
    context.read<CoursesListCubit>().searchCourses('');
  }

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

    return RefreshIndicator(
      onRefresh: () => context.read<CoursesListCubit>().loadCourses(),
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
                  style: texts.headlineSmall?.copyWith(fontWeight: .bold),
                ),
                Text(
                  context.tr('welcomeSubtitle'),
                  style: texts.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            ?widget.continueWatching != null
                ? ContinueWatchingCard(
                    item: widget.continueWatching!,
                    onResume: (item) => _resumeLesson(context, item),
                  )
                : null,
            CoursesSearchBar(
              controller: _searchController,
              onChanged: _onSearchChanged,
              onClear: _onClearSearch,
            ),
            Text(
              context.tr('courses'),
              style: texts.titleMedium?.copyWith(fontWeight: .bold),
            ),
            if (widget.courses.isEmpty)
              Padding(
                padding: const .symmetric(vertical: 24),
                child: AppEmptyView(
                  message: context.tr('noSearchResults'),
                  icon: Icons.search_off_rounded,
                ),
              )
            else
              for (final course in widget.courses)
                CourseCard(
                  course: course,
                  onTap: (course) => _navigateToCourse(context, course),
                ),
          ],
        ),
      ),
    );
  }
}
