import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter({
  required Widget Function(BuildContext context, GoRouterState state) builder,
  List<RouteBase> routes = const <RouteBase>[],
  String initialLocation = '/',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: <RouteBase>[
      GoRoute(
        path: '/',
        name: 'home',
        builder: builder,
        routes: routes,
      ),
    ],
  );
}

