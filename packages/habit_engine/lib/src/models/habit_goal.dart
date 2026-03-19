class HabitGoal {
  const HabitGoal({required this.dailyTarget, required this.completedToday});

  final int dailyTarget;
  final int completedToday;

  double get progress {
    if (dailyTarget <= 0) {
      return 0;
    }
    final double ratio = completedToday / dailyTarget;
    if (ratio < 0) {
      return 0;
    }
    if (ratio > 1) {
      return 1;
    }
    return ratio;
  }
}
