import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/extensions/context_extensions.dart';
import '../cubit/lesson_notes_cubit.dart';
import '../cubit/lesson_notes_state.dart';
import 'add_note_field.dart';
import 'note_item_card.dart';

/// Modern study notes workspace for lessons with animated transitions.
class LessonNotesSection extends StatelessWidget {
  const LessonNotesSection({super.key, required this.lessonId});

  final String lessonId;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return BlocBuilder<LessonNotesCubit, LessonNotesState>(
      builder: (context, state) {
        final notes = state is LessonNotesLoaded ? state.notes : const [];
        final isAdding = state is LessonNotesLoaded && state.isAdding;
        final cubit = context.read<LessonNotesCubit>();

        return Padding(
          padding: const .symmetric(horizontal: 16, vertical: 8),
          child: Container(
            padding: const .all(16),
            decoration: BoxDecoration(
              color: colors.surfaceContainerLowest,
              borderRadius: .circular(20),
              border: Border.all(
                color: colors.outlineVariant.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: colors.shadow.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: .stretch,
              spacing: 14,
              children: [
                Row(
                  spacing: 10,
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.edit_note_rounded,
                        color: colors.primary,
                        size: 20,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        context.tr('lessonNotes'),
                        style: texts.titleMedium?.copyWith(
                          fontWeight: .bold,
                          color: colors.onSurface,
                        ),
                      ),
                    ),
                    Container(
                      padding: const .symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: colors.primary.withValues(alpha: 0.1),
                        borderRadius: .circular(12),
                      ),
                      child: Text(
                        '${notes.length}',
                        style: texts.labelSmall?.copyWith(
                          color: colors.primary,
                          fontWeight: .bold,
                        ),
                      ),
                    ),
                  ],
                ),
                AddNoteField(
                  isAdding: isAdding,
                  onAdd: (content) {
                    cubit.addNote(lessonId: lessonId, content: content);
                  },
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.25),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: notes.isEmpty
                      ? Padding(
                          padding: const .symmetric(vertical: 20),
                          child: Column(
                            spacing: 8,
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: colors.surfaceContainerHighest
                                      .withValues(alpha: 0.5),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.draw_rounded,
                                  size: 24,
                                  color: colors.onSurfaceVariant.withValues(
                                    alpha: 0.6,
                                  ),
                                ),
                              ),
                              Text(
                                context.tr('noNotesYet'),
                                style: texts.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                                textAlign: .center,
                              ),
                            ],
                          ),
                        )
                      : Column(
                          spacing: 10,
                          children: [
                            for (final note in notes)
                              NoteItemCard(
                                key: ValueKey(note.id),
                                note: note,
                                onUpdate: (newContent) {
                                  cubit.updateNote(
                                    lessonId: lessonId,
                                    noteId: note.id,
                                    newContent: newContent,
                                  );
                                },
                                onDelete: () {
                                  cubit.deleteNote(
                                    lessonId: lessonId,
                                    noteId: note.id,
                                  );
                                },
                              ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
