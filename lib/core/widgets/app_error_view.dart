import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../utils/extensions/context_extensions.dart';

class AppErrorView extends StatelessWidget {
  const AppErrorView({super.key, required this.message, this.onRetry});

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retryButton = onRetry != null
        ? FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(context.tr('retry')),
          )
        : null;

    return Center(
      child: Padding(
        padding: const .all(24),
        child: Column(
          mainAxisAlignment: .center,
          spacing: 16,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: context.colorScheme.error,
            ),
            Text(
              message,
              style: context.textTheme.bodyLarge,
              textAlign: .center,
            ),
            ?retryButton,
          ],
        ),
      ),
    );
  }
}
