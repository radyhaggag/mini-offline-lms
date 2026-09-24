import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

/// Inline text field with save/cancel controls for editing an existing note.
class NoteEditMode extends StatelessWidget {
  const NoteEditMode({
    super.key,
    required this.controller,
    required this.onSave,
    required this.onCancel,
  });

  final TextEditingController controller;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return Column(
      crossAxisAlignment: .stretch,
      spacing: 6,
      children: [
        TextField(
          controller: controller,
          autofocus: true,
          minLines: 2,
          maxLines: 4,
          style: texts.bodyMedium,
          decoration: const InputDecoration(
            border: InputBorder.none,
            isDense: true,
            contentPadding: .zero,
          ),
        ),
        Row(
          mainAxisAlignment: .end,
          spacing: 6,
          children: [
            TextButton(
              onPressed: onCancel,
              style: TextButton.styleFrom(
                padding: const .symmetric(horizontal: 10, vertical: 4),
                visualDensity: .compact,
              ),
              child: Text(context.tr('cancel')),
            ),
            FilledButton(
              onPressed: onSave,
              style: FilledButton.styleFrom(
                padding: const .symmetric(horizontal: 12, vertical: 4),
                visualDensity: .compact,
                shape: RoundedRectangleBorder(borderRadius: .circular(8)),
              ),
              child: Text(
                context.tr('save'),
                style: texts.labelMedium?.copyWith(
                  color: colors.onPrimary,
                  fontWeight: .bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
