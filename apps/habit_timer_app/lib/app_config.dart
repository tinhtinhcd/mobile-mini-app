import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'src/presentation/habit_timer_app_screen.dart';

AppDefinition buildHabitTimerAppDefinition() {
  return AppDefinition(
    name: 'habit_timer_app',
    title: 'Habit Timer',
    accentColor: const Color(0xFFF59E0B),
    router: createAppRouter(
      builder: (BuildContext context, state) {
        return const HabitTimerAppScreen();
      },
    ),
  );
}
