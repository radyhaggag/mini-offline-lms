import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';

class AppEmptyView extends StatelessWidget {
  const AppEmptyView({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
  });

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisAlignment: .center,
          spacing: 16,
          children: [
            Icon(icon, size: 48, color: context.colorScheme.onSurfaceVariant),
            Text(
              message,
              style: context.textTheme.bodyLarge?.copyWith(
                color: context.colorScheme.onSurfaceVariant,
              ),
              textAlign: .center,
            ),
          ],
        ),
      ),
    );
  }
}
