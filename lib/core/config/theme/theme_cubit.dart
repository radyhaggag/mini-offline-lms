import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cubit managing application theme mode (light / dark) with persistence.
class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._prefs) : super(_loadInitialMode(_prefs));

  final SharedPreferences _prefs;
  static const _themePrefKey = 'app_theme_mode';

  static ThemeMode _loadInitialMode(SharedPreferences prefs) {
    final modeStr = prefs.getString(_themePrefKey);
    return switch (modeStr) {
      'dark' => .dark,
      'light' => .light,
      _ => .light,
    };
  }

  /// Toggles between light and dark themes.
  Future<void> toggleTheme() async {
    final nextMode = state == .dark ? ThemeMode.light : ThemeMode.dark;
    emit(nextMode);
    await _prefs.setString(_themePrefKey, nextMode == .dark ? 'dark' : 'light');
  }

  /// Explicitly sets the theme mode.
  Future<void> setTheme(ThemeMode mode) async {
    emit(mode);
    await _prefs.setString(_themePrefKey, mode == .dark ? 'dark' : 'light');
  }
}
