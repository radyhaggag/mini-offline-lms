import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../di/service_locator.dart';
import '../../../features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import '../../../features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import '../../../features/courses/presentation/screens/course_details_screen.dart';
import '../../../features/courses/presentation/screens/courses_screen.dart';
import '../../../features/player/presentation/screens/lesson_player_screen.dart';
import 'app_routes.dart';

abstract class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.courses,
    routes: [
      GoRoute(
        path: AppRoutes.courses,
        builder: (context, state) => BlocProvider(
          create: (_) => sl<CoursesListCubit>()..loadCourses(),
          child: const CoursesScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.courseDetails,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          return BlocProvider(
            create: (_) => sl<CourseDetailsCubit>()..loadCourse(courseId),
            child: CourseDetailsScreen(courseId: courseId),
          );
        },
      ),
      GoRoute(
        path: AppRoutes.lessonPlayer,
        builder: (context, state) {
          final courseId = state.pathParameters['courseId'] ?? '';
          final lessonId = state.pathParameters['lessonId'] ?? '';
          return LessonPlayerScreen(courseId: courseId, lessonId: lessonId);
        },
      ),
    ],
  );
}
