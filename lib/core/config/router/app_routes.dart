/// Centralized route path constants.
/// Never inline path strings in widgets — always use AppRoutes helpers.
abstract class AppRoutes {
  static const courses = '/';
  static const courseDetails = '/course/:courseId';
  static const lessonPlayer = '/course/:courseId/lesson/:lessonId';

  static String courseDetailsPath(String courseId) => '/course/$courseId';
  static String lessonPlayerPath(String courseId, String lessonId) =>
      '/course/$courseId/lesson/$lessonId';
}
