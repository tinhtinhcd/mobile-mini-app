class UsageLimitResult {
  const UsageLimitResult({
    required this.allowed,
    required this.requiresPremium,
    required this.remainingFreeUses,
    required this.message,
  });

  final bool allowed;
  final bool requiresPremium;
  final int remainingFreeUses;
  final String message;
}
