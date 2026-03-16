import 'package:app_core/src/app_definition.dart';
import 'package:app_core/src/theme/app_theme.dart';
import 'package:flutter/material.dart';

class FactoryApp extends StatelessWidget {
  const FactoryApp({
    super.key,
    required this.definition,
  });

  final AppDefinition definition;

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: definition.title,
      debugShowCheckedModeBanner: false,
      themeMode: definition.themeMode,
      theme: AppTheme.light(definition.accentColor),
      darkTheme: AppTheme.dark(definition.accentColor),
      routerConfig: definition.router,
    );
  }
}
