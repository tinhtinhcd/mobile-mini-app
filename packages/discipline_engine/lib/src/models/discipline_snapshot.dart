import 'package:discipline_engine/src/models/discipline_goal.dart';
import 'package:discipline_engine/src/models/discipline_pressure.dart';
import 'package:discipline_engine/src/models/discipline_status.dart';
import 'package:discipline_engine/src/models/recovery_suggestion.dart';

class DisciplineSnapshot {
  const DisciplineSnapshot({
    required this.goal,
    required this.status,
    required this.pressure,
    required this.expectedCompleted,
    this.recoverySuggestion,
  });

  final DisciplineGoal goal;
  final DisciplineStatus status;
  final DisciplinePressure pressure;
  final int expectedCompleted;
  final RecoverySuggestion? recoverySuggestion;

  int get paceGap {
    final int gap = expectedCompleted - goal.completed;
    return gap > 0 ? gap : 0;
  }
}
