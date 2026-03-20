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
  const CompactStatStrip({
    super.key,
    required this.items,
    this.compact = false,
  });

  final List<CompactStatItem> items;
  final bool compact;

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
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? AppSpacing.sm : AppSpacing.md,
                  vertical: compact ? AppSpacing.xs : AppSpacing.sm,
                ),
                child: RichText(
                  text: TextSpan(
                    children: <InlineSpan>[
                      TextSpan(
                        text: '${item.value}  ',
                        style: (compact
                                ? theme.textTheme.titleSmall
                                : theme.textTheme.titleMedium)
                            ?.copyWith(
                              color: accent,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      TextSpan(
                        text: item.label,
                        style: (compact
                                ? theme.textTheme.labelSmall
                                : theme.textTheme.bodySmall)
                            ?.copyWith(
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
