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
    final Color surface = theme.colorScheme.surfaceContainerLowest;
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
              final Widget alignedContent = Align(
                alignment: Alignment.topCenter,
                child: SizedBox(width: contentWidth, child: content),
              );

              if (scrollable) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.lg,
                    AppSpacing.md,
                    AppSpacing.xl,
                  ),
                  child: alignedContent,
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  AppSpacing.lg,
                  AppSpacing.md,
                  AppSpacing.xl,
                ),
                child: alignedContent,
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
            color: Color.alphaBlend(primary.withValues(alpha: 0.035), surface),
            borderRadius: BorderRadius.circular(AppRadius.medium),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.9),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.88,
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
                                letterSpacing: 0.8,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (headerTrailing != null) ...<Widget>[
                      const SizedBox(width: AppSpacing.md),
                      Flexible(child: headerTrailing!),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(title, style: theme.textTheme.headlineMedium),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle!, style: theme.textTheme.bodyMedium),
                ],
              ],
            ),
          ),
        ),
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          action!,
        ],
        const SizedBox(height: AppSpacing.xl),
        SizedBox(width: double.infinity, child: body),
      ],
    );
  }
}
