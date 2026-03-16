import 'package:flutter/foundation.dart';

class StartupTiming {
  StartupTiming._(this.appId);

  static final Map<String, StartupTiming> _instances =
      <String, StartupTiming>{};

  static StartupTiming forApp(String appId) {
    return _instances.putIfAbsent(appId, () => StartupTiming._(appId));
  }

  final String appId;
  final Stopwatch _stopwatch = Stopwatch()..start();

  void mark(String label) {
    assert(() {
      debugPrint(
        '[Startup][$appId] $label +${_stopwatch.elapsedMilliseconds}ms',
      );
      return true;
    }());
  }
}
