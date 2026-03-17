import 'package:design_system/src/layout/action_zone.dart';
import 'package:design_system/src/layout/screen_layout.dart';
import 'package:design_system/src/layout/section_layout.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

class TimerLayout extends StatelessWidget {
  const TimerLayout({
    super.key,
    required this.title,
    required this.timer,
    required this.primaryAction,
    required this.selector,
    this.status,
    this.headerTrailing,
    this.secondaryActions,
    this.stats,
    this.footer,
  });

  final String title;
  final Widget timer;
  final Widget primaryAction;
  final Widget selector;
  final Widget? status;
  final Widget? headerTrailing;
  final Widget? secondaryActions;
  final Widget? stats;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return ScreenLayout(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
              if (headerTrailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.md),
                Flexible(child: headerTrailing!),
              ],
            ],
          ),
          if (status != null) ...<Widget>[
            const SizedBox(height: AppSpacing.sm),
            status!,
          ],
          const SizedBox(height: AppSpacing.xs),
          TimerHero(child: timer),
          const SizedBox(height: AppSpacing.md),
          PrimaryActionZone(
            primary: primaryAction,
            secondary: secondaryActions,
          ),
          const SizedBox(height: AppSpacing.lg),
          SelectorSection(title: 'Selector', child: selector),
          if (stats != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionLayout(title: 'Stats', child: stats!),
          ],
          if (footer != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            footer!,
          ],
        ],
      ),
    );
  }
}
