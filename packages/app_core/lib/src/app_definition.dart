import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

@immutable
class AppDefinition {
  const AppDefinition({
    required this.name,
    required this.title,
    required this.accentColor,
    required this.router,
    this.themeMode = ThemeMode.light,
  });

  final String name;
  final String title;
  final Color accentColor;
  final GoRouter router;
  final ThemeMode themeMode;
}

