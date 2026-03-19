import 'package:app_core/src/scaffold/app_shell.dart';
import 'package:app_core/src/scaffold/factory_scaffold.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    this.requestNotificationPermission,
  });

  final String appTitle;
  final String aboutDescription;
  final String versionLabel;
  final String privacyBody;
  final String feedbackBody;
  final Future<bool> Function(BuildContext context)?
  requestNotificationPermission;
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
      onTap: () => context.go('/$appMenuAboutPath'),
    ),
    AppDrawerItem(
      label: l10n.shellSettingsConfig,
      icon: Icons.settings_outlined,
      onTap: () => context.go('/$appMenuSettingsPath'),
    ),
    AppDrawerItem(
      label: l10n.shellSubscriptionPlan,
      icon: Icons.workspace_premium_outlined,
      onTap: () => context.go('/$appMenuPremiumPath'),
    ),
    AppDrawerItem(
      label: l10n.shellPrivacy,
      icon: Icons.privacy_tip_outlined,
      onTap: () => context.go('/$appMenuPrivacyPath'),
    ),
    AppDrawerItem(
      label: l10n.shellFeedback,
      icon: Icons.feedback_outlined,
      onTap: () => context.go('/$appMenuFeedbackPath'),
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
          const _InfoTile(
            icon: Icons.smartphone_rounded,
            title: 'Platform',
            subtitle: 'Shared mobile app shell powered by the monorepo.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ActionTile(
            icon: Icons.copy_all_rounded,
            title: 'Copy app details',
            subtitle: 'Copy app name, version, and summary for support or QA.',
            onTap:
                () => _copyText(
                  context,
                  value:
                      '${spec.appTitle}\nVersion: ${spec.versionLabel}\n${spec.aboutDescription}',
                  successMessage: 'App details copied',
                ),
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ActionTile(
            icon: Icons.notifications_active_outlined,
            title: 'Enable notifications',
            subtitle:
                'Request notification permission so timers can alert on completion.',
            onTap:
                spec.requestNotificationPermission == null
                    ? null
                    : () async {
                      final bool granted = await spec
                          .requestNotificationPermission!(context);
                      if (!context.mounted) {
                        return;
                      }
                      _showSnackBar(
                        context,
                        granted
                            ? 'Notifications enabled'
                            : 'Notifications not enabled',
                      );
                    },
          ),
          const SizedBox(height: AppSpacing.sm),
          const _InfoTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'Uses the current app localization and device locale.',
          ),
          const SizedBox(height: AppSpacing.sm),
          const _InfoTile(
            icon: Icons.tune_rounded,
            title: 'Configuration',
            subtitle:
                'Shared shell settings are active. App-specific preferences can be added here next.',
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
          Text(spec.privacyBody, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: AppSpacing.lg),
          const _InfoTile(
            icon: Icons.shield_outlined,
            title: 'Data handling',
            subtitle:
                'Core privacy guidance is available here without changing the app flow.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ActionTile(
            icon: Icons.copy_all_rounded,
            title: 'Copy privacy summary',
            subtitle: 'Copy the current privacy text for review or sharing.',
            onTap:
                () => _copyText(
                  context,
                  value: spec.privacyBody,
                  successMessage: 'Privacy summary copied',
                ),
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
    final String template =
        'App: ${spec.appTitle}\nVersion: ${spec.versionLabel}\n\nFeedback:\n- What happened:\n- Expected:\n- Steps to reproduce:\n';

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
                'Use the actions below to copy a clean feedback template for bug reports or support requests.',
          ),
          const SizedBox(height: AppSpacing.lg),
          _ActionTile(
            icon: Icons.copy_rounded,
            title: 'Copy feedback template',
            subtitle:
                'Copy a structured template with app and version details.',
            onTap:
                () => _copyText(
                  context,
                  value: template,
                  successMessage: 'Feedback template copied',
                ),
          ),
          const SizedBox(height: AppSpacing.sm),
          _ActionTile(
            icon: Icons.bug_report_outlined,
            title: 'Copy debug summary',
            subtitle:
                'Copy app identity and feedback notes for quick issue reporting.',
            onTap:
                () => _copyText(
                  context,
                  value:
                      '${spec.appTitle}\nVersion: ${spec.versionLabel}\n${spec.feedbackBody}',
                  successMessage: 'Debug summary copied',
                ),
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Future<void> Function()? onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Material(
      color: Color.alphaBlend(
        theme.colorScheme.primary.withValues(alpha: 0.03),
        theme.colorScheme.surface,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.medium),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap == null ? null : () => onTap!(),
        borderRadius: BorderRadius.circular(AppRadius.medium),
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
              const SizedBox(width: AppSpacing.sm),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.primary.withValues(alpha: 0.72),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<void> _copyText(
  BuildContext context, {
  required String value,
  required String successMessage,
}) async {
  await Clipboard.setData(ClipboardData(text: value));
  if (!context.mounted) {
    return;
  }
  _showSnackBar(context, successMessage);
}

void _showSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(message)));
}
