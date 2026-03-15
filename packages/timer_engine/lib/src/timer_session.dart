class TimerSession {
  const TimerSession({
    required this.id,
    required this.label,
    required this.duration,
    this.isTracked = true,
  });

  final String id;
  final String label;
  final Duration duration;
  final bool isTracked;
}

