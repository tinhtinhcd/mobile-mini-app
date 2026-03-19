import 'dart:async';

import 'package:analytics/analytics.dart';
import 'package:app_core/app_core.dart';
import 'package:fasting_app/app_config.dart';
import 'package:fasting_app/src/application/fasting_analytics.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:fasting_app/src/application/fasting_habits.dart';
import 'package:fasting_app/src/application/fasting_monetization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit_engine/habit_engine.dart';
import 'package:monetization/monetization.dart';
import 'package:notifications/notifications.dart';
import 'package:storage/storage.dart';
import 'package:timer_engine/timer_engine.dart';

void main() {
  final StartupTiming startupTiming = StartupTiming.forApp('fasting_app');
  startupTiming.mark('app_start');
  WidgetsFlutterBinding.ensureInitialized();
  startupTiming.mark('run_app');
  runApp(createFastingApp());
  startupTiming.mark('run_app_done');
}

Widget createFastingApp({
  AnalyticsService? analyticsService,
  NotificationService? notificationService,
  StoreMonetizationService? monetizationService,
  AdService? adService,
  TimerSnapshotStore? snapshotStore,
  HabitService? habitService,
}) {
  return _FastingBootstrap(
    analyticsService: analyticsService ?? DebugLoggerAnalyticsService(),
    notificationService:
        notificationService ??
        NotificationService(
          defaultChannel: const NotificationChannel(
            id: 'fasting_timers',
            name: 'Fasting Timers',
            description: 'Completion alerts for fasting sessions.',
          ),
        ),
    monetizationService:
        monetizationService ??
        StoreMonetizationService(
          productIds: const <String>[
            fastingMonthlyProductId,
            fastingYearlyProductId,
          ],
          entitlementCacheKey: fastingEntitlementCacheKey,
        ),
    adService: adService ?? GoogleMobileAdsService(),
    snapshotStore:
        snapshotStore ??
        _DeferredTimerSnapshotStore(storageKey: 'fasting_app.timer_snapshot'),
    habitService: habitService ?? buildFastingHabitService(),
  );
}

class _FastingBootstrap extends StatefulWidget {
  const _FastingBootstrap({
    required this.analyticsService,
    required this.notificationService,
    required this.monetizationService,
    required this.adService,
    required this.snapshotStore,
    required this.habitService,
  });

  final AnalyticsService analyticsService;
  final NotificationService notificationService;
  final StoreMonetizationService monetizationService;
  final AdService adService;
  final TimerSnapshotStore snapshotStore;
  final HabitService habitService;

  @override
  State<_FastingBootstrap> createState() => _FastingBootstrapState();
}

class _FastingBootstrapState extends State<_FastingBootstrap> {
  static const Duration _lightServicesDelay = Duration(milliseconds: 300);
  static const Duration _monetizationDelay = Duration(milliseconds: 1400);
  static const Duration _adsWarmupDelay = Duration(milliseconds: 2600);

  TimerSnapshot? _restoredSnapshot;
  late final StartupTiming _startupTiming = StartupTiming.forApp('fasting_app');
  late final FastingMonetizationAnalyticsBinding _analyticsBinding =
      FastingMonetizationAnalyticsBinding(
        service: widget.monetizationService,
        analytics: widget.analyticsService,
      );

