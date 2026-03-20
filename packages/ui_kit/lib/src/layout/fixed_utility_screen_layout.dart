import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class FixedUtilityScreenLayout extends StatelessWidget {
  const FixedUtilityScreenLayout({
    super.key,
    required this.hero,
    required this.primaryAction,
    required this.selector,
    required this.compactPanel,
    this.secondaryAction,
  });

  final Widget hero;
  final Widget primaryAction;
  final Widget selector;
  final Widget compactPanel;
  final Widget? secondaryAction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final bool compactHeight = constraints.maxHeight < 720;
        final bool tightHeight = constraints.maxHeight < 640;
        final double gap =
            tightHeight
                ? AppSpacing.xxs
                : compactHeight
                ? AppSpacing.xs
                : AppSpacing.sm;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(child: hero),
            SizedBox(height: gap),
            primaryAction,
            if (secondaryAction != null) ...<Widget>[
              SizedBox(height: gap),
              secondaryAction!,
            ],
            SizedBox(height: gap),
            selector,
            SizedBox(height: gap),
            compactPanel,
          ],
        );
      },
    );
  }
}
