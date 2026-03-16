import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              theme.colorScheme.surface,
              Color.alphaBlend(
                theme.colorScheme.primary.withValues(alpha: 0.04),
                theme.colorScheme.surface,
              ),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              if (title != null ||
                  subtitle != null ||
                  trailing != null) ...<Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          if (title != null)
                            Text(title!, style: theme.textTheme.titleLarge),
                          if (subtitle != null) ...<Widget>[
                            const SizedBox(height: AppSpacing.xs),
                            Text(subtitle!, style: theme.textTheme.bodySmall),
                          ],
                        ],
                      ),
                    ),
                    if (trailing != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.md),
                      trailing!,
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    color: theme.colorScheme.outlineVariant.withValues(
                      alpha: 0.38,
                    ),
                  ),
                  child: const SizedBox(height: 1, width: double.infinity),
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
              child,
            ],
          ),
        ),
      ),
    );
  }
}
