import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

import '../buttons/app_buttons.dart';

class PremiumCalloutCard extends StatelessWidget {
  const PremiumCalloutCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.badgeLabel = 'Premium',
    this.actionLabel,
    this.onPressed,
  });

  final String title;
  final String subtitle;
  final String badgeLabel;
  final String? actionLabel;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(
              primary.withValues(alpha: 0.14),
              theme.colorScheme.surface,
            ),
            Color.alphaBlend(
              primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.84),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeLabel.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(subtitle, style: theme.textTheme.bodyMedium),
            if (actionLabel != null && onPressed != null) ...<Widget>[
              const SizedBox(height: AppSpacing.md),
              AppSecondaryButton(
                label: actionLabel!,
                icon: const Icon(Icons.workspace_premium_rounded),
                onPressed: onPressed,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
