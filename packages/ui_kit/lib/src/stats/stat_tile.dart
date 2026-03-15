import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class StatTile extends StatelessWidget {
  const StatTile({
    super.key,
    required this.label,
    required this.value,
    this.detail,
    this.highlight,
  });

  final String label;
  final String value;
  final String? detail;
  final Color? highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlight ?? theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppRadius.medium),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(color: color),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(label, style: theme.textTheme.titleMedium),
            if (detail != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xxs),
              Text(detail!, style: theme.textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}
