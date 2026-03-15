import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pomodoro_app/app_config.dart';

void main() {
  runApp(const ProviderScope(child: PomodoroAppEntry()));
}

class PomodoroAppEntry extends StatelessWidget {
  const PomodoroAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildPomodoroAppDefinition());
  }
}

