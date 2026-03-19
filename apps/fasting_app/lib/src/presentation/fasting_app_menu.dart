import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ui_kit/ui_kit.dart';

const AppMenuSpec fastingAppMenuSpec = AppMenuSpec(
  appTitle: 'Fasting Tracker',
  aboutDescription:
      'A clean fasting utility focused on consistent plans, progress, and calm daily tracking.',
  versionLabel: '0.1.0 placeholder',
  privacyBody:
      'Fasting Tracker keeps privacy guidance simple for now. This screen is ready for the full policy when it is available.',
  feedbackBody:
      'Use this screen as the future home for support, bug reports, and fasting flow feedback.',
);

class FastingPremiumScreen extends ConsumerWidget {
  const FastingPremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FactoryScaffold(
      title: context.l10n.shellSubscriptionPlan,
      appMenuSpec: fastingAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            fastingPaywallContent.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...fastingPaywallContent.benefits.map(
            (String benefit) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(Icons.check_circle_rounded, size: 18),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: Text(benefit)),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            fastingPaywallContent.freeTierNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'View subscription options',
            onPressed:
                () => openFastingPaywall(
                  context: context,
                  ref: ref,
                  entryPoint: fastingHeaderButtonEntryPoint,
                ),
          ),
        ],
      ),
    );
  }
}
