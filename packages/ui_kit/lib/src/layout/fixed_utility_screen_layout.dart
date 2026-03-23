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
        final double textScaleFactor = MediaQuery.textScalerOf(
          context,
        ).scale(1);
        final bool compactWidth = constraints.maxWidth < 430;
        final bool compactHeight = constraints.maxHeight < 720;
        final bool tightHeight = constraints.maxHeight < 640;
        final bool shouldScroll =
            compactHeight || compactWidth || textScaleFactor > 1.05;
        final double gap =
            tightHeight || compactWidth
                ? AppSpacing.xxs
                : compactHeight
                ? AppSpacing.xs
                : AppSpacing.sm;
        final double heroHeight =
            (constraints.maxHeight *
                    (tightHeight
                        ? 0.30
                        : compactWidth
                        ? 0.32
                        : 0.4))
                .clamp(
                  compactWidth ? 208.0 : 240.0,
                  compactWidth ? 280.0 : 320.0,
                )
                .toDouble();
        final List<Widget> content = <Widget>[
          if (shouldScroll)
            SizedBox(height: heroHeight, child: hero)
          else
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
        ];

        if (shouldScroll) {
          return SingleChildScrollView(
            key: const ValueKey<String>('fixed-utility-scroll-view'),
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: content,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: content,
        );
      },
    );
  }
}
