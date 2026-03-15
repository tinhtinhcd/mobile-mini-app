import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

AppDefinition buildFastingAppDefinition() {
  return AppDefinition(
    name: 'fasting_app',
    title: 'Fasting App',
    accentColor: const Color(0xFF1D8A6B),
    router: createAppRouter(
      builder: (BuildContext context, _) {
        return const _FastingPlaceholderScreen();
      },
    ),
  );
}

class _FastingPlaceholderScreen extends StatelessWidget {
  const _FastingPlaceholderScreen();

  static const TimerSession _starterSession = TimerSession(
    id: 'fasting-preview',
    label: '16h fast',
    duration: Duration(hours: 16),
    isTracked: true,
  );

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Fasting Flow',
      subtitle: 'Phase 5 scaffold only. Shared timer infrastructure is ready for a future fasting experience.',
      body: SectionCard(
        title: 'Placeholder',
        subtitle: 'This app is intentionally minimal for now.',
        child: StatTile(
          label: 'Starter plan',
          value: _starterSession.label,
          detail: '${_starterSession.duration.inHours} hour preview session',
        ),
      ),
      action: const AppPrimaryButton(
        label: 'Coming soon',
      ),
    );
  }
}
