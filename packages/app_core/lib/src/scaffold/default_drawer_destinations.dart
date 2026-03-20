import 'package:flutter/material.dart';
import 'package:localization/localization.dart';

import 'app_drawer_destination.dart';

List<AppDrawerDestination> buildDefaultDrawerDestinations(
  BuildContext context, {
  required String appTitle,
  VoidCallback? onSubscriptionTap,
}) {
  final AppLocalizations l10n = context.l10n;

  return <AppDrawerDestination>[
    AppDrawerDestination.placeholder(
      label: l10n.shellAboutApp,
      icon: Icons.info_outline_rounded,
      placeholderBuilder:
          (_) => AppDrawerPlaceholderSpec(
            title: l10n.shellAboutTitle(appTitle),
            description: l10n.shellAboutDescription,
          ),
    ),
    AppDrawerDestination.placeholder(
      label: l10n.shellSettingsConfig,
      icon: Icons.settings_outlined,
      placeholderBuilder:
          (_) => AppDrawerPlaceholderSpec(
            title: l10n.shellSettingsTitle,
            description: l10n.shellSettingsDescription,
          ),
    ),
    if (onSubscriptionTap != null)
      AppDrawerDestination.action(
        label: l10n.shellSubscriptionPlan,
        icon: Icons.workspace_premium_outlined,
        onSelected: (_) => onSubscriptionTap(),
      )
    else
      AppDrawerDestination.placeholder(
        label: l10n.shellSubscriptionPlan,
        icon: Icons.workspace_premium_outlined,
        placeholderBuilder:
            (_) => AppDrawerPlaceholderSpec(
              title: l10n.shellSubscriptionPlan,
              description: l10n.shellSubscriptionDescription,
            ),
      ),
    AppDrawerDestination.placeholder(
      label: l10n.shellPrivacy,
      icon: Icons.privacy_tip_outlined,
      placeholderBuilder:
          (_) => AppDrawerPlaceholderSpec(
            title: l10n.shellPrivacy,
            description: l10n.shellPrivacyDescription,
          ),
    ),
    AppDrawerDestination.placeholder(
      label: l10n.shellFeedback,
      icon: Icons.feedback_outlined,
      placeholderBuilder:
          (_) => AppDrawerPlaceholderSpec(
            title: l10n.shellFeedback,
            description: l10n.shellFeedbackDescription,
          ),
    ),
  ];
}
