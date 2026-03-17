import 'package:design_system/src/layout/action_zone.dart';
import 'package:design_system/src/layout/screen_layout.dart';
import 'package:design_system/src/layout/section_layout.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

class ToolLayout extends StatelessWidget {
  const ToolLayout({
    super.key,
    required this.title,
    required this.input,
    required this.primaryAction,
    this.result,
    this.history,
    this.subtitle,
    this.headerTrailing,
    this.footer,
  });

  final String title;
  final Widget input;
  final Widget primaryAction;
  final Widget? result;
  final Widget? history;
  final String? subtitle;
  final Widget? headerTrailing;
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
          SectionLayout(title: 'Input', child: input),
          const SizedBox(height: AppSpacing.md),
          ActionZone(primary: primaryAction),
          if (result != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionLayout(title: 'Result', child: result!),
          ],
          if (history != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            SectionLayout(title: 'History', child: history!),
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
