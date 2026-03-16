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
    final ThemeData theme = Theme.of(context);
    final Color color = highlight ?? theme.colorScheme.primary;
    final Color background = Color.alphaBlend(
      color.withValues(alpha: 0.10),
      theme.colorScheme.surface,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: color.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withValues(alpha: 0.78),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      label.toUpperCase(),
                      style: theme.textTheme.bodySmall?.copyWith(
                        letterSpacing: 0.8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.trending_up_rounded,
                  size: 18,
                  color: color.withValues(alpha: 0.72),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (detail != null) ...<Widget>[
              const SizedBox(height: AppSpacing.sm),
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
