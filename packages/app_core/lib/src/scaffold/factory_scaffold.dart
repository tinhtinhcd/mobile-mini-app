import 'package:app_core/src/theme/app_tokens.dart';
import 'package:flutter/material.dart';

class FactoryScaffold extends StatelessWidget {
  const FactoryScaffold({
    super.key,
    required this.title,
    required this.body,
    this.subtitle,
    this.action,
    this.headerTrailing,
    this.scrollable = true,
  });

  final String title;
  final String? subtitle;
  final Widget body;
  final Widget? action;
  final Widget? headerTrailing;
  final bool scrollable;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    final Color surface = theme.colorScheme.surface;
    final Widget content = _ScaffoldContent(
      title: title,
      subtitle: subtitle,
      headerTrailing: headerTrailing,
      action: action,
      body: body,
      primary: primary,
      surface: surface,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: DecoratedBox(
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
          child: LayoutBuilder(
            builder: (
              BuildContext context,
              BoxConstraints viewportConstraints,
            ) {
              final double contentWidth =
                  viewportConstraints.maxWidth > 720
                      ? 720
                      : viewportConstraints.maxWidth;
              final Widget centeredContent = Center(
                child: SizedBox(width: contentWidth, child: content),
              );

              if (scrollable) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.xl,
                    AppSpacing.xxl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: centeredContent,
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxl,
                  AppSpacing.xl,
                  AppSpacing.xl,
                ),
                child: centeredContent,
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ScaffoldContent extends StatelessWidget {
  const _ScaffoldContent({
    required this.title,
    required this.subtitle,
    required this.headerTrailing,
    required this.action,
    required this.body,
    required this.primary,
    required this.surface,
  });

  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final Widget? action;
  final Widget body;
  final Color primary;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: <Color>[
                Color.alphaBlend(primary.withValues(alpha: 0.09), surface),
                Color.alphaBlend(primary.withValues(alpha: 0.03), surface),
              ],
            ),
            borderRadius: BorderRadius.circular(AppRadius.large),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface.withValues(
                            alpha: 0.82,
                          ),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.xs,
                          ),
                          child: Text(
                            'UTILITY APP',
                            style: theme.textTheme.bodySmall?.copyWith(
                              letterSpacing: 0.9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text(title, style: theme.textTheme.headlineLarge),
                      if (subtitle != null) ...<Widget>[
                        const SizedBox(height: AppSpacing.sm),
                        Text(subtitle!, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                if (headerTrailing != null) ...<Widget>[
                  const SizedBox(width: AppSpacing.md),
                  headerTrailing!,
                ],
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        SizedBox(width: double.infinity, child: body),
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.xl),
          action!,
        ],
      ],
    );
  }
}
