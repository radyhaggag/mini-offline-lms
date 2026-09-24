import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

/// Persistent search field displayed above the course list.
class CoursesSearchBar extends StatelessWidget {
  const CoursesSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: .search,
      decoration: InputDecoration(
        hintText: context.tr('searchCourses'),
        prefixIcon: Icon(Icons.search_rounded, color: colors.onSurfaceVariant),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.close_rounded, color: colors.onSurfaceVariant),
                onPressed: onClear,
                tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              )
            : null,
        filled: true,
        fillColor: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: .none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: .none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: .circular(12),
          borderSide: BorderSide(color: colors.primary, width: 1.5),
        ),
        contentPadding: const .symmetric(vertical: 0, horizontal: 16),
      ),
    );
  }
}
