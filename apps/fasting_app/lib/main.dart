import 'package:app_core/app_core.dart';
import 'package:fasting_app/app_config.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FastingAppEntry());
}

class FastingAppEntry extends StatelessWidget {
  const FastingAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildFastingAppDefinition());
  }
}

