import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppFeedback {
  static void tap(BuildContext context) {
    Feedback.forTap(context);
    HapticFeedback.selectionClick();
  }
}
