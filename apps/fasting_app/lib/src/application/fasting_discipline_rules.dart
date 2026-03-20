import 'package:discipline_engine/discipline_engine.dart';
import 'package:fasting_app/src/domain/fasting_plan.dart';

class FastingDisciplineRules extends DisciplineRules {
  const FastingDisciplineRules();

  @override
  int expectedCompletedBy({
    required DisciplineGoal goal,
    required DateTime referenceDate,
  }) {
    final int hour = referenceDate.hour;
    if (goal.target <= 1) {
      return hour >= 20 ? 1 : 0;
    }
    if (hour < 14) {
      return 0;
    }
    if (hour < 20) {
      return 1;
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
    return RecoverySuggestion(
      remainingActions: pressure.gapToGoal,
      message:
          'Complete a ${FastingPlan.reset12.label} fast today to protect your streak.',
    );
  }
}
