class DisciplinePressure {
  const DisciplinePressure({
    required this.gapToGoal,
    required this.streakAtRisk,
    required this.currentStreak,
    this.warningMessage,
    this.streakMessage,
  });

  final int gapToGoal;
  final bool streakAtRisk;
  final int currentStreak;
  final String? warningMessage;
  final String? streakMessage;
}
