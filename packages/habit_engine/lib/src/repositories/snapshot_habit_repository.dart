import 'package:habit_engine/src/models/daily_summary.dart';
import 'package:habit_engine/src/models/habit_goal.dart';
import 'package:habit_engine/src/models/habit_session.dart';
import 'package:habit_engine/src/models/habit_session_record.dart';
import 'package:habit_engine/src/models/habit_snapshot.dart';
import 'package:habit_engine/src/models/habit_streak.dart';
import 'package:habit_engine/src/repositories/habit_repository.dart';
import 'package:habit_engine/src/stores/habit_snapshot_store.dart';

class SnapshotHabitRepository implements HabitRepository {
  SnapshotHabitRepository({
    required HabitSnapshotStore snapshotStore,
    required int defaultDailyGoal,
  }) : _snapshotStore = snapshotStore,
       _defaultDailyGoal = defaultDailyGoal > 0 ? defaultDailyGoal : 1;

  final HabitSnapshotStore _snapshotStore;
  final int _defaultDailyGoal;

  @override
  Future<void> saveSession(HabitSession session) async {
    final HabitSnapshot snapshot = await _readSnapshot();
    final HabitSessionRecord record = HabitSessionRecord(
      type: session.type,
      completedAtUtcMillis: session.completedAtUtcMillis,
      durationMinutes: session.durationMinutes,
    );
    final List<HabitSessionRecord> updatedRecords = <HabitSessionRecord>[
      ...snapshot.records,
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

    await _snapshotStore.writeSnapshot(
      snapshot.copyWith(records: updatedRecords),
    );
    await updateStreak(session.completedAtLocal);
  }

  @override
  Future<List<HabitSession>> getSessions({
    DateTime? from,
    DateTime? to,
    int? limit,
  }) async {
    final HabitSnapshot snapshot = await _readSnapshot();
    Iterable<HabitSession> sessions = snapshot.records;

    if (from != null) {
      final int fromMillis = from.toUtc().millisecondsSinceEpoch;
      sessions = sessions.where(
        (HabitSession session) => session.completedAtUtcMillis >= fromMillis,
      );
    }

    if (to != null) {
      final int toMillis = to.toUtc().millisecondsSinceEpoch;
      sessions = sessions.where(
        (HabitSession session) => session.completedAtUtcMillis <= toMillis,
      );
    }

    final List<HabitSession> sorted = sessions.toList(growable: false)..sort(
      (HabitSession a, HabitSession b) =>
          b.completedAtUtcMillis.compareTo(a.completedAtUtcMillis),
    );

    if (limit == null || sorted.length <= limit) {
      return List<HabitSession>.from(sorted);
    }
    return List<HabitSession>.from(sorted.sublist(0, limit));
  }

  @override
  Future<DailySummary> getTodaySummary() async {
    final DateTime today = _dayKey(DateTime.now());
    final List<HabitSession> sessions = _entriesForDay(
      (await _readSnapshot()).records,
      today,
    );
    return _buildSummary(today, sessions);
  }

  @override
  Future<DailySummary> getWeeklySummary() async {
    final DateTime today = _dayKey(DateTime.now());
    final DateTime start = today.subtract(const Duration(days: 6));
    final List<HabitSession> sessions = _entriesForRange(
      (await _readSnapshot()).records,
      start,
      today,
    );
    return _buildSummary(today, sessions);
  }

  @override
  Future<HabitStreak> getStreak() async {
    final HabitSnapshot snapshot = await _readSnapshot();
    return HabitStreak(
      current: snapshot.currentStreak,
      longest: snapshot.longestStreak,
      lastActiveDay: _lastActiveDay(snapshot),
    );
  }

  @override
  Future<HabitStreak> updateStreak(DateTime activeDay) async {
    final HabitSnapshot snapshot = await _readSnapshot();
    final List<DateTime> activeDays = snapshot.records
      .map<DateTime>(
        (HabitSession session) => _dayKey(session.completedAtLocal),
      )
      .toSet()
      .toList(growable: true)..sort();

    final DateTime normalizedDay = _dayKey(activeDay);
    if (!activeDays.contains(normalizedDay)) {
      activeDays.add(normalizedDay);
      activeDays.sort();
    }

    final int current = _calculateCurrentStreak(activeDays);
    final int longest = _calculateLongestStreak(activeDays);
    final DateTime? lastActiveDay = activeDays.isEmpty ? null : activeDays.last;

    await _snapshotStore.writeSnapshot(
      snapshot.copyWith(
        currentStreak: current,
        longestStreak: longest,
        lastActiveDayUtcMillis: lastActiveDay?.toUtc().millisecondsSinceEpoch,
      ),
    );

    return HabitStreak(
      current: current,
      longest: longest,
      lastActiveDay: lastActiveDay,
    );
  }

  @override
  Future<HabitGoal> getGoal() async {
    final HabitSnapshot snapshot = await _readSnapshot();
    final int completedToday =
        _entriesForDay(snapshot.records, DateTime.now()).length;
    return HabitGoal(
      dailyTarget: snapshot.dailyGoal,
      completedToday: completedToday,
    );
  }

  @override
  Future<void> saveGoal(HabitGoal goal) async {
    final HabitSnapshot snapshot = await _readSnapshot();
    await _snapshotStore.writeSnapshot(
      snapshot.copyWith(
        dailyGoal: goal.dailyTarget > 0 ? goal.dailyTarget : _defaultDailyGoal,
      ),
    );
  }

  int _calculateCurrentStreak(List<DateTime> activeDays) {
    if (activeDays.isEmpty) {
      return 0;
    }

    final Set<DateTime> activeDaySet = activeDays.toSet();
    DateTime cursor = _dayKey(DateTime.now());
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

  DailySummary _buildSummary(DateTime day, List<HabitSession> sessions) {
    return DailySummary(
      day: day,
      sessionCount: sessions.length,
      totalMinutes: sessions.fold<int>(
        0,
        (int sum, HabitSession session) => sum + session.durationMinutes,
      ),
    );
  }

  List<HabitSession> _entriesForDay(List<HabitSession> records, DateTime day) {
    final DateTime target = _dayKey(day);
    return records
        .where(
          (HabitSession session) => _dayKey(session.completedAtLocal) == target,
        )
        .toList(growable: false);
  }

  List<HabitSession> _entriesForRange(
    List<HabitSession> records,
    DateTime start,
    DateTime end,
  ) {
    return records
        .where((HabitSession session) {
          final DateTime day = _dayKey(session.completedAtLocal);
          return !day.isBefore(start) && !day.isAfter(end);
        })
        .toList(growable: false);
  }

  DateTime? _lastActiveDay(HabitSnapshot snapshot) {
    final int? millis = snapshot.lastActiveDayUtcMillis;
    if (millis == null) {
      return null;
    }
    return DateTime.fromMillisecondsSinceEpoch(millis, isUtc: true).toLocal();
  }

  Future<HabitSnapshot> _readSnapshot() async {
    return await _snapshotStore.readSnapshot() ??
        HabitSnapshot.initial(dailyGoal: _defaultDailyGoal);
  }

  static DateTime _dayKey(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}
