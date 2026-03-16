import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:analytics/analytics.dart';
import 'package:fasting_app/app_config.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
import 'package:notifications/notifications.dart';
import 'package:storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final DebugLoggerAnalyticsService analyticsService =
      DebugLoggerAnalyticsService();
  await analyticsService.initialize();

  final NotificationService notificationService = NotificationService(
    defaultChannel: const NotificationChannel(
      id: 'fasting_timers',
      name: 'Fasting Timers',
      description: 'Completion alerts for fasting sessions.',
    ),
  );

  final StoreMonetizationService monetizationService =
      StoreMonetizationService(
        productIds: const <String>[
          fastingMonthlyProductId,
          fastingYearlyProductId,
        ],
        entitlementCacheKey: fastingEntitlementCacheKey,
      );
  await monetizationService.initialize();

  FastingMonetizationAnalyticsBinding(
    service: monetizationService,
    analytics: analyticsService,
  ).attach();

  final GoogleMobileAdsService adService = GoogleMobileAdsService();

  final SharedPreferencesTimerSnapshotStore snapshotStore =
      await SharedPreferencesTimerSnapshotStore.create(
    storageKey: 'fasting_app.timer_snapshot',
  );
  final restoredSnapshot = await snapshotStore.readSnapshot();

  runApp(
    ProviderScope(
      overrides: [
        fastingAnalyticsServiceProvider.overrideWith((_) => analyticsService),
        fastingMonetizationServiceProvider.overrideWith(
          (_) => monetizationService,
        ),
        fastingAdServiceProvider.overrideWith((_) => adService),
        fastingNotificationServiceProvider.overrideWith(
          (_) => notificationService,
        ),
        fastingSnapshotStoreProvider.overrideWith((_) => snapshotStore),
        fastingRestoredSnapshotProvider.overrideWith((_) => restoredSnapshot),
      ],
      child: const FastingAppEntry(),
    ),
  );

  unawaited(notificationService.requestPermission());
  unawaited(monetizationService.initialize());
  unawaited(adService.initialize());
}

class FastingAppEntry extends StatelessWidget {
  const FastingAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildFastingAppDefinition());
  }
}
