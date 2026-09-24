import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../config/theme/theme_cubit.dart';
import '../utils/extensions/context_extensions.dart';

/// Self-contained icon button toggling application light and dark themes.
class AppThemeToggle extends StatelessWidget {
  const AppThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        final isDark =
            themeMode == .dark ||
            (themeMode == .system && context.theme.brightness == .dark);

        return IconButton(
          tooltip: isDark ? context.tr('lightMode') : context.tr('darkMode'),
          icon: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
          ),
          onPressed: () => context.read<ThemeCubit>().toggleTheme(),
        );
      },
    );
  }
}
