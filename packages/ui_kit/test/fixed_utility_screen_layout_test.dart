import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ui_kit/ui_kit.dart';

void main() {
  testWidgets(
    'uses a scroll view on narrow layouts even when height is sufficient',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        const _TestHarness(
          width: 390,
          height: 860,
          child: FixedUtilityScreenLayout(
            hero: Placeholder(),
            primaryAction: Placeholder(),
            secondaryAction: Placeholder(),
            selector: Placeholder(),
            compactPanel: Placeholder(),
          ),
        ),
      );

      expect(
        find.byKey(const ValueKey<String>('fixed-utility-scroll-view')),
        findsOneWidget,
      );
    },
  );
}

class _TestHarness extends StatelessWidget {
  const _TestHarness({
    required this.width,
    required this.height,
    required this.child,
  });

  final double width;
  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData(
        size: Size(width, height),
        textScaler: TextScaler.noScaling,
      ),
      child: MaterialApp(
        home: Material(
          child: Center(
            child: SizedBox(width: width, height: height, child: child),
          ),
        ),
      ),
    );
  }
}
