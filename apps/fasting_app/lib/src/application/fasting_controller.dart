import 'package:fasting_app/src/domain/fasting_plan.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timer_engine/timer_engine.dart';

final fastingControllerProvider =
    NotifierProvider<FastingController, TimerState>(FastingController.new);

class FastingController extends TimerController {
  @override
  TimerSession get initialSession => FastingPlan.lean16.session;

  FastingPlan get selectedPlan => fastingPlanFromSession(state.activeSession);

  void selectPlan(FastingPlan plan) {
    selectSession(plan.session);
  }

  @override
  TimerSession resolveNextSession(TimerState completedState) {
    return completedState.activeSession;
  }
}

