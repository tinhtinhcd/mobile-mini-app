import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_app_menu.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_screen.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_weekly_summary_screen.dart';

AppDefinition buildPomodoroAppDefinition() {
  return AppDefinition(
    name: 'pomodoro_app',
    title: 'Pomodoro App',
    accentColor: const Color(0xFFE4572E),
    router: createAppRouter(
      builder: (BuildContext context, GoRouterState state) {
        return const PomodoroScreen();
      },
      routes: <RouteBase>[
        ...buildAppMenuRoutes(
          spec: pomodoroAppMenuSpec,
          premiumScreenBuilder: (BuildContext context) {
            return const PomodoroPremiumScreen();
          },
        ),
        GoRoute(
          path: pomodoroWeeklySummaryPath,
          name: pomodoroWeeklySummaryPath,
          builder: (BuildContext context, GoRouterState state) {
            return const PomodoroWeeklySummaryScreen();
          },
        ),
      ],
    ),
  );
}
