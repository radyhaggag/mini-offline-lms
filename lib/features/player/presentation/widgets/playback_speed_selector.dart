import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../../core/utils/extensions/context_extensions.dart';

/// Modal bottom sheet widget for selecting playback speed (1x, 1.25x, 1.5x, 2x).
class PlaybackSpeedSelector extends StatelessWidget {
  const PlaybackSpeedSelector({
    super.key,
    required this.currentSpeed,
    required this.onSpeedSelected,
  });

  final double currentSpeed;
  final ValueChanged<double> onSpeedSelected;

  static const List<double> availableSpeeds = [1.0, 1.25, 1.5, 2.0];

  /// Opens the speed selector modal bottom sheet.
  static Future<void> show(
    BuildContext context, {
    required double currentSpeed,
    required ValueChanged<double> onSpeedSelected,
  }) {
    return showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (sheetContext) => PlaybackSpeedSelector(
        currentSpeed: currentSpeed,
        onSpeedSelected: (speed) {
          Navigator.of(sheetContext).pop();
          onSpeedSelected(speed);
        },
      ),
    );
  }

  String _formatSpeedLabel(BuildContext context, double speed) {
    if (speed == 1.0) {
      return context.tr('normalSpeed');
    }
    return '${speed}x';
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    final texts = context.textTheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const .fromLTRB(16, 0, 16, 20),
        child: Column(
          mainAxisSize: .min,
          crossAxisAlignment: .stretch,
          spacing: 8,
          children: [
            Padding(
              padding: const .symmetric(vertical: 8, horizontal: 16),
              child: Text(
                context.tr('playbackSpeed'),
                style: texts.titleMedium?.copyWith(fontWeight: .bold),
              ),
            ),
            for (final speed in availableSpeeds)
              _SpeedTile(
                label: _formatSpeedLabel(context, speed),
                isSelected: (currentSpeed - speed).abs() < 0.01,
                onTap: () => onSpeedSelected(speed),
                colors: colors,
                texts: texts,
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeedTile extends StatelessWidget {
  const _SpeedTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
    required this.texts,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colors;
  final TextTheme texts;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: .circular(12)),
      tileColor: isSelected
          ? colors.primaryContainer.withValues(alpha: 0.35)
          : null,
      leading: Icon(
        Icons.speed_rounded,
        color: isSelected ? colors.primary : colors.onSurfaceVariant,
      ),
      title: Text(
        label,
        style: texts.bodyLarge?.copyWith(
          fontWeight: isSelected ? .bold : .normal,
          color: isSelected ? colors.primary : colors.onSurface,
        ),
      ),
      trailing: isSelected
          ? Icon(Icons.check_rounded, color: colors.primary)
          : null,
    );
  }
}
