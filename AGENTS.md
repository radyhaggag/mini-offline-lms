# AGENTS.md

## Project
Thaheen Mini Offline LMS — a Flutter screening task for a health-sciences learning platform.
Stack: Flutter stable (3.47+), Dart 3.13+, Cubit, Clean Architecture (with Use Cases & Domain Policies), go_router, get_it, SharedPreferences, easy_localization.
Data: bundled JSON + local MP4 files. **No backend, no API calls.** Everything runs offline.
Language: Arabic (primary) + English via `easy_localization`. Target: Android, iOS.

---

### Dot shorthands (Dart 3.10+)
Omit the type name when the compiler can infer it. Use everywhere — enums, named constructors, static members.

```dart
// Do
Column(mainAxisAlignment: .start, crossAxisAlignment: .center)
Padding(padding: .all(16))
Container(alignment: .center)
case .loading: ...
Status current = .loading;

// Don't
Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center)
Padding(padding: EdgeInsets.all(16))
case ProductsStatus.loading: ...
```

### Row/Column spacing (Flutter 3.27+)
Use `spacing` instead of `SizedBox` between children.

```dart
// Do
Row(spacing: 12, children: [...])
Column(spacing: 8, children: [...])

// Don't
Row(children: [Widget1(), SizedBox(width: 12), Widget2()])
```

### Null-aware collection elements (Dart 3.8+)
Use `?element` to conditionally include nullable values in collections.

```dart
// Do
children: [
  HeaderWidget(),
  ?maybeWidget,       // skipped if null
  FooterWidget(),
]

// Don't
children: [
  HeaderWidget(),
  if (maybeWidget != null) maybeWidget!,
  FooterWidget(),
]
```

### Switch expressions (Dart 3.0+)
Prefer switch expressions over switch statements when producing a value.

```dart
// Do
Widget body = switch (state) {
  CoursesListLoading()                   => const AppLoader(),
  CoursesListError(:final message)       => AppErrorView(message: message),
  CoursesListLoaded(:final courses)      => CoursesList(courses: courses),
  _                                      => const SizedBox.shrink(),
};
```

### Wildcard variables (Dart 3.7+)
Use `_` for unused parameters without naming conflicts.

---

## Commands

```bash
# Format changed files before finishing
dart format lib/

# Analyze — must pass clean
flutter analyze

# Run app
flutter run

# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Test execution policy

- Do not create test files or run `flutter test` automatically during ordinary implementation or documentation work.
- After completing the requested work, ask the user whether they want tests created or run. Never create test files without the user's approval.
- If the user explicitly requests tests, run them even when no commit is requested.
- If the user explicitly requests a commit, run `dart format lib/ test/`, `flutter analyze`, and `flutter test` before committing.
- Report skipped tests clearly when the user declines them.

---

## Structure

```
lib/
  core/
    config/
      di/               ← service_locator.dart (get_it registration)
      router/            ← go_router setup (BlocProviders at route level), AppRoutes constants
      theme/             ← AppTheme, AppColors, ThemeCubit
    error/              ← Result<T> sealed class (Success / Failure)
    utils/
      extensions/        ← context extensions, duration formatting, etc.
    widgets/             ← App-prefixed shared widgets (AppErrorView, AppThemeToggle, AppLanguageToggle, etc.)
  features/
    courses/
      data/
        models/          ← CourseModel, SectionModel, LessonModel (extend entities, add fromJson)
        data_sources/    ← abstract CoursesDataSource + CoursesLocalDataSource
        repositories/    ← CoursesRepositoryImpl (pure catalog data retrieval)
      domain/
        entities/        ← Course, Section, Lesson, ContinueWatching
        policies/        ← CourseUnlockPolicy (pure 90% threshold & sequential unlock logic)
        repositories/    ← CoursesRepository (abstract interface)
        use_cases/       ← GetCoursesUseCase, GetCourseDetailsUseCase
      presentation/
        cubit/           ← courses_list/ (CoursesListCubit), course_details/ (CourseDetailsCubit)
        screens/         ← CoursesScreen, CourseDetailsScreen
        widgets/         ← ContinueWatchingCard, CourseCard, CourseThumbnail, SectionCard, LessonTile, LessonStatusBadge
    player/
      data/
        data_sources/    ← abstract ProgressDataSource + ProgressLocalDataSource (SharedPreferences)
        repositories/    ← ProgressRepositoryImpl
      domain/
        entities/        ← LessonProgress (position, completed, etc.)
        repositories/    ← ProgressRepository (abstract interface)
      presentation/
        cubit/           ← PlayerCubit, ProgressCubit, state
        screens/         ← LessonPlayerScreen
        widgets/         ← video player wrapper, PlaybackSpeedSelector, NextLessonButton, etc.
  l10n/                 ← en.json, ar.json (easy_localization translation files)
