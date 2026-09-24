import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

/// Self-contained icon button toggling Arabic and English application locales.
class AppLanguageToggle extends StatelessWidget {
  const AppLanguageToggle({super.key});

  void _toggleLanguage(BuildContext context) {
    final nextLocale = context.locale.languageCode == 'ar'
        ? const Locale('en')
        : const Locale('ar');
    context.setLocale(nextLocale);
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: context.tr('language'),
      icon: const Icon(Icons.language_rounded),
      onPressed: () => _toggleLanguage(context),
    );
  }
}
