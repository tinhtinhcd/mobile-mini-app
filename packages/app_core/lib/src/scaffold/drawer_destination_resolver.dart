import 'package:flutter/material.dart';

import '../navigation/app_menu.dart';
import 'app_drawer_destination.dart';
import 'default_drawer_destinations.dart';

List<AppDrawerDestination> resolveDrawerDestinations(
  BuildContext context, {
  required List<AppDrawerDestination> drawerDestinations,
  required String appTitle,
  required AppMenuSpec? appMenuSpec,
  VoidCallback? onSubscriptionTap,
}) {
  if (drawerDestinations.isNotEmpty) {
    return drawerDestinations;
  }

  if (appMenuSpec != null) {
    return buildAppMenuDrawerDestinations(context);
  }

  return buildDefaultDrawerDestinations(
    context,
    appTitle: appTitle,
    onSubscriptionTap: onSubscriptionTap,
  );
}