```

### Key decisions

- **Models extend Entities.** Entities are clean domain objects. Models extend entities and add JSON parsing (`fromJson`/`toJson`). No `toEntity()` mappers — a Model IS an Entity.
- **Use Cases & Single Responsibility Principle (SRP).** Each Use Case represents a single user intent (`GetCoursesUseCase`, `GetCourseDetailsUseCase`) coordinating between repositories and domain policies.
- **Domain Policies for Business Rules.** Rules such as 90% completion and sequential unlocking live in pure domain policies (`CourseUnlockPolicy`), keeping domain logic isolated from data sources, repositories, or UI widgets.
- **Repositories are data-only.** Repositories only fetch and persist data. They do not calculate business rules or cross-pollinate with unrelated data sources.
- **BlocProvider at Route level.** BlocProviders are injected inside `app_router.dart` route builders, keeping screen widgets clean and decoupling lifecycle management from the widget tree.
- **Abstract data sources.** Each data source has an abstract interface for testability and dependency inversion, even with a single implementation.
- **Result\<T\> for error handling.** Repositories catch exceptions and return `Failure(localizationKey)`. The key is a translation key — the **UI** localizes it via `context.tr(key)`. Cubits never catch — they pattern-match on Result.
- **SharedPreferences for progress.** Key-value is sufficient for lesson positions and completion flags.
- **Player feature is mostly UI.** The video player widget wraps `video_player`/`chewie`. The feature's domain concern is progress tracking and completion logic, not video playback itself.

---

## Error Handling — Result\<T\>

A single sealed class in `core/error/`:

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  const Success(this.data);
  final T data;
}

final class Failure<T> extends Result<T> {
  const Failure(this.message);
  final String message;
}
```

### Repository — catches exceptions, returns Result with localization keys

```dart
class CoursesRepositoryImpl implements CoursesRepository {
  const CoursesRepositoryImpl(this._dataSource);
  final CoursesDataSource _dataSource;

  @override
  Future<Result<List<Course>>> getCourses() async {
    try {
      final courses = await _dataSource.getCourses();
      return Success(courses);                        // Models ARE Entities
    } catch (_) {
      return const Failure('coursesLoadError');        // localization key
    }
  }
}
```

### Use Case — coordinates data access with domain policy

```dart
class GetCoursesUseCase {
  const GetCoursesUseCase({
    required this.coursesRepository,
    required this.progressRepository,
  });

  final CoursesRepository coursesRepository;
  final ProgressRepository progressRepository;

  Future<Result<List<Course>>> call() async {
    final result = await coursesRepository.getCourses();
    return switch (result) {
      Success(:final data) => Success(
          CourseUnlockPolicy.applyProgressToCourses(
            courses: data,
            isCompleted: progressRepository.isCompleted,
            getPosition: progressRepository.getPosition,
          ),
        ),
      Failure(:final message) => Failure(message),
    };
  }
}
```

### Cubit — calls Use Case, never catches, folds on Result

```dart
class CoursesListCubit extends Cubit<CoursesListState> {
  CoursesListCubit(this._getCoursesUseCase) : super(const CoursesListInitial());
  final GetCoursesUseCase _getCoursesUseCase;

  Future<void> loadCourses() async {
    emit(const CoursesListLoading());
    final result = await _getCoursesUseCase();
    switch (result) {
      case Success(:final data):
        emit(CoursesListLoaded(
          courses: data,
          continueWatching: ContinueWatching.fromCourses(data),
        ));
      case Failure(:final message):
        emit(CoursesListError(message));              // passes key as-is
    }
  }
}
```

