import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

import '../navigation/app_menu.dart';
import 'app_drawer_destination.dart';
import 'app_shell.dart';
import 'drawer_destination_resolver.dart';

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
    this.drawerDestinations = const <AppDrawerDestination>[],
    this.onSubscriptionTap,
    this.appMenuSpec,
    this.expandBody = false,
    this.contentPadding,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? action;
  final Widget? headerTrailing;
  final bool scrollable;
  final Widget? footer;
  final List<AppDrawerDestination> drawerDestinations;
  final VoidCallback? onSubscriptionTap;
  final AppMenuSpec? appMenuSpec;
  final bool expandBody;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final List<AppDrawerDestination> resolvedDrawerDestinations =
        resolveDrawerDestinations(
          context,
          drawerDestinations: drawerDestinations,
          appTitle: title,
          appMenuSpec: appMenuSpec,
          onSubscriptionTap: onSubscriptionTap,
        );
    final Widget content = _ScaffoldContent(
      subtitle: subtitle,
      action: action,
      body: body,
      expandBody: expandBody,
    );

    return AppShell(
      title: title,
      headerTrailing: headerTrailing,
      footer: footer,
      drawerDestinations: resolvedDrawerDestinations,
      scrollable: scrollable,
      contentPadding: contentPadding,
      body: content,
    );
  }
}

class _ScaffoldContent extends StatelessWidget {
  const _ScaffoldContent({
    required this.subtitle,
    required this.action,
    required this.body,
    required this.expandBody,
  });

  final String? subtitle;
  final Widget? action;
  final Widget body;
  final bool expandBody;

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
        if (expandBody)
          Expanded(child: SizedBox(width: double.infinity, child: body))
        else
          SizedBox(width: double.infinity, child: body),
      ],
    );
  }
}
