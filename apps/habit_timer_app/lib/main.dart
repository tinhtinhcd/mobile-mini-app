import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeneratedAppEntry());
}

class GeneratedAppEntry extends StatelessWidget {
  const GeneratedAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildHabitTimerAppDefinition());
  }
}