### UI — localizes the error key

```dart
CoursesListError(:final message) => AppErrorView(
  message: context.tr(message),                   // localized here
  onRetry: () => context.read<CoursesListCubit>().loadCourses(),
),
```

---

## Business Rules (Progress & Unlock)

These rules live in the **Domain Layer** inside pure domain policies (`CourseUnlockPolicy`), not in repositories, cubits, or widgets:

- A lesson is **completed at 90% watched** — position $\ge$ 0.9 $\times$ duration.
- Lessons unlock **sequentially** — a lesson is playable only if the previous one in the section is completed. The first lesson in each section is always unlocked.
- **Course progress %** = completed lessons / total lessons $\times$ 100.
- **"Continue watching"** = the first lesson across all courses that is in-progress (has a saved position but is not completed).

---

## DI — Registration

All registration in `core/config/di/service_locator.dart`:

```dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Theme Management
  sl.registerLazySingleton<ThemeCubit>(() => ThemeCubit(sl()));

  // Data Sources
  sl.registerLazySingleton<CoursesDataSource>(() => const CoursesLocalDataSource());
  sl.registerLazySingleton<ProgressDataSource>(() => ProgressLocalDataSource(sl()));

  // Repositories
  sl.registerLazySingleton<CoursesRepository>(() => CoursesRepositoryImpl(sl()));
  sl.registerLazySingleton<ProgressRepository>(() => ProgressRepositoryImpl(sl()));

  // Use Cases
  sl.registerLazySingleton<GetCoursesUseCase>(() => GetCoursesUseCase(
    coursesRepository: sl(),
    progressRepository: sl(),
  ));
  sl.registerLazySingleton<GetCourseDetailsUseCase>(() => GetCourseDetailsUseCase(
    coursesRepository: sl(),
    progressRepository: sl(),
  ));

  // Cubits
  sl.registerFactory(() => CoursesListCubit(sl()));
  sl.registerFactory(() => CourseDetailsCubit(sl()));
}
```

---

## Localization — easy_localization

Translation files live in `lib/l10n/`:

```json
// ar.json
{
  "courses": "الدورات",
  "continueWatching": "متابعة المشاهدة",
  "lessonLocked": "أكمل الدرس السابق أولاً",
  "noLessons": "لا توجد دروس",
  "error": "حدث خطأ"
}
```

```dart
// Usage — always use localized strings
Text(context.tr('courses'))

// Never
Text('الدورات')
```

---

## Routing — go_router

```dart
abstract class AppRoutes {
  static const courses = '/';
  static const courseDetails = '/course/:courseId';
  static const lessonPlayer = '/course/:courseId/lesson/:lessonId';

  static String courseDetailsPath(String courseId) => '/course/$courseId';
  static String lessonPlayerPath(String courseId, String lessonId) =>
      '/course/$courseId/lesson/$lessonId';
}
```

- Declare `BlocProvider` at the route definition level in `app_router.dart`.
- Never inline path strings in widgets. Always use `AppRoutes` helpers.
- Parse path parameters in the screen or a typed route helper.

---

## Presentation & UI Rules

### File Size & Modularity
- No presentation source file (screens, widgets, part files) should exceed **200 lines**.
- Decompose bloated views into smaller widget components.
- Use Dart `part`/`part of` directives to split complex layouts:
  - Do NOT use explicit `library` declarations.
  - Always use string URIs for `part of` directives (e.g. `part of 'my_view.dart';`).

### Cubit — Grouping & Folder Structure

If a feature's `cubit/` folder contains more than one Cubit, group each into its own subfolder.

```
lib/features/<feature>/presentation/cubit/
  ├── courses_list/
  │   ├── courses_list_cubit.dart
  │   └── courses_list_state.dart
  └── course_details/
      ├── course_details_cubit.dart
      └── course_details_state.dart
```

### Design Tokens
- Use theme colors via `context.colorScheme` and text styles via `context.textTheme`.
- Never reference raw `Colors.*` (like `Colors.black`, `Colors.white`, or hex codes) directly except `Colors.transparent`.
- Use `spacing` properties on Row/Column instead of `SizedBox` spacers.

