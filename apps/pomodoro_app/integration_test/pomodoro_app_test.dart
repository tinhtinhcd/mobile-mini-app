import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monetization/monetization.dart';
import 'package:pomodoro_app/main.dart' as app;
import 'package:timer_engine/timer_engine.dart';

import 'support/test_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('pomodoro_app', () {
    testWidgets('launches and renders the first screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app.createPomodoroApp(
          analyticsService: TestAnalyticsService(),
          notificationService: TestNotificationService(),
          monetizationService: TestMonetizationService(
            initialEntitlement: const EntitlementState(
              isPremium: true,
              storeAvailable: true,
              isProcessing: false,
              ownedProductIds: <String>{'pomodoro_premium_monthly'},
              source: EntitlementSource.storePurchase,
            ),
          ),
          adService: TestAdService(),
          snapshotStore: InMemoryTimerSnapshotStore(),
        ),
      );

      await pumpUntilVisible(tester, find.text('Focus Flow'));
      expect(find.text('Current cycle'), findsOneWidget);
      expect(find.text('Start focus session'), findsOneWidget);
    });

    testWidgets('supports start pause reset and mode switching', (
      WidgetTester tester,
    ) async {
      final TestNotificationService notifications = TestNotificationService();
      await tester.pumpWidget(
        app.createPomodoroApp(
          analyticsService: TestAnalyticsService(),
          notificationService: notifications,
          monetizationService: TestMonetizationService(
            initialEntitlement: const EntitlementState(
              isPremium: true,
              storeAvailable: true,
              isProcessing: false,
              ownedProductIds: <String>{'pomodoro_premium_monthly'},
              source: EntitlementSource.storePurchase,
            ),
          ),
          adService: TestAdService(),
          snapshotStore: InMemoryTimerSnapshotStore(),
        ),
      );

      await pumpUntilVisible(tester, find.text('Focus Flow'));
      await tester.ensureVisible(find.text('Start focus session'));
      await tester.tap(find.text('Start focus session'));
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Pause focus'), findsOneWidget);
      expect(notifications.scheduledIds, isNotEmpty);

      await tester.tap(find.text('Pause focus'));
      await tester.pump();
      expect(find.text('Resume focus'), findsOneWidget);
      expect(notifications.canceledIds, isNotEmpty);

      await tester.ensureVisible(find.text('Reset'));
      await tester.tap(find.text('Reset'));
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);

      await tester.ensureVisible(find.text('Short break'));
      await tester.tap(find.text('Short break'));
      await tester.pump();
      expect(find.text('05:00'), findsOneWidget);
      expect(find.text('Start break'), findsOneWidget);
    });

    testWidgets(
      'restores snapshots safely and completes a near-finished session',
      (WidgetTester tester) async {
        final InMemoryTimerSnapshotStore snapshotStore =
            InMemoryTimerSnapshotStore(
              snapshot: const TimerSnapshot(
                sessionId: 'focus',
                remainingSeconds: 1,
                wasRunning: true,
                completedTrackedSessions: 0,
                trackedMinutes: 0,
              ),
            );

        await tester.pumpWidget(
          app.createPomodoroApp(
            analyticsService: TestAnalyticsService(),
            notificationService: TestNotificationService(),
            monetizationService: TestMonetizationService(
              initialEntitlement: const EntitlementState(
                isPremium: true,
                storeAvailable: true,
                isProcessing: false,
                ownedProductIds: <String>{'pomodoro_premium_monthly'},
                source: EntitlementSource.storePurchase,
              ),
            ),
            adService: TestAdService(),
            snapshotStore: snapshotStore,
          ),
        );

        await pumpUntilVisible(tester, find.text('00:01'));
        expect(find.text('Resume focus'), findsOneWidget);

        await tester.ensureVisible(find.text('Resume focus'));
        await tester.tap(find.text('Resume focus'));
        await tester.pump(const Duration(milliseconds: 1200));
        expect(find.text('Short break'), findsWidgets);
        expect(find.text('Start break'), findsOneWidget);
      },
    );

    testWidgets('handles invalid restore state and keeps paywall usable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app.createPomodoroApp(
          analyticsService: TestAnalyticsService(),
          notificationService: TestNotificationService(),
          monetizationService: TestMonetizationService(),
          adService: TestAdService(),
          snapshotStore: InMemoryTimerSnapshotStore(
            snapshot: const TimerSnapshot(
              sessionId: 'focus',
              remainingSeconds: -10,
              wasRunning: true,
              completedTrackedSessions: 2,
              trackedMinutes: 50,
            ),
          ),
        ),
      );

      await pumpUntilVisible(tester, find.text('Focus Flow'));
      expect(find.text('25:00'), findsOneWidget);
      expect(find.text('Start focus session'), findsOneWidget);

      await tester.tap(find.text('Upgrade'));
      await tester.pumpAndSettle();
      expect(find.text('Upgrade Focus Flow'), findsOneWidget);

      await tester.ensureVisible(find.text('Maybe later'));
      await tester.tap(find.text('Maybe later'));
      await tester.pumpAndSettle();
      expect(find.text('Upgrade Focus Flow'), findsNothing);
    });
  });
}
