import 'package:discipline_engine/src/models/discipline_goal.dart';
import 'package:discipline_engine/src/models/discipline_pressure.dart';
import 'package:discipline_engine/src/models/recovery_suggestion.dart';

abstract class DisciplineRules {
  const DisciplineRules();

  int expectedCompletedBy({
    required DisciplineGoal goal,
    required DateTime referenceDate,
  });

  RecoverySuggestion? buildRecoverySuggestion({
    required DisciplineGoal goal,
    required DisciplinePressure pressure,
  });
}
