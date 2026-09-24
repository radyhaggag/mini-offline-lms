# AGENTS.md

## Project
Thaheen Mini Offline LMS — a Flutter screening task for a health-sciences learning platform.
Stack: Flutter stable (3.47+), Dart 3.13+, Cubit, Clean Architecture (no use cases), go_router, get_it, SharedPreferences, easy_localization.
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
  CoursesLoading()                   => const AppLoader(),
  CoursesError(:final message)       => AppErrorView(message: message),
  CoursesLoaded(:final courses)      => CoursesList(courses: courses),
  _                                  => const SizedBox.shrink(),
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
      router/            ← go_router setup, AppRoutes path constants
      theme/             ← AppTheme, colors, text styles
    error/              ← Result<T> sealed class (Success / Failure)
    utils/
      extensions/        ← context extensions, duration formatting, etc.
    widgets/             ← App-prefixed shared widgets (AppErrorView, AppLoader, etc.)
  features/
    courses/
      data/
        models/          ← CourseModel, SectionModel, LessonModel (extend entities, add fromJson)
        data_sources/    ← abstract CoursesDataSource + CoursesLocalDataSource
        repositories/    ← CoursesRepositoryImpl
      domain/
        entities/        ← Course, Section, Lesson (pure domain objects, base classes)
        repositories/    ← CoursesRepository (abstract interface)
      presentation/
        cubit/           ← CoursesCubit, state
        screens/         ← CoursesScreen, CourseDetailsScreen
        widgets/         ← CourseCard, SectionTile, LessonTile, etc.
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
- **No use cases.** Cubits call repository interfaces directly. The repository interface is the abstraction boundary.
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

### Repository — catches everything, returns Result with localization keys

```dart
class CoursesRepositoryImpl implements CoursesRepository {
  CoursesRepositoryImpl(this._dataSource);
  final CoursesDataSource _dataSource;

  @override
  Future<Result<List<Course>>> getCourses() async {
    try {
      final courses = await _dataSource.getCourses();
      return Success(courses);                        // Models ARE Entities
    } catch (e) {
      return const Failure('coursesLoadError');        // localization key, not text
    }
  }
}
```

### Cubit — never catches, folds on Result

```dart
class CoursesCubit extends Cubit<CoursesState> {
  CoursesCubit(this._repository) : super(const CoursesInitial());
  final CoursesRepository _repository;

  Future<void> loadCourses() async {
    emit(const CoursesLoading());
    final result = await _repository.getCourses();
    switch (result) {
      case Success(:final data):
        emit(CoursesLoaded(data));
      case Failure(:final message):
        emit(CoursesError(message));              // passes key as-is
    }
  }
}
```

### UI — localizes the error key

```dart
// In the screen's BlocBuilder:
CoursesError(:final message) => AppErrorView(
  message: context.tr(message),                   // localized here
  onRetry: () => context.read<CoursesCubit>().loadCourses(),
),
```

---

## Data Sources — abstract + implementation

```dart
// Abstract — the contract
abstract class CoursesDataSource {
  Future<List<CourseModel>> getCourses();
}

// Implementation — reads bundled JSON
class CoursesLocalDataSource implements CoursesDataSource {
  @override
  Future<List<CourseModel>> getCourses() async {
    final jsonString = await rootBundle.loadString('assets/data/courses.json');
    final data = jsonDecode(jsonString) as Map<String, Object?>;
    // parse and return models
  }
}
```

```dart
// Abstract
abstract class ProgressDataSource {
  Future<void> savePosition(String lessonId, int positionSeconds);
  int getPosition(String lessonId);
  Future<void> markCompleted(String lessonId);
  bool isCompleted(String lessonId);
}

// Implementation — SharedPreferences
class ProgressLocalDataSource implements ProgressDataSource {
  ProgressLocalDataSource(this._prefs);
  final SharedPreferences _prefs;

  @override
  Future<void> savePosition(String lessonId, int positionSeconds) async {
    await _prefs.setInt('position_$lessonId', positionSeconds);
  }

  @override
  int getPosition(String lessonId) => _prefs.getInt('position_$lessonId') ?? 0;

  @override
  Future<void> markCompleted(String lessonId) async {
    await _prefs.setBool('completed_$lessonId', true);
  }

  @override
  bool isCompleted(String lessonId) => _prefs.getBool('completed_$lessonId') ?? false;
}
```

---

## Business Rules (Progress & Unlock)

These rules live in the **repository layer**, not scattered across widgets or cubits.

- A lesson is **completed at 90% watched** — position ≥ 0.9 × duration.
- Lessons unlock **sequentially** — a lesson is playable only if the previous one in the section is completed. The first lesson in each section is always unlocked.
- **Course progress %** = completed lessons / total lessons × 100.
- **"Continue watching"** = the first lesson across all courses that is in-progress (has a saved position but is not completed).

---

## DI — Registration

All registration in `core/config/di/service_locator.dart` (project is small enough for one file):

```dart
final sl = GetIt.instance;

Future<void> initDependencies() async {
  final prefs = await SharedPreferences.getInstance();

  // Data Sources
  sl.registerLazySingleton<CoursesDataSource>(() => CoursesLocalDataSource());
  sl.registerLazySingleton<ProgressDataSource>(() => ProgressLocalDataSource(prefs));

  // Repositories
  sl.registerLazySingleton<CoursesRepository>(() => CoursesRepositoryImpl(sl()));
  sl.registerLazySingleton<ProgressRepository>(() => ProgressRepositoryImpl(sl()));

  // Cubits
  sl.registerFactory(() => CoursesCubit(sl()));
  sl.registerFactory(() => PlayerCubit(sl()));
}
```

---

## Localization — easy_localization

Translation files live in `lib/l10n/` (or `assets/l10n/`):

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
// AppRoutes — path constants
abstract class AppRoutes {
  static const courses = '/';
  static const courseDetails = '/course/:courseId';
  static const lessonPlayer = '/course/:courseId/lesson/:lessonId';

  static String courseDetailsPath(String courseId) => '/course/$courseId';
  static String lessonPlayerPath(String courseId, String lessonId) =>
      '/course/$courseId/lesson/$lessonId';
}
```

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
- Prefix reusable widgets with `App` (e.g. `AppErrorView`, `AppLoader`).

---

## Testing

### Standards
- **Pattern**: AAA (Arrange–Act–Assert) for every test.
- **Mocking**: `mocktail` (no code generation). Never use `mockito`.
- **Cubit testing**: `bloc_test` package with `blocTest<C, S>()` helper.
- **Naming**: `'should <expected> when <condition>'`.

### Required tests (per task spec)
At minimum **3 unit tests** for progress logic:
1. **90% completion rule** — lesson marks as completed when position ≥ 90% of duration.
2. **Sequential unlock rule** — lesson is locked until previous lesson is completed; first lesson is always unlocked.
3. **Progress % calculation** — course progress = completed / total × 100.

### Test Structure
```
test/
  features/
    courses/
      data/
        repositories/
          courses_repository_impl_test.dart
    player/
      data/
        repositories/
          progress_repository_impl_test.dart
      presentation/
        cubit/
          player_cubit_test.dart
  helpers/
    test_helpers.dart      ← shared mocks
```

### Layer Isolation

| Layer Under Test | What to Mock | What to Assert |
|---|---|---|
| Cubit | Repository interface | State emission sequence |
| Repository Impl | Data Source interface | Model→Entity mapping, Result wrapping |
| Data Source | SharedPreferences / rootBundle | Correct keys, parsing |
| Model | Nothing (pure data) | `fromJson` / `toJson` / `toEntity` round-trip |

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