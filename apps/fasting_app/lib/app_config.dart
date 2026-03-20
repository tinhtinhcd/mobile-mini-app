import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/presentation/fasting_screen.dart';
import 'package:fasting_app/src/presentation/fasting_app_menu.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:fasting_app/src/presentation/fasting_weekly_summary_screen.dart';

AppDefinition buildFastingAppDefinition() {
  return AppDefinition(
    name: 'fasting_app',
    title: 'Fasting Tracker',
    accentColor: const Color(0xFF1D8A6B),
    router: createAppRouter(
      builder: (BuildContext context, GoRouterState state) {
        return const FastingScreen();
      },
      routes: <RouteBase>[
        ...buildAppMenuRoutes(
          spec: fastingAppMenuSpec,
          premiumScreenBuilder: (BuildContext context) {
            return const FastingPremiumScreen();
          },
        ),
        GoRoute(
          path: fastingWeeklySummaryPath,
          name: fastingWeeklySummaryPath,
          builder: (BuildContext context, GoRouterState state) {
            return const FastingWeeklySummaryScreen();
          },
        ),
      ],
    ),
  );
}
