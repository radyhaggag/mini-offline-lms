import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

/// Modern input card for drafting notes with integrated dynamic submit action.
class AddNoteField extends StatefulWidget {
  const AddNoteField({super.key, required this.onAdd, this.isAdding = false});

  final ValueChanged<String> onAdd;
  final bool isAdding;

  @override
  State<AddNoteField> createState() => _AddNoteFieldState();
}

class _AddNoteFieldState extends State<AddNoteField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.trim().isNotEmpty;
    if (hasText != _canSubmit) {
      setState(() => _canSubmit = hasText);
    }
  }

  void _submit() {
    final trimmed = _controller.text.trim();
    if (trimmed.isEmpty) return;
    widget.onAdd(trimmed);
    _controller.clear();
    _focusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return Container(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: .circular(16),
        border: Border.all(
          color: _focusNode.hasFocus
              ? colors.primary
              : colors.outlineVariant.withValues(alpha: 0.4),
          width: _focusNode.hasFocus ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.shadow.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const .fromLTRB(14, 10, 10, 8),
      child: Column(
        crossAxisAlignment: .stretch,
        spacing: 8,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            minLines: 2,
            maxLines: 5,
            style: texts.bodyMedium,
            decoration: InputDecoration(
              hintText: context.tr('lessonNotesHint'),
              hintStyle: texts.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant.withValues(alpha: 0.6),
              ),
              border: InputBorder.none,
              isDense: true,
              contentPadding: .zero,
            ),
          ),
          Row(
            mainAxisAlignment: .spaceBetween,
            children: [
              Text(
                '${_controller.text.length} ${context.tr('characters')}',
                style: texts.labelSmall?.copyWith(
                  color: colors.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ),
              FilledButton(
                onPressed: (_canSubmit && !widget.isAdding) ? _submit : null,
                style: FilledButton.styleFrom(
                  padding: const .symmetric(horizontal: 14, vertical: 8),
                  shape: RoundedRectangleBorder(borderRadius: .circular(12)),
                ),
                child: Row(
                  mainAxisSize: .min,
                  spacing: 6,
                  children: [
                    Text(
                      context.tr('addNote'),
                      style: texts.labelMedium?.copyWith(
                        fontWeight: .bold,
                        color: _canSubmit ? colors.onPrimary : null,
                      ),
                    ),
                    if (widget.isAdding)
                      SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors.onPrimary,
                        ),
                      )
                    else
                      Icon(
                        Icons.send_rounded,
                        size: 16,
                        color: _canSubmit ? colors.onPrimary : null,
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
