import 'package:fasting_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:monetization/monetization.dart';
import 'package:timer_engine/timer_engine.dart';
import 'package:ui_kit/ui_kit.dart';

import 'support/test_services.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('fasting_app', () {
    testWidgets('launches and renders the first screen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        app.createFastingApp(
          analyticsService: TestAnalyticsService(),
          notificationService: TestNotificationService(),
          monetizationService: TestMonetizationService(
            initialEntitlement: const EntitlementState(
              isPremium: true,
              storeAvailable: true,
              isProcessing: false,
              ownedProductIds: <String>{'fasting_premium_monthly'},
              source: EntitlementSource.storePurchase,
            ),
          ),
          adService: TestAdService(),
          snapshotStore: InMemoryTimerSnapshotStore(),
        ),
      );

      await pumpUntilVisible(tester, find.text('Fasting Flow'));
      expect(find.text('Current fast'), findsOneWidget);
      expect(find.text('Start fast'), findsOneWidget);
    });

    testWidgets('supports start pause reset and plan switching', (
      WidgetTester tester,
    ) async {
      final TestNotificationService notifications = TestNotificationService();
      await tester.pumpWidget(
        app.createFastingApp(
          analyticsService: TestAnalyticsService(),
          notificationService: notifications,
          monetizationService: TestMonetizationService(
            initialEntitlement: const EntitlementState(
              isPremium: true,
              storeAvailable: true,
              isProcessing: false,
              ownedProductIds: <String>{'fasting_premium_monthly'},
              source: EntitlementSource.storePurchase,
            ),
          ),
          adService: TestAdService(),
          snapshotStore: InMemoryTimerSnapshotStore(),
        ),
      );

      await pumpUntilVisible(tester, find.text('Fasting Flow'));
      await tapFilledButton(tester, 'Start fast');
      await tester.pump(const Duration(seconds: 1));
      expect(find.text('Pause fast'), findsOneWidget);
      expect(notifications.scheduledIds, isNotEmpty);

      await tapFilledButton(tester, 'Pause fast');
      await tester.pump();
      expect(find.text('Resume fast'), findsOneWidget);
      expect(notifications.canceledIds, isNotEmpty);

      await tapOutlinedButton(tester, 'Reset fast');
      await tester.pump();
      expect(find.text('16:00:00'), findsOneWidget);

      await tapSelectionPill(tester, '12:12');
      await tester.pump();
      expect(find.text('12:00:00'), findsOneWidget);
      expect(find.text('Start fast'), findsOneWidget);
    });

    testWidgets('restores safely and completes a near-finished fast', (
      WidgetTester tester,
    ) async {
      final InMemoryTimerSnapshotStore snapshotStore =
          InMemoryTimerSnapshotStore(
            snapshot: const TimerSnapshot(
              sessionId: '16_8',
              remainingSeconds: 1,
              wasRunning: true,
              completedTrackedSessions: 0,
              trackedMinutes: 0,
            ),
          );

      await tester.pumpWidget(
        app.createFastingApp(
          analyticsService: TestAnalyticsService(),
          notificationService: TestNotificationService(),
          monetizationService: TestMonetizationService(
            initialEntitlement: const EntitlementState(
              isPremium: true,
              storeAvailable: true,
              isProcessing: false,
              ownedProductIds: <String>{'fasting_premium_monthly'},
              source: EntitlementSource.storePurchase,
            ),
          ),
          adService: TestAdService(),
          snapshotStore: snapshotStore,
        ),
      );

      await pumpUntilVisible(tester, find.text('00:00:01'));
      expect(find.text('Resume fast'), findsOneWidget);

      await tapFilledButton(tester, 'Resume fast');
      await tester.pump(const Duration(milliseconds: 1200));
      expect(find.text('16:00:00'), findsOneWidget);
      expect(
        find.byWidgetPredicate((widget) {
          return widget is RichText &&
              widget.text.toPlainText().contains('completed fasts');
        }),
        findsOneWidget,
      );
    });

    testWidgets(
      'keeps free core flow usable and opens the paywall for locked plans',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          app.createFastingApp(
            analyticsService: TestAnalyticsService(),
            notificationService: TestNotificationService(),
            monetizationService: TestMonetizationService(),
            adService: TestAdService(),
            snapshotStore: InMemoryTimerSnapshotStore(
              snapshot: const TimerSnapshot(
                sessionId: '16_8',
                remainingSeconds: -20,
                wasRunning: true,
                completedTrackedSessions: 1,
                trackedMinutes: 960,
              ),
            ),
          ),
        );

        await pumpUntilVisible(tester, find.text('Fasting Flow'));
        expect(find.text('16:00:00'), findsOneWidget);
        expect(find.text('Start fast'), findsOneWidget);

        await tapSelectionPill(tester, '18:6');
        await tester.pumpAndSettle();
        expect(find.text('Upgrade Fasting Flow'), findsOneWidget);

        await tapTextButton(tester, 'Maybe later');
        await tester.pumpAndSettle();
        expect(find.text('Upgrade Fasting Flow'), findsNothing);
      },
    );
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
