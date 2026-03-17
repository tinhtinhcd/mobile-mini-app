import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class CompactStatItem {
  const CompactStatItem({
    required this.label,
    required this.value,
    this.highlight,
  });

  final String label;
  final String value;
  final Color? highlight;
}

class CompactStatStrip extends StatelessWidget {
  const CompactStatStrip({super.key, required this.items});

  final List<CompactStatItem> items;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children:
          items.map((CompactStatItem item) {
            final Color accent = item.highlight ?? theme.colorScheme.primary;
            return DecoratedBox(
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  accent.withValues(alpha: 0.05),
                  theme.colorScheme.surface,
                ),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(color: accent.withValues(alpha: 0.12)),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: '${item.value}  ',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      TextSpan(
                        text: item.label,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
