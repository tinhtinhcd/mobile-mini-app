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
    this.scrollable = true,
    this.footer,
    this.drawerItems = const <AppDrawerItem>[],
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? action;
  final Widget? headerTrailing;
  final bool scrollable;
  final Widget? footer;
  final List<AppDrawerItem> drawerItems;

  @override
  Widget build(BuildContext context) {
    final List<AppDrawerItem> resolvedDrawerItems =
        drawerItems.isEmpty
            ? _buildDefaultDrawerItems(context, title: title)
            : drawerItems;
    final Widget content = _ScaffoldContent(
      subtitle: subtitle,
      action: action,
      body: body,
    );

    return AppShell(
      title: title,
      headerTrailing: headerTrailing,
      footer: footer,
      drawerItems: resolvedDrawerItems,
      scrollable: scrollable,
      body: content,
    );
  }

  List<AppDrawerItem> _buildDefaultDrawerItems(
    BuildContext context, {
    required String title,
  }) {
    return <AppDrawerItem>[
      AppDrawerItem(
        label: 'About App',
        icon: Icons.info_outline_rounded,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: 'About $title',
              description:
                  'A reusable placeholder surface for app information. Hook the real destination in when the page is ready.',
            ),
      ),
      AppDrawerItem(
        label: 'Settings / Config',
        icon: Icons.settings_outlined,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: 'Settings',
              description:
                  'Settings lives in the shared shell now. Wire in the real configuration screen when it is implemented.',
            ),
      ),
      AppDrawerItem(
        label: 'Subscription Plan',
        icon: Icons.workspace_premium_outlined,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: 'Subscription Plan',
              description:
                  'Subscription management can be connected here without cluttering the main task screen.',
            ),
      ),
      AppDrawerItem(
        label: 'Privacy',
        icon: Icons.privacy_tip_outlined,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: 'Privacy',
              description:
                  'Add the privacy destination here when the shared legal pages are ready.',
            ),
      ),
      AppDrawerItem(
        label: 'Feedback',
        icon: Icons.feedback_outlined,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: 'Feedback',
              description:
                  'Route feedback and support flows here without changing the main app flow.',
            ),
      ),
    ];
  }

  void _showPlaceholderSheet(
    BuildContext context, {
    required String title,
    required String description,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        final ThemeData theme = Theme.of(context);
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.sm,
              AppSpacing.lg,
              AppSpacing.lg,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(title, style: theme.textTheme.titleLarge),
                const SizedBox(height: AppSpacing.sm),
                Text(description, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        );
      },
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
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (subtitle != null) ...<Widget>[
          Text(
            subtitle!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],
        if (action != null) ...<Widget>[
          action!,
          const SizedBox(height: AppSpacing.lg),
        ],
        SizedBox(width: double.infinity, child: body),
      ],
    );
  }
}
