import 'package:app_core/app_core.dart';
import 'package:analytics/analytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
import 'package:notifications/notifications.dart';
import 'package:pomodoro_app/app_config.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final DebugLoggerAnalyticsService analyticsService =
      DebugLoggerAnalyticsService();
  await analyticsService.initialize();

  final NotificationService notificationService = NotificationService(
    defaultChannel: const NotificationChannel(
      id: 'pomodoro_timers',
      name: 'Pomodoro Timers',
      description: 'Session completion alerts for Pomodoro cycles.',
    ),
  );
  await notificationService.initialize();
  await notificationService.requestPermission();

  final StoreMonetizationService monetizationService =
      StoreMonetizationService(
        productIds: const <String>[
          pomodoroMonthlyProductId,
          pomodoroYearlyProductId,
        ],
        entitlementCacheKey: pomodoroEntitlementCacheKey,
      );
  await monetizationService.initialize();

  final GoogleMobileAdsService adService = GoogleMobileAdsService();
  await adService.initialize();

  final SharedPreferencesTimerSnapshotStore snapshotStore =
      await SharedPreferencesTimerSnapshotStore.create(
    storageKey: 'pomodoro_app.timer_snapshot',
  );
  final restoredSnapshot = await snapshotStore.readSnapshot();

  runApp(
    ProviderScope(
      overrides: [
        pomodoroAnalyticsServiceProvider.overrideWith((_) => analyticsService),
        pomodoroMonetizationServiceProvider.overrideWith(
          (_) => monetizationService,
        ),
        pomodoroAdServiceProvider.overrideWith((_) => adService),
        pomodoroNotificationServiceProvider.overrideWith(
          (_) => notificationService,
        ),
        pomodoroSnapshotStoreProvider.overrideWith((_) => snapshotStore),
        pomodoroRestoredSnapshotProvider.overrideWith((_) => restoredSnapshot),
      ],
      child: const PomodoroAppEntry(),
    ),
  );
}

class PomodoroAppEntry extends StatelessWidget {
  const PomodoroAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildPomodoroAppDefinition());
  }
}
