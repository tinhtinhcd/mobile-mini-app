import 'package:design_system/design_system.dart';
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
    final ThemeData theme = Theme.of(context);
    final Color color = highlight ?? theme.colorScheme.primary;
    final Color background = Color.alphaBlend(
      color.withValues(alpha: 0.06),
      theme.colorScheme.surface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.10)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              label.toUpperCase(),
              style: theme.textTheme.bodySmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (detail != null) ...<Widget>[
              const SizedBox(height: AppSpacing.xs),
              Text(
                detail!,
                style: theme.textTheme.bodySmall?.copyWith(height: 1.5),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
