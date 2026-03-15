import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.action,
  });

  final String title;
  final String message;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 40, color: theme.colorScheme.primary),
        const SizedBox(height: AppSpacing.md),
        Text(title, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          action!,
        ],
      ],
    );
  }
}

