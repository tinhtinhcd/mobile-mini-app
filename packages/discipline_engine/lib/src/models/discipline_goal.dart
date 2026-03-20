class DisciplineGoal {
  const DisciplineGoal({
    required this.target,
    required this.completed,
    required this.remaining,
    required this.suggestedTarget,
  });

  final int target;
  final int completed;
  final int remaining;
  final int suggestedTarget;

  double get progress {
    if (target <= 0) {
      return 0;
    }
    return (completed / target).clamp(0, 1);
  }
}
