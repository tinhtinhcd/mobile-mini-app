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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final content = Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.xxxl,
        AppSpacing.xl,
        AppSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
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
          const SizedBox(height: AppSpacing.xl),
          Expanded(
            child: scrollable
                ? SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: SizedBox(
                      width: double.infinity,
                      child: body,
                    ),
                  )
                : body,
          ),
          if (action != null) ...<Widget>[
            const SizedBox(height: AppSpacing.lg),
            action!,
          ],
        ],
      ),
    );

    return Scaffold(
      body: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: <Color>[
              AppColors.background,
              Color.alphaBlend(primary.withOpacity(0.08), AppColors.background),
            ],
          ),
        ),
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -90,
              right: -30,
              child: _GlowOrb(
                color: primary.withOpacity(0.12),
                size: 220,
              ),
            ),
            Positioned(
              left: -80,
              bottom: 100,
              child: _GlowOrb(
                color: primary.withOpacity(0.08),
                size: 180,
              ),
            ),
            SafeArea(child: content),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({
    required this.color,
    required this.size,
  });

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color,
              color.withOpacity(0),
            ],
          ),
        ),
      ),
    );
  }
}
