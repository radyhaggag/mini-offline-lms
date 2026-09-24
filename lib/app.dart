import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'core/config/router/app_router.dart';
import 'core/config/theme/app_theme.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      locale: context.locale,
      supportedLocales: context.supportedLocales,
      localizationsDelegates: context.localizationDelegates,
      routerConfig: AppRouter.router,
    );
  }
}
