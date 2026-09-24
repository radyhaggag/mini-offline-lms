import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

/// Top bar of video player overlay showing back button and lesson title in fullscreen mode.
class PlayerTopControls extends StatelessWidget {
  const PlayerTopControls({
    super.key,
    required this.title,
    required this.onToggleFullscreen,
  });

  final String title;
  final VoidCallback onToggleFullscreen;

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return Padding(
      padding: const .symmetric(horizontal: 16, vertical: 8),
      child: Row(
        spacing: 12,
        children: [
          IconButton(
            onPressed: onToggleFullscreen,
            icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
          ),
          Expanded(
            child: Text(
              title,
              style: texts.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: .bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
