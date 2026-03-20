import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import '../navigation/app_menu.dart';
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
  final List<AppDrawerItem> drawerItems;
  final VoidCallback? onSubscriptionTap;
  final AppMenuSpec? appMenuSpec;
  final bool expandBody;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final List<AppDrawerItem> resolvedDrawerItems =
        drawerItems.isEmpty
            ? appMenuSpec != null
                ? buildAppMenuDrawerItems(context, spec: appMenuSpec!)
                : _buildDefaultDrawerItems(
                  context,
                  title: title,
                  onSubscriptionTap: onSubscriptionTap,
                )
            : drawerItems;
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
      drawerItems: resolvedDrawerItems,
      scrollable: scrollable,
      contentPadding: contentPadding,
      body: content,
    );
  }

  List<AppDrawerItem> _buildDefaultDrawerItems(
    BuildContext context, {
    required String title,
    VoidCallback? onSubscriptionTap,
  }) {
    final AppLocalizations l10n = context.l10n;

    return <AppDrawerItem>[
      AppDrawerItem(
        label: l10n.shellAboutApp,
        icon: Icons.info_outline_rounded,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: l10n.shellAboutTitle(title),
              description: l10n.shellAboutDescription,
            ),
      ),
      AppDrawerItem(
        label: l10n.shellSettingsConfig,
        icon: Icons.settings_outlined,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: l10n.shellSettingsTitle,
              description: l10n.shellSettingsDescription,
            ),
      ),
      AppDrawerItem(
        label: l10n.shellSubscriptionPlan,
        icon: Icons.workspace_premium_outlined,
        onTap:
            onSubscriptionTap ??
            () => _showPlaceholderSheet(
              context,
              title: l10n.shellSubscriptionPlan,
              description: l10n.shellSubscriptionDescription,
            ),
      ),
      AppDrawerItem(
        label: l10n.shellPrivacy,
        icon: Icons.privacy_tip_outlined,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: l10n.shellPrivacy,
              description: l10n.shellPrivacyDescription,
            ),
      ),
      AppDrawerItem(
        label: l10n.shellFeedback,
        icon: Icons.feedback_outlined,
        onTap:
            () => _showPlaceholderSheet(
              context,
              title: l10n.shellFeedback,
              description: l10n.shellFeedbackDescription,
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
