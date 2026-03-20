import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class TimerDisplayCard extends StatelessWidget {
  const TimerDisplayCard({
    super.key,
    required this.label,
    required this.timeText,
    required this.progress,
    this.statusText,
    this.footnote,
    this.compact = false,
  });

  final String label;
  final String timeText;
  final double progress;
  final String? statusText;
  final String? footnote;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    final double clampedProgress = progress.clamp(0, 1).toDouble();
    final double padding = compact ? AppSpacing.sm : AppSpacing.lg;
    final double largeGap = compact ? AppSpacing.sm : AppSpacing.lg;
    final double smallGap = compact ? AppSpacing.xxs : AppSpacing.sm;
    final TextStyle? timeStyle =
        compact
            ? theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              color: theme.colorScheme.onSurface,
            )
            : theme.textTheme.displayLarge?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
              color: theme.colorScheme.onSurface,
            );

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            Color.alphaBlend(
              primary.withValues(alpha: 0.18),
              theme.colorScheme.surface,
            ),
            Color.alphaBlend(
              primary.withValues(alpha: 0.05),
              theme.colorScheme.surface,
            ),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: primary.withValues(alpha: 0.16)),
      ),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: compact ? AppSpacing.xxs : AppSpacing.xs,
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withValues(alpha: 0.72),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              child: Text(
                label.toUpperCase(),
                style: theme.textTheme.bodySmall?.copyWith(
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            SizedBox(height: largeGap),
            Text(timeText, style: timeStyle),
            if (statusText != null) ...<Widget>[
              SizedBox(height: smallGap),
              AnimatedSwitcher(
                duration: 180.ms,
                switchInCurve: Curves.easeOutCubic,
                switchOutCurve: Curves.easeInCubic,
                child: _StatusChip(
                      key: ValueKey<String>(statusText!),
                      label: statusText!,
                    )
                    .animate()
                    .fadeIn(duration: 180.ms)
                    .slideX(begin: 0.08, end: 0, duration: 180.ms),
              ),
            ],
            SizedBox(height: largeGap),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.small),
              child: LinearProgressIndicator(value: clampedProgress),
            ),
            if (footnote != null) ...<Widget>[
              SizedBox(height: smallGap),
              Text(
                footnote!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: AppSpacing.xs,
        ),
        child: Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
