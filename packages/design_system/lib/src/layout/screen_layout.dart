import 'package:design_system/src/tokens/shell.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

class ScreenLayout extends StatelessWidget {
  const ScreenLayout({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.scrollable = true,
  });

  final Widget child;
  final double maxWidth;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: AppContentFrame(
        maxWidth: maxWidth,
        scrollable: scrollable,
        child: child,
      ),
    );
  }
}

class AppContentFrame extends StatelessWidget {
  const AppContentFrame({
    super.key,
    required this.child,
    this.maxWidth = 720,
    this.scrollable = true,
    this.includeTopSafeArea = true,
    this.includeBottomSafeArea = true,
    this.contentPadding,
  });

  final Widget child;
  final double maxWidth;
  final bool scrollable;
  final bool includeTopSafeArea;
  final bool includeBottomSafeArea;
  final EdgeInsetsGeometry? contentPadding;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    final Color surface = theme.colorScheme.surfaceContainerLowest;

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            theme.scaffoldBackgroundColor,
            Color.alphaBlend(
              primary.withValues(alpha: 0.08),
              theme.scaffoldBackgroundColor,
            ),
            Color.alphaBlend(
              surface.withValues(alpha: 0.24),
              theme.scaffoldBackgroundColor,
            ),
          ],
        ),
      ),
      child: SafeArea(
        top: includeTopSafeArea,
        bottom: includeBottomSafeArea,
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double contentWidth =
                constraints.maxWidth > maxWidth
                    ? maxWidth
                    : constraints.maxWidth;
            final Widget alignedChild = Align(
              alignment: Alignment.topCenter,
              child: SizedBox(width: contentWidth, child: child),
            );

            if (scrollable) {
              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding:
                    contentPadding ??
                    const EdgeInsets.fromLTRB(
                      AppShellMetrics.contentHorizontalPadding,
                      AppShellMetrics.contentHorizontalPadding,
                      AppShellMetrics.contentHorizontalPadding,
                      AppSpacing.xl,
                    ),
                child: alignedChild,
              );
            }

            return Padding(
              padding:
                  contentPadding ??
                  const EdgeInsets.fromLTRB(
                    AppShellMetrics.contentHorizontalPadding,
                    AppShellMetrics.contentHorizontalPadding,
                    AppShellMetrics.contentHorizontalPadding,
                    AppSpacing.xl,
                  ),
              child: alignedChild,
            );
          },
        ),
      ),
    );
  }
}

class TimerHero extends StatelessWidget {
  const TimerHero({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
