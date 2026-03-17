import 'package:design_system/src/layout/action_zone.dart';
import 'package:design_system/src/layout/screen_layout.dart';
import 'package:design_system/src/layout/section_layout.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

class TrackerLayout extends StatelessWidget {
  const TrackerLayout({
    super.key,
    required this.title,
    required this.todayStatus,
    required this.primaryAction,
    required this.progress,
    this.subtitle,
    this.headerTrailing,
    this.historyPreview,
    this.footer,
  });

  final String title;
  final Widget todayStatus;
  final Widget primaryAction;
  final Widget progress;
  final String? subtitle;
  final Widget? headerTrailing;
  final Widget? historyPreview;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (subtitle != null) ...<Widget>[
                      const SizedBox(height: AppSpacing.xs),
                      Text(subtitle!, style: theme.textTheme.bodyMedium),
                    ],
                  ],
                ),
              ),
              if (headerTrailing != null) ...<Widget>[
                const SizedBox(width: AppSpacing.md),
                Flexible(child: headerTrailing!),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SectionLayout(title: "Today's status", child: todayStatus),
          const SizedBox(height: AppSpacing.md),
          ActionZone(primary: primaryAction),
          const SizedBox(height: AppSpacing.lg),
          SectionLayout(title: 'Progress', child: progress),
          if (historyPreview != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionLayout(title: 'History', child: historyPreview!),
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
