import 'package:analytics/src/analytics_event.dart';

abstract class AnalyticsService {
  Future<void> initialize();

  Future<void> logEvent(AnalyticsEvent event);
}
