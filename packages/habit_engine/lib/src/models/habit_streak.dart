class HabitStreak {
  const HabitStreak({
    required this.current,
    required this.longest,
    this.lastActiveDay,
  });

  const HabitStreak.empty() : current = 0, longest = 0, lastActiveDay = null;

  final int current;
  final int longest;
  final DateTime? lastActiveDay;
}
