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
    final Widget content = _ScaffoldContent(
      title: title,
      subtitle: subtitle,
      headerTrailing: headerTrailing,
      action: action,
      body: body,
      primary: primary,
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
                primary.withValues(alpha: 0.10),
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
                    AppSpacing.xxxl,
                    AppSpacing.xl,
                    AppSpacing.xl,
                  ),
                  child: centeredContent,
                );
              }

              return Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xxxl,
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
  });

  final String title;
  final String? subtitle;
  final Widget? headerTrailing;
  final Widget? action;
  final Widget body;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        DecoratedBox(
          decoration: BoxDecoration(
            color: Color.alphaBlend(
              primary.withValues(alpha: 0.06),
              theme.colorScheme.surface,
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
        const SizedBox(height: AppSpacing.xl),
        SizedBox(width: double.infinity, child: body),
        if (action != null) ...<Widget>[
          const SizedBox(height: AppSpacing.lg),
          action!,
        ],
      ],
    );
  }
}