  @override
  void initState() {
    super.initState();
    _analyticsBinding.attach();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startupTiming.mark('first_frame');
      unawaited(_initializeHabits());
      unawaited(_runTierB());
      unawaited(_runTierC());
    });
  }

  @override
  void dispose() {
    _analyticsBinding.detach();
    super.dispose();
  }

  Future<void> _runTierB() async {
    _startupTiming.mark('bootstrap_start');

    try {
      _startupTiming.mark('snapshot_restore_start');
      final TimerSnapshot? snapshot = await widget.snapshotStore.readSnapshot();
      _startupTiming.mark(
        snapshot == null
            ? 'snapshot_restore_done:none'
            : 'snapshot_restore_done',
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _restoredSnapshot = snapshot;
      });
    } catch (_) {
      _startupTiming.mark('snapshot_restore_failed');
      if (!mounted) {
        return;
      }
      setState(() {});
    } finally {
      _startupTiming.mark('bootstrap_interactive');
    }
  }

  Future<void> _runTierC() async {
    await Future<void>.delayed(_lightServicesDelay);
    if (!mounted) {
      return;
    }

    final List<Future<void>> deferredTasks = <Future<void>>[
      _initializeAnalytics(),
      _initializeNotifications(),
    ];

    if (kDebugMode) {
      _startupTiming.mark('monetization_init_skipped_debug');
      _startupTiming.mark('ads_init_skipped_debug');
    } else {
      deferredTasks.addAll(<Future<void>>[
        _initializeMonetization(),
        _warmAds(),
      ]);
    }

    await Future.wait<void>(deferredTasks);
    _startupTiming.mark('bootstrap_finish');
  }

  Future<void> _initializeHabits() async {
    try {
      await widget.habitService.initialize();
    } catch (_) {}
  }

  Future<void> _initializeAnalytics() async {
    try {
      _startupTiming.mark('analytics_init_start');
      await widget.analyticsService.initialize();
      _startupTiming.mark('analytics_init_done');
    } catch (_) {}
  }

  Future<void> _initializeNotifications() async {
    try {
      _startupTiming.mark('notifications_init_start');
      await widget.notificationService.initialize();
      _startupTiming.mark('notifications_init_done');
    } catch (_) {}
  }

  Future<void> _initializeMonetization() async {
    await Future<void>.delayed(_monetizationDelay);
    if (!mounted) {
      return;
    }

    try {
      _startupTiming.mark('monetization_init_start');
      await widget.monetizationService.initialize();
      _startupTiming.mark('monetization_init_done');
    } catch (_) {
      _startupTiming.mark('monetization_init_failed');
    }
  }

  Future<void> _warmAds() async {
    _startupTiming.mark('ads_init_deferred');
    await Future<void>.delayed(_adsWarmupDelay);
    if (!mounted) {
      return;
    }

    try {
      _startupTiming.mark('ads_init_start');
      await widget.adService.initialize();
      _startupTiming.mark('ads_init_done');
    } catch (_) {
      _startupTiming.mark('ads_init_failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        fastingAnalyticsServiceProvider.overrideWith((_) {
          return widget.analyticsService;
        }),
        fastingMonetizationServiceProvider.overrideWith((_) {
          return widget.monetizationService;
        }),
        fastingAdServiceProvider.overrideWith((_) => widget.adService),
        fastingNotificationServiceProvider.overrideWith((_) {
          return widget.notificationService;
        }),
        fastingSnapshotStoreProvider.overrideWith((_) => widget.snapshotStore),
        fastingHabitServiceProvider.overrideWith((_) => widget.habitService),
        fastingRestoredSnapshotProvider.overrideWith((_) {
          return _restoredSnapshot;
        }),
      ],
      child: _FastingRestoreSync(
        restoredSnapshot: _restoredSnapshot,
        child: const FastingAppEntry(),
      ),
    );
  }
}

class _FastingRestoreSync extends ConsumerStatefulWidget {
  const _FastingRestoreSync({
    required this.restoredSnapshot,
    required this.child,
  });

  final TimerSnapshot? restoredSnapshot;
  final Widget child;

  @override
  ConsumerState<_FastingRestoreSync> createState() =>
      _FastingRestoreSyncState();
}

class _FastingRestoreSyncState extends ConsumerState<_FastingRestoreSync> {
  @override
  void initState() {
    super.initState();
    _invalidateIfNeeded(previousSnapshot: null);
  }

  @override
  void didUpdateWidget(covariant _FastingRestoreSync oldWidget) {
    super.didUpdateWidget(oldWidget);
    _invalidateIfNeeded(previousSnapshot: oldWidget.restoredSnapshot);
  }

  void _invalidateIfNeeded({required TimerSnapshot? previousSnapshot}) {
    final TimerSnapshot? snapshot = widget.restoredSnapshot;
    if (snapshot == null || previousSnapshot != null) {
      return;
    }

    Future<void>.microtask(() {
      if (!mounted) {
        return;
      }
      ref
          .read(fastingControllerProvider.notifier)
          .restoreSnapshotState(snapshot);
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class FastingAppEntry extends StatelessWidget {
  const FastingAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildFastingAppDefinition());
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
