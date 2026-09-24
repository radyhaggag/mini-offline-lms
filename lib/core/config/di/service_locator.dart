import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../features/courses/data/data_sources/courses_data_source.dart';
import '../../../features/courses/data/repositories/courses_repository_impl.dart';
import '../../../features/courses/domain/repositories/courses_repository.dart';
import '../../../features/courses/domain/use_cases/get_course_details_use_case.dart';
import '../../../features/courses/domain/use_cases/get_courses_use_case.dart';
import '../../../features/courses/domain/use_cases/search_courses_use_case.dart';
import '../../../features/courses/presentation/cubit/course_details/course_details_cubit.dart';
import '../../../features/courses/presentation/cubit/courses_list/courses_list_cubit.dart';
import '../../../features/notes/data/data_sources/notes_data_source.dart';
import '../../../features/notes/data/repositories/notes_repository_impl.dart';
import '../../../features/notes/domain/repositories/notes_repository.dart';
import '../../../features/notes/domain/use_cases/add_lesson_note_use_case.dart';
import '../../../features/notes/domain/use_cases/delete_lesson_note_use_case.dart';
import '../../../features/notes/domain/use_cases/get_lesson_notes_use_case.dart';
import '../../../features/notes/domain/use_cases/update_lesson_note_use_case.dart';
import '../../../features/notes/presentation/cubit/lesson_notes_cubit.dart';
import '../../../features/player/data/data_sources/progress_data_source.dart';
import '../../../features/player/data/repositories/progress_repository_impl.dart';
import '../../../features/player/domain/repositories/progress_repository.dart';
import '../../../features/player/domain/use_cases/get_lesson_progress_use_case.dart';
import '../../../features/player/domain/use_cases/get_next_lesson_use_case.dart';
import '../../../features/player/domain/use_cases/get_playback_speed_use_case.dart';
import '../../../features/player/domain/use_cases/save_lesson_progress_use_case.dart';
import '../../../features/player/domain/use_cases/save_playback_speed_use_case.dart';
import '../../../features/player/presentation/cubit/player_cubit.dart';
import '../theme/theme_cubit.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Theme Management
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));

  // Data Sources
  sl.registerLazySingleton<CoursesDataSource>(
    () => const CoursesLocalDataSource(),
  );
  sl.registerLazySingleton<ProgressDataSource>(
    () => ProgressLocalDataSource(sl()),
  );
  sl.registerLazySingleton<NotesDataSource>(() => NotesLocalDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<CoursesRepository>(
    () => CoursesRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<ProgressRepository>(
    () => ProgressRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<NotesRepository>(() => NotesRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton<GetCoursesUseCase>(
    () => GetCoursesUseCase(coursesRepository: sl(), progressRepository: sl()),
  );
  sl.registerLazySingleton<SearchCoursesUseCase>(
    () =>
        SearchCoursesUseCase(coursesRepository: sl(), progressRepository: sl()),
  );
  sl.registerLazySingleton<GetCourseDetailsUseCase>(
    () => GetCourseDetailsUseCase(
      coursesRepository: sl(),
      progressRepository: sl(),
    ),
  );
  sl.registerLazySingleton<GetLessonProgressUseCase>(
    () => GetLessonProgressUseCase(sl()),
  );
  sl.registerLazySingleton<SaveLessonProgressUseCase>(
    () => SaveLessonProgressUseCase(sl()),
  );
  sl.registerLazySingleton<GetNextLessonUseCase>(
    () =>
        GetNextLessonUseCase(coursesRepository: sl(), progressRepository: sl()),
  );
  sl.registerLazySingleton<GetPlaybackSpeedUseCase>(
    () => GetPlaybackSpeedUseCase(sl()),
  );
  sl.registerLazySingleton<SavePlaybackSpeedUseCase>(
    () => SavePlaybackSpeedUseCase(sl()),
  );
  sl.registerLazySingleton<GetLessonNotesUseCase>(
    () => GetLessonNotesUseCase(sl()),
  );
  sl.registerLazySingleton<AddLessonNoteUseCase>(
    () => AddLessonNoteUseCase(sl()),
  );
  sl.registerLazySingleton<DeleteLessonNoteUseCase>(
    () => DeleteLessonNoteUseCase(sl()),
  );
  sl.registerLazySingleton<UpdateLessonNoteUseCase>(
    () => UpdateLessonNoteUseCase(sl()),
  );

  // Cubits
  sl.registerFactory(() => CoursesListCubit(sl(), sl()));
  sl.registerFactory(() => CourseDetailsCubit(sl()));
  sl.registerFactory(() => LessonNotesCubit(sl(), sl(), sl(), sl()));
  sl.registerFactory(
    () => PlayerCubit(
      getCourseDetailsUseCase: sl(),
      getLessonProgressUseCase: sl(),
      saveLessonProgressUseCase: sl(),
      getNextLessonUseCase: sl(),
      getPlaybackSpeedUseCase: sl(),
      savePlaybackSpeedUseCase: sl(),
    ),
  );
}
