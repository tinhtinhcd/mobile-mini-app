import 'package:flutter/foundation.dart';
import 'package:habit_engine/src/models/habit_session_record.dart';
import 'package:habit_engine/src/models/habit_snapshot.dart';
import 'package:habit_engine/src/stores/habit_snapshot_store.dart';

class HabitService extends ChangeNotifier {
  HabitService({
    required HabitSnapshotStore snapshotStore,
    required int defaultDailyGoal,
  }) : _snapshotStore = snapshotStore,
       _defaultDailyGoal = defaultDailyGoal,
       _snapshot = HabitSnapshot.initial(
         dailyGoal: defaultDailyGoal > 0 ? defaultDailyGoal : 1,
       );

  final HabitSnapshotStore _snapshotStore;
  final int _defaultDailyGoal;

  HabitSnapshot _snapshot;
  Future<void>? _initializeFuture;
  bool _initialized = false;

  bool get isInitialized => _initialized;

  int get dailyGoal => _snapshot.dailyGoal;

  int get currentStreak => _snapshot.currentStreak;

  int get longestStreak => _snapshot.longestStreak;

  DateTime? get lastActiveDay {
    final int? millis = _snapshot.lastActiveDayUtcMillis;
    if (millis == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
  }

  List<HabitSessionRecord> get records => _snapshot.records;

  int get todayCount => countForDay(DateTime.now());

  int get todayMinutes => minutesForDay(DateTime.now());

  int get weeklyCount => countForLastDays(7);

  int get weeklyMinutes => minutesForLastDays(7);

  double get goalProgress {
    if (dailyGoal <= 0) {
      return 0;
    }
    final double progress = todayCount / dailyGoal;
    if (progress < 0) {
      return 0;
    }
    if (progress > 1) {
      return 1;
    }
    return progress;
  }

  HabitSessionRecord? get lastRecord {
    if (_snapshot.records.isEmpty) {
      return null;
    }

    final List<HabitSessionRecord> sorted = List<HabitSessionRecord>.from(
      _snapshot.records,
    )..sort(
      (HabitSessionRecord a, HabitSessionRecord b) =>
          b.completedAtUtcMillis.compareTo(a.completedAtUtcMillis),
    );
    return sorted.first;
  }

  Duration? get lastSessionDuration {
    final HabitSessionRecord? record = lastRecord;
    return record?.duration;
  }

  Future<void> initialize() {
    return _initializeFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    final HabitSnapshot? storedSnapshot = await _snapshotStore.readSnapshot();
    _snapshot = _normalizeSnapshot(
      storedSnapshot ??
          HabitSnapshot.initial(
            dailyGoal: _defaultDailyGoal > 0 ? _defaultDailyGoal : 1,
          ),
    );
    _initialized = true;
    notifyListeners();
  }

  Future<void> updateDailyGoal(int dailyGoal) async {
    await initialize();

    final HabitSnapshot nextSnapshot = _rebuildSnapshot(
      records: _snapshot.records,
      dailyGoal: dailyGoal > 0 ? dailyGoal : 1,
    );
    await _replaceSnapshot(nextSnapshot);
  }

  Future<void> recordSession({
    required String type,
    required Duration duration,
    DateTime? completedAt,
  }) async {
    if (duration <= Duration.zero) {
      return;
    }

    await initialize();

    final HabitSessionRecord record = HabitSessionRecord(
      type: type,
      completedAtUtcMillis:
          (completedAt ?? DateTime.now()).toUtc().millisecondsSinceEpoch,
      durationMinutes: duration.inMinutes,
    );

    final List<HabitSessionRecord> updatedRecords = <HabitSessionRecord>[
      ..._snapshot.records,
      record,
    ]..sort(
      (HabitSessionRecord a, HabitSessionRecord b) =>
          a.completedAtUtcMillis.compareTo(b.completedAtUtcMillis),
    );

    if (updatedRecords.length > HabitSnapshot.maxRecords) {
      updatedRecords.removeRange(
        0,
        updatedRecords.length - HabitSnapshot.maxRecords,
      );
    }

    final HabitSnapshot nextSnapshot = _rebuildSnapshot(
      records: updatedRecords,
      dailyGoal: _snapshot.dailyGoal,
    );
    await _replaceSnapshot(nextSnapshot);
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
    final List<HabitSessionRecord> sorted = List<HabitSessionRecord>.from(
      _snapshot.records,
    )..sort(
      (HabitSessionRecord a, HabitSessionRecord b) =>
          b.completedAtUtcMillis.compareTo(a.completedAtUtcMillis),
    );

    if (sorted.length <= limit) {
      return sorted;
    }
    return sorted.sublist(0, limit);
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

  Future<void> _replaceSnapshot(HabitSnapshot nextSnapshot) async {
    _snapshot = nextSnapshot;
    notifyListeners();
    await _snapshotStore.writeSnapshot(nextSnapshot);
  }

  HabitSnapshot _normalizeSnapshot(HabitSnapshot snapshot) {
    final List<HabitSessionRecord> normalizedRecords =
        List<HabitSessionRecord>.from(snapshot.records)..sort(
          (HabitSessionRecord a, HabitSessionRecord b) =>
              a.completedAtUtcMillis.compareTo(b.completedAtUtcMillis),
        );

    return _rebuildSnapshot(
      records: normalizedRecords,
      dailyGoal:
          snapshot.dailyGoal > 0 ? snapshot.dailyGoal : _defaultDailyGoal,
    );
  }

  HabitSnapshot _rebuildSnapshot({
    required List<HabitSessionRecord> records,
    required int dailyGoal,
  }) {
    final List<DateTime> activeDays =
        records
            .map(
              (HabitSessionRecord record) => _dayKey(record.completedAtLocal),
            )
            .toSet()
            .toList()
          ..sort();

    final int currentStreak = _calculateCurrentStreak(activeDays);
    final int longestStreak = _calculateLongestStreak(activeDays);
    final DateTime? lastActiveDay = activeDays.isEmpty ? null : activeDays.last;

    return HabitSnapshot(
      dailyGoal: dailyGoal,
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastActiveDayUtcMillis: lastActiveDay?.toUtc().millisecondsSinceEpoch,
      records: List<HabitSessionRecord>.unmodifiable(records),
    );
  }

  int _calculateCurrentStreak(List<DateTime> activeDays) {
    if (activeDays.isEmpty) {
      return 0;
    }

    final Set<DateTime> activeDaySet = activeDays.toSet();
    final DateTime today = _dayKey(DateTime.now());
    DateTime cursor = today;
    int streak = 0;

    while (activeDaySet.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int _calculateLongestStreak(List<DateTime> activeDays) {
    if (activeDays.isEmpty) {
      return 0;
    }

    int longest = 1;
    int current = 1;
    for (int index = 1; index < activeDays.length; index += 1) {
      final int gap =
          activeDays[index].difference(activeDays[index - 1]).inDays;
      if (gap == 1) {
        current += 1;
      } else if (gap > 1) {
        current = 1;
      }

      if (current > longest) {
        longest = current;
      }
    }

    return longest;
  }

  List<HabitSessionRecord> _entriesForDay(DateTime day) {
    final DateTime target = _dayKey(day);
    return _snapshot.records
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
    return _snapshot.records
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
