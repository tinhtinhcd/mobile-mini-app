import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class FactoryScaffold extends StatelessWidget {
  const FactoryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.action,
    this.headerTrailing,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? action;
  final Widget? headerTrailing;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final Widget content = _ScaffoldContent(
      title: title,
      subtitle: subtitle,
      headerTrailing: headerTrailing,
      action: action,
      body: body,
    );

    return ScreenLayout(scrollable: scrollable, child: content);
  }
}

class _ScaffoldContent extends StatelessWidget {
  const _ScaffoldContent({
    required this.title,
    required this.subtitle,
    required this.headerTrailing,
    required this.action,
    required this.body,
  });

  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final Widget? action;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    Text(
                      subtitle!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
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
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.md),
          action!,
        ],
        const SizedBox(height: AppSpacing.lg),
        SizedBox(width: double.infinity, child: body),
      ],
    );
  }
}
