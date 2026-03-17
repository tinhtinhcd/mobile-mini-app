import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

class ActionZone extends StatelessWidget {
  const ActionZone({super.key, required this.primary, this.secondary});

  final Widget primary;
  final Widget? secondary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        primary,
        if (secondary != null) ...<Widget>[
          const SizedBox(height: AppSpacing.sm),
          secondary!,
        ],
      ],
    );
  }
}

class PrimaryActionZone extends ActionZone {
  const PrimaryActionZone({super.key, required super.primary, super.secondary});
}
