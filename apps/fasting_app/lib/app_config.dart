import 'package:app_core/app_core.dart';
import 'package:fasting_app/src/presentation/fasting_screen.dart';
import 'package:fasting_app/src/presentation/fasting_app_menu.dart';
import 'package:flutter/material.dart';

AppDefinition buildFastingAppDefinition() {
  return AppDefinition(
    name: 'fasting_app',
    title: 'Fasting Tracker',
    accentColor: const Color(0xFF1D8A6B),
    router: createAppRouter(
      builder: (BuildContext _, __) {
        return const FastingScreen();
      },
      routes: buildAppMenuRoutes(
        spec: fastingAppMenuSpec,
        premiumScreenBuilder: (BuildContext context) {
          return const FastingPremiumScreen();
        },
      ),
    ),
  );
}
