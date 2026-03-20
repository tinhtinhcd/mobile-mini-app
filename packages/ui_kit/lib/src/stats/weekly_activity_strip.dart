import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class WeeklyActivityEntry {
  const WeeklyActivityEntry({
    required this.label,
    required this.value,
    this.emphasis = false,
  });

  final String label;
  final double value;
  final bool emphasis;
}

class WeeklyActivityStrip extends StatelessWidget {
  const WeeklyActivityStrip({
    super.key,
    required this.entries,
    this.maxValue,
    this.barColor,
    this.compact = false,
  });

  final List<WeeklyActivityEntry> entries;
  final double? maxValue;
  final Color? barColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color accent = barColor ?? theme.colorScheme.primary;
    final double barHeight = compact ? 28 : 44;
    final double resolvedMax = math.max(
      maxValue ??
          entries.fold<double>(0, (double max, WeeklyActivityEntry entry) {
            return math.max(max, entry.value);
          }),
      1,
    );

    return Row(
      children:
          entries.map((WeeklyActivityEntry entry) {
            final double ratio = (entry.value / resolvedMax).clamp(0.0, 1.0);
            final Color resolvedAccent =
                entry.emphasis
                    ? accent
                    : Color.alphaBlend(
                      accent.withValues(alpha: 0.35),
                      theme.colorScheme.secondaryContainer,
                    );

            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Container(
                      height: barHeight,
                      decoration: BoxDecoration(
                        color: Color.alphaBlend(
                          resolvedAccent.withValues(alpha: 0.06),
                          theme.colorScheme.surfaceContainerHighest,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.small),
                        border: Border.all(
                          color: resolvedAccent.withValues(
                            alpha: entry.emphasis ? 0.22 : 0.12,
                          ),
                        ),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: FractionallySizedBox(
                          widthFactor: 1,
                          heightFactor: ratio == 0 ? 0.14 : ratio,
                          alignment: Alignment.bottomCenter,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: resolvedAccent,
                              borderRadius: BorderRadius.circular(
                                AppRadius.small,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: compact ? AppSpacing.xxs : AppSpacing.xs),
                    Text(
                      entry.label,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color:
                            entry.emphasis
                                ? theme.colorScheme.onSurface
                                : theme.colorScheme.onSurfaceVariant,
                        fontWeight:
                            entry.emphasis ? FontWeight.w700 : FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}
