import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:ui_kit/ui_kit.dart';

const AppMenuSpec pomodoroAppMenuSpec = AppMenuSpec(
  appTitle: 'Pomodoro App',
  aboutDescription:
      'A calm focus timer built on the shared mobile app shell and timer engine.',
  versionLabel: '0.1.0 placeholder',
  privacyBody:
      'Pomodoro App keeps privacy guidance lightweight for now. Add the full policy here when the legal copy is ready.',
  feedbackBody:
      'Share focus flow feedback or support needs here. This screen is ready to connect to email or issue reporting later.',
);

class PomodoroPremiumScreen extends ConsumerWidget {
  const PomodoroPremiumScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FactoryScaffold(
      title: context.l10n.shellSubscriptionPlan,
      appMenuSpec: pomodoroAppMenuSpec,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            pomodoroPaywallContent.subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSpacing.lg),
          ...pomodoroPaywallContent.benefits.map(
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
            pomodoroPaywallContent.freeTierNote,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.lg),
          AppPrimaryButton(
            label: 'View subscription options',
            onPressed:
                () => openPomodoroPaywall(
                  context: context,
                  ref: ref,
                  entryPoint: pomodoroHeaderButtonEntryPoint,
                ),
          ),
        ],
      ),
    );
  }
}
