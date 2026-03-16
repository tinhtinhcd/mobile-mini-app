import 'dart:async';

import 'package:app_core/app_core.dart';
import 'package:analytics/analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:monetization/monetization.dart';
import 'package:notifications/notifications.dart';
import 'package:pomodoro_app/app_config.dart';
import 'package:pomodoro_app/src/application/pomodoro_analytics.dart';
import 'package:pomodoro_app/src/application/pomodoro_controller.dart';
import 'package:pomodoro_app/src/application/pomodoro_monetization.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(createPomodoroApp());
}

Widget createPomodoroApp({
  AnalyticsService? analyticsService,
  NotificationService? notificationService,
  StoreMonetizationService? monetizationService,
  AdService? adService,
  TimerSnapshotStore? snapshotStore,
}) {
  return _PomodoroBootstrap(
    analyticsService: analyticsService ?? DebugLoggerAnalyticsService(),
    notificationService:
        notificationService ??
        NotificationService(
          defaultChannel: const NotificationChannel(
            id: 'pomodoro_timers',
            name: 'Pomodoro Timers',
            description: 'Session completion alerts for Pomodoro cycles.',
          ),
        ),
    monetizationService:
        monetizationService ??
        StoreMonetizationService(
          productIds: const <String>[
            pomodoroMonthlyProductId,
            pomodoroYearlyProductId,
          ],
          entitlementCacheKey: pomodoroEntitlementCacheKey,
        ),
    adService: adService ?? GoogleMobileAdsService(),
    snapshotStore:
        snapshotStore ??
        _DeferredTimerSnapshotStore(storageKey: 'pomodoro_app.timer_snapshot'),
  );
}

class _PomodoroBootstrap extends StatefulWidget {
  const _PomodoroBootstrap({
    required this.analyticsService,
    required this.notificationService,
    required this.monetizationService,
    required this.adService,
    required this.snapshotStore,
  });

  final AnalyticsService analyticsService;
  final NotificationService notificationService;
  final StoreMonetizationService monetizationService;
  final AdService adService;
  final TimerSnapshotStore snapshotStore;

  @override
  State<_PomodoroBootstrap> createState() => _PomodoroBootstrapState();
}

class _PomodoroBootstrapState extends State<_PomodoroBootstrap> {
  TimerSnapshot? _restoredSnapshot;
  bool _bootstrapReady = false;
  late final PomodoroMonetizationAnalyticsBinding _analyticsBinding =
      PomodoroMonetizationAnalyticsBinding(
        service: widget.monetizationService,
        analytics: widget.analyticsService,
      );

  @override
  void initState() {
    super.initState();
    _analyticsBinding.attach();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_bootstrapAsync());
    });
  }

  @override
  void dispose() {
    _analyticsBinding.detach();
    super.dispose();
  }

  Future<void> _bootstrapAsync() async {
    try {
      await widget.analyticsService.initialize();
    } catch (_) {}

    try {
      final TimerSnapshot? snapshot = await widget.snapshotStore.readSnapshot();
      if (mounted) {
        setState(() {
          _restoredSnapshot = snapshot;
          _bootstrapReady = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _bootstrapReady = true;
        });
      }
    }

    if (kDebugMode) {
      return;
    }

    try {
      await widget.monetizationService.initialize();
    } catch (_) {}

    try {
      await widget.adService.initialize();
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      key: ValueKey<String>(
        _bootstrapReady
            ? 'ready:${_restoredSnapshot?.sessionId ?? 'none'}'
            : 'booting',
      ),
      overrides: [
        pomodoroAnalyticsServiceProvider.overrideWith((_) {
          return widget.analyticsService;
        }),
        pomodoroMonetizationServiceProvider.overrideWith((_) {
          return widget.monetizationService;
        }),
        pomodoroAdServiceProvider.overrideWith((_) => widget.adService),
        pomodoroNotificationServiceProvider.overrideWith((_) {
          return widget.notificationService;
        }),
        pomodoroSnapshotStoreProvider.overrideWith((_) => widget.snapshotStore),
        pomodoroRestoredSnapshotProvider.overrideWith((_) {
          return _restoredSnapshot;
        }),
      ],
      child: const PomodoroAppEntry(),
    );
  }
}

class PomodoroAppEntry extends StatelessWidget {
  const PomodoroAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildPomodoroAppDefinition());
  }
}

class _DeferredTimerSnapshotStore implements TimerSnapshotStore {
  _DeferredTimerSnapshotStore({required this.storageKey});

  final String storageKey;

  SharedPreferencesTimerSnapshotStore? _delegate;
  Future<SharedPreferencesTimerSnapshotStore>? _delegateFuture;
  TimerSnapshot? _pendingSnapshot;
  bool _pendingClear = false;

  Future<SharedPreferencesTimerSnapshotStore> initialize() {
    final SharedPreferencesTimerSnapshotStore? delegate = _delegate;
    if (delegate != null) {
      return Future<SharedPreferencesTimerSnapshotStore>.value(delegate);
    }

    return _delegateFuture ??= _createDelegate();
  }

  Future<SharedPreferencesTimerSnapshotStore> _createDelegate() async {
    final SharedPreferencesTimerSnapshotStore delegate =
        await SharedPreferencesTimerSnapshotStore.create(
          storageKey: storageKey,
        );
    _delegate = delegate;

    if (_pendingClear) {
      _pendingClear = false;
      _pendingSnapshot = null;
      await delegate.clearSnapshot();
      return delegate;
    }

    final TimerSnapshot? pendingSnapshot = _pendingSnapshot;
    if (pendingSnapshot != null) {
      _pendingSnapshot = null;
      await delegate.writeSnapshot(pendingSnapshot);
    }

    return delegate;
  }

  @override
  Future<TimerSnapshot?> readSnapshot() async {
    final SharedPreferencesTimerSnapshotStore delegate = await initialize();
    return delegate.readSnapshot();
  }

  @override
  Future<void> writeSnapshot(TimerSnapshot snapshot) async {
    final SharedPreferencesTimerSnapshotStore? delegate = _delegate;
    if (delegate != null) {
      await delegate.writeSnapshot(snapshot);
      return;
    }

    _pendingClear = false;
    _pendingSnapshot = snapshot;
    unawaited(initialize());
  }

  @override
  Future<void> clearSnapshot() async {
    final SharedPreferencesTimerSnapshotStore? delegate = _delegate;
    if (delegate != null) {
      await delegate.clearSnapshot();
      return;
    }

    _pendingClear = true;
    _pendingSnapshot = null;
    unawaited(initialize());
  }
}
