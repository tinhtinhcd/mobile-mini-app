import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monetization/monetization.dart';
import 'package:pomodoro_app/main.dart' as app;
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

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
      await tapFilledButton(tester, 'Start focus session');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Pause focus'), findsOneWidget);
      expect(notifications.scheduledIds, isNotEmpty);

      await tapFilledButton(tester, 'Pause focus');
      await tester.pump();
      expect(find.text('Resume focus'), findsOneWidget);
      expect(notifications.canceledIds, isNotEmpty);

      await tapOutlinedButton(tester, 'Reset');
      await tester.pump();
      expect(find.text('25:00'), findsOneWidget);

      await tapSelectionPill(tester, 'Short break');
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

        await tapFilledButton(tester, 'Resume focus');
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

      await openDrawer(tester);
      await tapDrawerItem(tester, 'Subscription Plan');
      await tester.pumpAndSettle();
      expect(find.text('View subscription options'), findsOneWidget);

      await tapFilledButton(tester, 'View subscription options');
      await tester.pumpAndSettle();
      expect(find.text('Upgrade Focus Flow'), findsOneWidget);

      await tapTextButton(tester, 'Maybe later');
      await tester.pumpAndSettle();
      expect(find.text('Upgrade Focus Flow'), findsNothing);
    });

    testWidgets('opens real drawer destinations', (WidgetTester tester) async {
      await tester.pumpWidget(
        app.createPomodoroApp(
          analyticsService: TestAnalyticsService(),
          notificationService: TestNotificationService(),
          monetizationService: TestMonetizationService(),
          adService: TestAdService(),
          snapshotStore: InMemoryTimerSnapshotStore(),
        ),
      );

      await pumpUntilVisible(tester, find.text('Focus Flow'));

      await openDrawer(tester);
      await tapDrawerItem(tester, 'About App');
      expect(find.text('Pomodoro App'), findsOneWidget);
      expect(find.text('Version'), findsOneWidget);
      await popRoute(tester);
      expect(find.text('Focus Flow'), findsOneWidget);

      await openDrawer(tester);
      await tapDrawerItem(tester, 'Settings / Config');
      expect(find.text('Configuration'), findsOneWidget);
      await popRoute(tester);
      expect(find.text('Focus Flow'), findsOneWidget);

      await openDrawer(tester);
      await tapDrawerItem(tester, 'Subscription Plan');
      expect(find.text('View subscription options'), findsOneWidget);
      await popRoute(tester);
      expect(find.text('Focus Flow'), findsOneWidget);

      await openDrawer(tester);
      await tapDrawerItem(tester, 'Privacy');
      expect(find.text('Data handling'), findsOneWidget);
      await popRoute(tester);
      expect(find.text('Focus Flow'), findsOneWidget);

      await openDrawer(tester);
      await tapDrawerItem(tester, 'Feedback');
      expect(find.text('Support'), findsOneWidget);
      await popRoute(tester);
      expect(find.text('Focus Flow'), findsOneWidget);
    });
  });
}

Future<void> tapFilledButton(WidgetTester tester, String label) async {
  final Finder button = find.widgetWithText(FilledButton, label);
  expect(button, findsOneWidget);
  tester.widget<FilledButton>(button).onPressed!.call();
  await tester.pump();
}

Future<void> tapOutlinedButton(WidgetTester tester, String label) async {
  final Finder button = find.widgetWithText(OutlinedButton, label);
  expect(button, findsOneWidget);
  tester.widget<OutlinedButton>(button).onPressed!.call();
  await tester.pump();
}

Future<void> tapTextButton(WidgetTester tester, String label) async {
  final Finder button = find.widgetWithText(TextButton, label);
  expect(button, findsOneWidget);
  tester.widget<TextButton>(button).onPressed!.call();
  await tester.pump();
}

Future<void> tapSelectionPill(WidgetTester tester, String label) async {
  final Finder pill = find.ancestor(
    of: find.text(label),
    matching: find.byType(SelectionPill),
  );
  expect(pill, findsOneWidget);
  tester.widget<SelectionPill>(pill).onTap();
  await tester.pump();
}

Future<void> openDrawer(WidgetTester tester) async {
  final Finder menuButton = find.byIcon(Icons.menu_rounded);
  expect(menuButton, findsWidgets);
  await tester.tap(menuButton.first);
  await tester.pumpAndSettle();
}

Future<void> tapDrawerItem(WidgetTester tester, String label) async {
  final Finder item = find.text(label);
  expect(item, findsWidgets);
  await tester.tap(item.last);
  await tester.pumpAndSettle();
}

Future<void> popRoute(WidgetTester tester) async {
  final NavigatorState navigator = tester.state<NavigatorState>(
    find.byType(Navigator).first,
  );
  navigator.pop();
  await tester.pumpAndSettle();
}
