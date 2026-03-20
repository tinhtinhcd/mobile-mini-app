enum DisciplineStatusType { notStarted, onTrack, behind, completed }

class DisciplineStatus {
  const DisciplineStatus({
    required this.type,
    required this.label,
    required this.message,
  });

  final DisciplineStatusType type;
  final String label;
  final String message;
}