### RTL & Arabic
- App locale defaults to Arabic (`ar`).
- All directional widgets, paddings, and icons must respect RTL.
- Seek bar, progress indicators, and navigation must feel natural in RTL.
- Use `easy_localization` for all user-facing strings — never hardcode text.

### Shared Widgets
- Prefix reusable widgets with `App` (e.g. `AppErrorView`, `AppLoader`, `AppThemeToggle`, `AppLanguageToggle`).

---

## Testing

### Standards
- **Pattern**: AAA (Arrange–Act–Assert) for every test.
- **Mocking**: `mocktail` (no code generation). Never use `mockito`.
- **Cubit testing**: `bloc_test` package with `blocTest<C, S>()` helper.
- **Naming**: `'should <expected> when <condition>'`.

### Required tests (per task spec)
At minimum **3 unit tests** for progress logic:
1. **90% completion rule** — lesson marks as completed when position $\ge$ 90% of duration.
2. **Sequential unlock rule** — lesson is locked until previous lesson is completed; first lesson is always unlocked.
3. **Progress % calculation** — course progress = completed / total $\times$ 100.

### Layer Isolation

| Layer Under Test | What to Mock | What to Assert |
|---|---|---|
| Cubit | Use Case | State emission sequence |
| Use Case | Repository interfaces | Policy execution, data coordination, Result propagation |
| Domain Policy | Nothing (pure Dart) | Deterministic unlock and completion math |
| Repository Impl | Data Source interface | Model $\rightarrow$ Entity mapping, Result wrapping |
| Data Source | SharedPreferences / rootBundle | Correct keys, parsing |
| Model | Nothing (pure data) | `fromJson` / `toJson` round-trip |

### What NOT to Test
- Private methods (test through public API)
- Flutter framework internals
- Simple getters/setters with no logic

---

## Boundaries

**Always:**
- `dart format` + `flutter analyze` before finishing
- `context.colorScheme` / `context.textTheme` for colors and type
- `context.tr(...)` for all user-facing strings (easy_localization)
- Prefix shared widgets with `App`
- `dart:developer log()` instead of `print`

**Ask before:**
- Adding a new package dependency
- Introducing a new shared widget in `core/widgets`

**Never:**
- `dynamic` — use `Object?`, typed generics, or sealed classes
- `!` unless non-null is structurally guaranteed
- Packages: `freezed`, `injectable`, `auto_route`, `get`/GetX, `riverpod`, `provider`
- Direct `SharedPreferences` usage outside the progress data source
- Network calls of any kind (fully offline app)
- Hardcoded user-facing strings — use `context.tr(...)` always

---

## Git & Workflow

### Commit Convention
Follow Conventional Commits: `<type>(<scope>): <description>`
- Types: `feat`, `fix`, `refactor`, `test`, `chore`, `docs`, `style`, `perf`
- Scope: feature name or `core` (e.g. `feat(player): add playback speed selector`)
- Subject: max 72 chars, imperative mood, no period

### Branch Naming
```
<type>/<short-kebab-description>
```
Types: `feature/`, `fix/`, `refactor/`, `test/`, `chore/`, `docs/`

### AI Agent Git Rules (ABSOLUTE — NO EXCEPTIONS)

**Never auto-commit:**
- Never run `git commit` without explicit user approval
- After completing work, show a summary of changed files
- Suggest a commit message following the convention
- Ask: "Would you like me to commit these changes?"
- Wait for explicit approval before committing

**Never auto-push:**
- Never run `git push` without explicit user approval
- After committing, ask: "Would you like me to push to remote?"
- Wait for explicit approval before pushing

**Never force-push:**
- Never run `git push --force` under any circumstances

**Branch awareness:**
- Check current branch with `git branch --show-current` before making changes
- If on `main` or `develop`: warn and ask to create a feature branch first
- Never create branches without user approval
- Suggest branch names following the convention

**Pre-work checks:**
- Run `git status` before starting work
- Warn about uncommitted changes
- Warn about untracked files in `lib/` or `test/`

### Pre-Push Checklist (mandatory before any push)
```bash
dart format lib/ test/
flutter analyze
flutter test
```