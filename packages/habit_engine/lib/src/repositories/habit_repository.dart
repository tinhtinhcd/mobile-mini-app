import 'package:habit_engine/src/models/daily_summary.dart';
import 'package:habit_engine/src/models/habit_goal.dart';
import 'package:habit_engine/src/models/habit_session.dart';
import 'package:habit_engine/src/models/habit_streak.dart';

abstract class HabitRepository {
  Future<void> saveSession(HabitSession session);

  Future<List<HabitSession>> getSessions({
    DateTime? from,
    DateTime? to,
    int? limit,
  });

  Future<DailySummary> getTodaySummary();

  Future<DailySummary> getWeeklySummary();

  Future<HabitStreak> getStreak();

  Future<HabitStreak> updateStreak(DateTime activeDay);

  Future<HabitGoal> getGoal();

  Future<void> saveGoal(HabitGoal goal);
}
