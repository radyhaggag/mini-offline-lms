import 'package:go_router/go_router.dart';

import 'app_routes.dart';

abstract class AppRouter {
  static final router = GoRouter(
    initialLocation: AppRoutes.courses,
    routes: [],
  );
}
