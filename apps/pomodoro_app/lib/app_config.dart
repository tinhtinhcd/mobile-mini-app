import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:pomodoro_app/src/presentation/pomodoro_screen.dart';

AppDefinition buildPomodoroAppDefinition() {
  return AppDefinition(
    name: 'pomodoro_app',
    title: 'Pomodoro App',
    accentColor: const Color(0xFFE4572E),
    router: createAppRouter(
      builder: (BuildContext context, _) {
        return const PomodoroScreen();
      },
    ),
  );
}
