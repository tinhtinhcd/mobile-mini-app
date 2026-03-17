import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import 'app_shell.dart';

class FactoryScaffold extends StatelessWidget {
  const FactoryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.action,
    this.headerTrailing,
    this.footer,
    this.drawerItems = const <AppDrawerItem>[],
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? action;
  final Widget? headerTrailing;
  final Widget? footer;
  final List<AppDrawerItem> drawerItems;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final Widget content = _ScaffoldContent(
      subtitle: subtitle,
      action: action,
      body: body,
    );

    return AppShell(
      title: title,
      headerTrailing: headerTrailing,
      footer: footer,
      drawerItems: drawerItems,
      scrollable: scrollable,
      body: content,
    );
  }
}

class _ScaffoldContent extends StatelessWidget {
  const _ScaffoldContent({
    required this.subtitle,
    required this.action,
    required this.body,
  });

  final String? subtitle;
  final Widget? action;
  final Widget body;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (subtitle != null) ...<Widget>[
          Text(
            subtitle!,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        if (action != null) ...<Widget>[
          action!,
          const SizedBox(height: AppShellMetrics.sectionSpacing),
        ],
        const SizedBox(height: AppSpacing.xs),
        SizedBox(width: double.infinity, child: body),
      ],
    );
  }
}
