import 'package:app_core/src/scaffold/app_shell.dart';
import 'package:app_core/src/scaffold/factory_scaffold.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:localization/localization.dart';

const String appMenuAboutPath = 'about';
const String appMenuSettingsPath = 'settings';
const String appMenuPremiumPath = 'premium';
const String appMenuPrivacyPath = 'privacy';
const String appMenuFeedbackPath = 'feedback';

@immutable
class AppMenuSpec {
  const AppMenuSpec({
    required this.appTitle,
    required this.aboutDescription,
    required this.versionLabel,
    required this.privacyBody,
    required this.feedbackBody,
  });

  final String appTitle;
  final String aboutDescription;
  final String versionLabel;
  final String privacyBody;
  final String feedbackBody;
}

List<RouteBase> buildAppMenuRoutes({
  required AppMenuSpec spec,
  required WidgetBuilder premiumScreenBuilder,
}) {
  return <RouteBase>[
    GoRoute(
      path: appMenuAboutPath,
      name: appMenuAboutPath,
      builder: (BuildContext context, GoRouterState state) {
        return _AppAboutScreen(spec: spec);
      },
    ),
    GoRoute(
      path: appMenuSettingsPath,
      name: appMenuSettingsPath,
      builder: (BuildContext context, GoRouterState state) {
        return _AppSettingsScreen(spec: spec);
      },
    ),
    GoRoute(
      path: appMenuPremiumPath,
      name: appMenuPremiumPath,
      builder: (BuildContext context, GoRouterState state) {
        return premiumScreenBuilder(context);
      },
    ),
    GoRoute(
      path: appMenuPrivacyPath,
      name: appMenuPrivacyPath,
      builder: (BuildContext context, GoRouterState state) {
        return _AppPrivacyScreen(spec: spec);
      },
    ),
    GoRoute(
      path: appMenuFeedbackPath,
      name: appMenuFeedbackPath,
      builder: (BuildContext context, GoRouterState state) {
        return _AppFeedbackScreen(spec: spec);
      },
    ),
  ];
}

List<AppDrawerItem> buildAppMenuDrawerItems(
  BuildContext context, {
  required AppMenuSpec spec,
}) {
  final AppLocalizations l10n = context.l10n;

  return <AppDrawerItem>[
    AppDrawerItem(
      label: l10n.shellAboutApp,
      icon: Icons.info_outline_rounded,
      onTap: () => context.push('/$appMenuAboutPath'),
    ),
    AppDrawerItem(
      label: l10n.shellSettingsConfig,
      icon: Icons.settings_outlined,
      onTap: () => context.push('/$appMenuSettingsPath'),
    ),
    AppDrawerItem(
      label: l10n.shellSubscriptionPlan,
      icon: Icons.workspace_premium_outlined,
      onTap: () => context.push('/$appMenuPremiumPath'),
    ),
    AppDrawerItem(
      label: l10n.shellPrivacy,
      icon: Icons.privacy_tip_outlined,
      onTap: () => context.push('/$appMenuPrivacyPath'),
    ),
    AppDrawerItem(
      label: l10n.shellFeedback,
      icon: Icons.feedback_outlined,
      onTap: () => context.push('/$appMenuFeedbackPath'),
    ),
  ];
}

class _AppAboutScreen extends StatelessWidget {
  const _AppAboutScreen({required this.spec});

  final AppMenuSpec spec;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = context.l10n;
    final ThemeData theme = Theme.of(context);

    return FactoryScaffold(
      title: l10n.shellAboutApp,
      appMenuSpec: spec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            spec.appTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(spec.aboutDescription, style: theme.textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          _InfoTile(
            icon: Icons.verified_outlined,
            title: 'Version',
            subtitle: spec.versionLabel,
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoTile(
            icon: Icons.smartphone_rounded,
            title: 'Platform',
            subtitle: 'Shared mobile app shell powered by the monorepo.',
          ),
        ],
      ),
    );
  }
}

class _AppSettingsScreen extends StatelessWidget {
  const _AppSettingsScreen({required this.spec});

  final AppMenuSpec spec;

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: context.l10n.shellSettingsConfig,
      appMenuSpec: spec,
      body: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _InfoTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'Uses the current app localization and device locale.',
          ),
          SizedBox(height: AppSpacing.sm),
          _InfoTile(
            icon: Icons.notifications_none_rounded,
            title: 'Notifications',
            subtitle: 'Managed through in-app prompts and system settings.',
          ),
          SizedBox(height: AppSpacing.sm),
          _InfoTile(
            icon: Icons.tune_rounded,
            title: 'Configuration',
            subtitle: 'This screen is ready for future app-specific preferences.',
          ),
        ],
      ),
    );
  }
}

class _AppPrivacyScreen extends StatelessWidget {
  const _AppPrivacyScreen({required this.spec});

  final AppMenuSpec spec;

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: context.l10n.shellPrivacy,
      appMenuSpec: spec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            spec.privacyBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _InfoTile(
            icon: Icons.shield_outlined,
            title: 'Data handling',
            subtitle:
                'Future policy details can be added here without changing navigation.',
          ),
        ],
      ),
    );
  }
}

class _AppFeedbackScreen extends StatelessWidget {
  const _AppFeedbackScreen({required this.spec});

  final AppMenuSpec spec;

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: context.l10n.shellFeedback,
      appMenuSpec: spec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            spec.feedbackBody,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          const _InfoTile(
            icon: Icons.mail_outline_rounded,
            title: 'Support',
            subtitle:
                'Use this screen as the future entry point for contact and issue reporting.',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          theme.colorScheme.primary.withValues(alpha: 0.03),
          theme.colorScheme.surface,
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxs),
              child: Icon(icon, size: AppIconSize.large),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
