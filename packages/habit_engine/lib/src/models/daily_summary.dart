class DailySummary {
  const DailySummary({
    required this.day,
    required this.sessionCount,
    required this.totalMinutes,
  });

  final DateTime day;
  final int sessionCount;
  final int totalMinutes;

  Duration get totalDuration => Duration(minutes: totalMinutes);
}
