import 'package:flutter/foundation.dart';
import 'package:habit_engine/src/models/daily_summary.dart';
import 'package:habit_engine/src/models/habit_goal.dart';
import 'package:habit_engine/src/models/habit_session.dart';
import 'package:habit_engine/src/models/habit_session_record.dart';
import 'package:habit_engine/src/models/habit_streak.dart';
import 'package:habit_engine/src/repositories/habit_repository.dart';
import 'package:habit_engine/src/repositories/snapshot_habit_repository.dart';
import 'package:habit_engine/src/stores/habit_snapshot_store.dart';

class HabitService extends ChangeNotifier {
  HabitService({
    HabitRepository? repository,
    HabitSnapshotStore? snapshotStore,
    required int defaultDailyGoal,
  }) : _repository =
           repository ??
           SnapshotHabitRepository(
             snapshotStore: snapshotStore!,
             defaultDailyGoal: defaultDailyGoal,
           ),
       _defaultDailyGoal = defaultDailyGoal > 0 ? defaultDailyGoal : 1,
       _todaySummary = DailySummary(
         day: _dayKey(DateTime.now()),
         sessionCount: 0,
         totalMinutes: 0,
       ),
       _weeklySummary = DailySummary(
         day: _dayKey(DateTime.now()),
         sessionCount: 0,
         totalMinutes: 0,
       ),
       _streak = const HabitStreak.empty(),
       _goal = HabitGoal(
         dailyTarget: defaultDailyGoal > 0 ? defaultDailyGoal : 1,
         completedToday: 0,
       );

  final HabitRepository _repository;
  final int _defaultDailyGoal;

  List<HabitSessionRecord> _sessions = const <HabitSessionRecord>[];
  DailySummary _todaySummary;
  DailySummary _weeklySummary;
  HabitStreak _streak;
  HabitGoal _goal;
  Future<void>? _initializeFuture;
  bool _initialized = false;
  bool _disposed = false;

  bool get isInitialized => _initialized;

  int get dailyGoal => _goal.dailyTarget;

  int get currentStreak => _streak.current;

  int get longestStreak => _streak.longest;

  DateTime? get lastActiveDay => _streak.lastActiveDay;

  List<HabitSessionRecord> get records =>
      List<HabitSessionRecord>.from(_sessions);

  int get todayCount => _todaySummary.sessionCount;

  int get todayMinutes => _todaySummary.totalMinutes;

  int get weeklyCount => _weeklySummary.sessionCount;

  int get weeklyMinutes => _weeklySummary.totalMinutes;

  double get goalProgress => _goal.progress;

  HabitSessionRecord? get lastRecord {
    if (_sessions.isEmpty) {
      return null;
    }
    return _sessions.first;
  }

  Duration? get lastSessionDuration => lastRecord?.duration;

  Future<void> initialize() {
    return _initializeFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    await _refresh();
    if (_disposed) {
      return;
    }
    _initialized = true;
    notifyListeners();
  }

  Future<void> updateDailyGoal(int dailyGoal) async {
    if (_disposed) {
      return;
    }
    await initialize();
    if (_disposed) {
      return;
    }
    await _repository.saveGoal(
      HabitGoal(
        dailyTarget: dailyGoal > 0 ? dailyGoal : _defaultDailyGoal,
        completedToday: _goal.completedToday,
      ),
    );
    await _refresh(notify: true);
  }

  Future<void> recordSession({
    required String type,
    required Duration duration,
    DateTime? completedAt,
  }) async {
    if (_disposed || duration <= Duration.zero) {
      return;
    }

    await initialize();
    if (_disposed) {
      return;
    }
    await _repository.saveSession(
      HabitSession(
        type: type,
        completedAtUtcMillis:
            (completedAt ?? DateTime.now()).toUtc().millisecondsSinceEpoch,
        durationMinutes: duration.inMinutes,
      ),
    );
    await _refresh(notify: true);
  }

  int countForDay(DateTime day) {
    return _entriesForDay(day).length;
  }

  int minutesForDay(DateTime day) {
    return _entriesForDay(day).fold<int>(
      0,
      (int sum, HabitSessionRecord entry) => sum + entry.durationMinutes,
    );
  }

  int countForLastDays(int days, {DateTime? referenceDate}) {
    return _entriesForLastDays(days, referenceDate: referenceDate).length;
  }

  int minutesForLastDays(int days, {DateTime? referenceDate}) {
    return _entriesForLastDays(days, referenceDate: referenceDate).fold<int>(
      0,
      (int sum, HabitSessionRecord entry) => sum + entry.durationMinutes,
    );
  }

  List<HabitSessionRecord> recentRecords({int limit = 5}) {
    if (_sessions.length <= limit) {
      return List<HabitSessionRecord>.from(_sessions);
    }
    return List<HabitSessionRecord>.from(_sessions.sublist(0, limit));
  }

  List<HabitSessionRecord> recordsForDay(DateTime day) {
    return _entriesForDay(day);
  }

  List<HabitSessionRecord> recordsForLastDays(
    int days, {
    DateTime? referenceDate,
  }) {
    return _entriesForLastDays(days, referenceDate: referenceDate);
  }

  Future<void> _refresh({bool notify = false}) async {
    _sessions = (await _repository.getSessions())
        .map((HabitSession session) {
          return HabitSessionRecord(
            type: session.type,
            completedAtUtcMillis: session.completedAtUtcMillis,
            durationMinutes: session.durationMinutes,
          );
        })
        .toList(growable: false);
    _todaySummary = await _repository.getTodaySummary();
    _weeklySummary = await _repository.getWeeklySummary();
    _streak = await _repository.getStreak();
    _goal = await _repository.getGoal();
    if (notify && !_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  List<HabitSessionRecord> _entriesForDay(DateTime day) {
    final DateTime target = _dayKey(day);
    return _sessions
        .where(
          (HabitSessionRecord entry) =>
              _dayKey(entry.completedAtLocal) == target,
        )
        .toList(growable: false);
  }

  List<HabitSessionRecord> _entriesForLastDays(
    int days, {
    DateTime? referenceDate,
  }) {
    final DateTime end = _dayKey(referenceDate ?? DateTime.now());
    final DateTime start = end.subtract(Duration(days: days - 1));
    return _sessions
        .where((HabitSessionRecord entry) {
          final DateTime day = _dayKey(entry.completedAtLocal);
          return !day.isBefore(start) && !day.isAfter(end);
        })
        .toList(growable: false);
  }

  static DateTime _dayKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
