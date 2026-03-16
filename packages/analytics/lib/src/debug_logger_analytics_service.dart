import 'package:analytics/src/analytics_event.dart';
import 'package:analytics/src/analytics_service.dart';
import 'package:flutter/foundation.dart';

class DebugLoggerAnalyticsService implements AnalyticsService {
  bool _isInitialized = false;

  @override
  Future<void> initialize() async {
    _isInitialized = true;
  }

  @override
  Future<void> logEvent(AnalyticsEvent event) async {
    try {
      if (!_isInitialized) {
        await initialize();
      }

      if (!kDebugMode) {
        return;
      }

      debugPrint(
        'analytics ${event.name} ${event.parameters}',
      );
    } catch (_) {}
  }
}
