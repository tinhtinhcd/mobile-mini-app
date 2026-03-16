import 'package:flutter/foundation.dart';

class TestAdUnitIds {
  static String get banner {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ca-app-pub-3940256099942544/9214589741',
      TargetPlatform.iOS => 'ca-app-pub-3940256099942544/2435281174',
      _ => '',
    };
  }

  static String get interstitial {
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'ca-app-pub-3940256099942544/1033173712',
      TargetPlatform.iOS => 'ca-app-pub-3940256099942544/4411468910',
      _ => '',
    };
  }
}
