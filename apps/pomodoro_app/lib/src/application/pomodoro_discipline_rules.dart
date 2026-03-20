import 'package:discipline_engine/discipline_engine.dart';

class PomodoroDisciplineRules extends DisciplineRules {
  const PomodoroDisciplineRules();

  @override
  int expectedCompletedBy({
    required DisciplineGoal goal,
    required DateTime referenceDate,
  }) {
    final int hour = referenceDate.hour;
    if (hour < 10) {
      return 0;
    }
    if (hour < 14) {
      return goal.target > 1 ? 1 : 0;
    }
    if (hour < 18) {
      return ((goal.target * 0.5).ceil()).clamp(1, goal.target);
    }
    if (hour < 21) {
      return ((goal.target * 0.75).ceil()).clamp(1, goal.target);
    }
    return goal.target;
  }

  @override
  RecoverySuggestion? buildRecoverySuggestion({
    required DisciplineGoal goal,
    required DisciplinePressure pressure,
  }) {
    if (pressure.gapToGoal <= 0) {
      return null;
    }
    final String noun = pressure.gapToGoal == 1 ? 'session' : 'sessions';
    return RecoverySuggestion(
      remainingActions: pressure.gapToGoal,
      message: 'Do ${pressure.gapToGoal} more $noun today to stay on track.',
    );
  }
}
