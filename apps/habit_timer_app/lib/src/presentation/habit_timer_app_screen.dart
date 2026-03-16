import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class HabitTimerAppScreen extends StatelessWidget {
  const HabitTimerAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: 'Habit Timer',
      subtitle: 'A scaffolded placeholder app generated for future development.',
      body: const SectionCard(
        title: 'Status',
        subtitle: 'This app is scaffolded but not implemented yet.',
        child: EmptyState(
          title: 'Coming soon',
          message:
              'The initial shell for habit_timer_app is ready. Future work can add app-specific flows here.',
          icon: Icons.construction_rounded,
        ),
      ),
    );
  }
}
