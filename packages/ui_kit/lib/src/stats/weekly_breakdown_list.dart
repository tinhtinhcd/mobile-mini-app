import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

@immutable
class WeeklyBreakdownItem {
  const WeeklyBreakdownItem({
    required this.label,
    required this.primaryValue,
    required this.secondaryValue,
    required this.progress,
    this.emphasis = false,
  });

  final String label;
  final String primaryValue;
  final String secondaryValue;
  final double progress;
  final bool emphasis;
}

class WeeklyBreakdownList extends StatelessWidget {
  const WeeklyBreakdownList({super.key, required this.items, this.barColor});

  final List<WeeklyBreakdownItem> items;
  final Color? barColor;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = barColor ?? theme.colorScheme.primary;

    return Column(
      children: items
          .map((WeeklyBreakdownItem item) {
            final double clampedProgress = item.progress.clamp(0, 1).toDouble();
            final Color rowAccent =
                item.emphasis ? theme.colorScheme.tertiary : accent;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: <Widget>[
                  SizedBox(
                    width: 26,
                    child: Text(
                      item.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                item.primaryValue,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            Text(
                              item.secondaryValue,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.pill),
                          child: LinearProgressIndicator(
                            value: clampedProgress,
                            minHeight: 6,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              rowAccent,
                            ),
                            backgroundColor: Color.alphaBlend(
                              rowAccent.withValues(alpha: 0.08),
                              theme.colorScheme.surface,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          })
          .toList(growable: false),
    );
  }
}
