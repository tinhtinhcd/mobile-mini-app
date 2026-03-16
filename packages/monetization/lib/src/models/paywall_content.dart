class PaywallContent {
  const PaywallContent({
    required this.title,
    required this.subtitle,
    required this.benefits,
    required this.monthlyProductId,
    required this.yearlyProductId,
    this.monthlyFallbackPrice = r'$0.99 / month',
    this.yearlyFallbackPrice = r'$9.99 / year',
    this.closeLabel = 'Maybe later',
    this.restoreLabel = 'Restore purchases',
  });

  final String title;
  final String subtitle;
  final List<String> benefits;
  final String monthlyProductId;
  final String yearlyProductId;
  final String monthlyFallbackPrice;
  final String yearlyFallbackPrice;
  final String closeLabel;
  final String restoreLabel;
}
