import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/lesson_note.dart';

/// Displays note content first, followed closely by its timestamp and compact action menu.
class NoteViewMode extends StatelessWidget {
  const NoteViewMode({
    super.key,
    required this.note,
    required this.formattedDate,
    required this.onEditTap,
    required this.onDelete,
  });

  final LessonNote note;
  final String formattedDate;
  final VoidCallback onEditTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    final Widget? editedBadge = note.updatedAt != null
        ? Container(
            padding: const .symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: colors.secondaryContainer.withValues(alpha: 0.6),
              borderRadius: .circular(4),
            ),
            child: Text(
              context.tr('edited'),
              style: texts.labelSmall?.copyWith(
                color: colors.onSecondaryContainer,
                fontSize: 9,
                fontWeight: .w600,
              ),
            ),
          )
        : null;

    return Column(
      crossAxisAlignment: .start,
      spacing: 3,
      children: [
        Row(
          crossAxisAlignment: .start,
          children: [
            Expanded(
              child: Text(
                note.content,
                style: texts.bodyMedium?.copyWith(
                  color: colors.onSurface,
                  height: 1.35,
                ),
              ),
            ),
            _NotePopupMenu(onEditTap: onEditTap, onDelete: onDelete),
          ],
        ),
        Row(
          spacing: 4,
          children: [
            Icon(
              Icons.schedule_rounded,
              size: 11,
              color: colors.onSurfaceVariant.withValues(alpha: 0.65),
            ),
            Text(
              formattedDate,
              style: texts.labelSmall?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.65),
                fontSize: 11,
              ),
            ),
            ?editedBadge,
          ],
        ),
      ],
    );
  }
}

/// Compact 3-dot popup menu for note actions (Edit & Delete).
class _NotePopupMenu extends StatelessWidget {
  const _NotePopupMenu({required this.onEditTap, required this.onDelete});

  final VoidCallback onEditTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return SizedBox(
      width: 22,
      height: 22,
      child: PopupMenuButton<_NoteAction>(
        tooltip: '',
        padding: .zero,
        constraints: const BoxConstraints(),
        menuPadding: const .symmetric(vertical: 4),
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: .circular(10),
          side: BorderSide(
            color: colors.outlineVariant.withValues(alpha: 0.25),
          ),
        ),
        color: colors.surfaceContainerHighest,
        onSelected: (action) {
          switch (action) {
            case _NoteAction.edit:
              onEditTap();
            case _NoteAction.delete:
              onDelete();
          }
        },
        icon: Icon(
          Icons.more_vert_rounded,
          size: 16,
          color: colors.onSurfaceVariant.withValues(alpha: 0.6),
        ),
        itemBuilder: (context) => [
          PopupMenuItem(
            value: _NoteAction.edit,
            height: 32,
            padding: const .symmetric(horizontal: 10),
            child: Row(
              spacing: 8,
              children: [
                Icon(Icons.edit_rounded, size: 15, color: colors.primary),
                Text(
                  context.tr('editNote'),
                  style: texts.labelMedium?.copyWith(color: colors.onSurface),
                ),
              ],
            ),
          ),
          PopupMenuItem(
            value: _NoteAction.delete,
            height: 32,
            padding: const .symmetric(horizontal: 10),
            child: Row(
              spacing: 8,
              children: [
                Icon(
                  Icons.delete_outline_rounded,
                  size: 15,
                  color: colors.error,
                ),
                Text(
                  context.tr('deleteNote'),
                  style: texts.labelMedium?.copyWith(color: colors.error),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _NoteAction { edit, delete }
