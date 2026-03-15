import 'package:timer_engine/timer_engine.dart';

enum FastingPlan {
  reset12(
    id: '12_12',
    label: '12:12',
    fastingDuration: Duration(hours: 12),
    eatingWindowLabel: '12h eating window',
    description: 'A balanced reset for building consistency.',
  ),
  lean16(
    id: '16_8',
    label: '16:8',
    fastingDuration: Duration(hours: 16),
    eatingWindowLabel: '8h eating window',
    description: 'The classic daily fasting rhythm.',
  ),
  performance18(
    id: '18_6',
    label: '18:6',
    fastingDuration: Duration(hours: 18),
    eatingWindowLabel: '6h eating window',
    description: 'A longer fast with a compact fueling block.',
  ),
  deep20(
    id: '20_4',
    label: '20:4',
    fastingDuration: Duration(hours: 20),
    eatingWindowLabel: '4h eating window',
    description: 'A deep fast for experienced routines.',
  );

  const FastingPlan({
    required this.id,
    required this.label,
    required this.fastingDuration,
    required this.eatingWindowLabel,
    required this.description,
  });

  final String id;
  final String label;
  final Duration fastingDuration;
  final String eatingWindowLabel;
  final String description;
}

extension FastingPlanSession on FastingPlan {
  TimerSession get session {
    return TimerSession(
      id: id,
      label: '$label fast',
      duration: fastingDuration,
      isTracked: true,
    );
  }
}

FastingPlan fastingPlanFromSession(TimerSession session) {
  return fastingPlanFromSessionId(session.id);
}

FastingPlan fastingPlanFromSessionId(String sessionId) {
  for (final FastingPlan plan in FastingPlan.values) {
    if (plan.id == sessionId) {
      return plan;
    }
  }

  return FastingPlan.lean16;
}
