import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../../domain/entities/lesson_note.dart';
import 'note_edit_mode.dart';
import 'note_view_mode.dart';

/// Card widget displaying an individual study note with inline editing capability.
class NoteItemCard extends StatefulWidget {
  const NoteItemCard({
    super.key,
    required this.note,
    required this.onDelete,
    required this.onUpdate,
  });

  final LessonNote note;
  final VoidCallback onDelete;
  final ValueChanged<String> onUpdate;

  @override
  State<NoteItemCard> createState() => _NoteItemCardState();
}

class _NoteItemCardState extends State<NoteItemCard> {
  bool _isEditing = false;
  late final TextEditingController _editController;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: widget.note.content);
  }

  @override
  void didUpdateWidget(covariant NoteItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.note.content != widget.note.content && !_isEditing) {
      _editController.text = widget.note.content;
    }
  }

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  void _saveEdit() {
    final trimmed = _editController.text.trim();
    if (trimmed.isEmpty) return;
    widget.onUpdate(trimmed);
    setState(() => _isEditing = false);
  }

  void _cancelEdit() {
    _editController.text = widget.note.content;
    setState(() => _isEditing = false);
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final date = widget.note.updatedAt ?? widget.note.createdAt;
    final formattedDate = DateFormat.yMMMd(context.locale.toString())
        .add_jm()
        .format(date);

    return ClipRRect(
      borderRadius: .circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: .circular(14),
          border: Border.all(
            color: colors.outlineVariant.withValues(alpha: 0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: .stretch,
          children: [
            Container(height: 3, color: colors.primary.withValues(alpha: 0.65)),
            Padding(
              padding: const .fromLTRB(12, 8, 8, 8),
              child: _isEditing
                  ? NoteEditMode(
                      controller: _editController,
                      onSave: _saveEdit,
                      onCancel: _cancelEdit,
                    )
                  : NoteViewMode(
                      note: widget.note,
                      formattedDate: formattedDate,
                      onEditTap: () => setState(() => _isEditing = true),
                      onDelete: widget.onDelete,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
