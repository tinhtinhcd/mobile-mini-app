import 'package:design_system/src/tokens/radius.dart';
import 'package:design_system/src/tokens/spacing.dart';
import 'package:flutter/material.dart';

class SectionLayout extends StatelessWidget {
  const SectionLayout({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.inset = true,
  });

  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final bool inset;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (subtitle != null) ...<Widget>[
                    const SizedBox(height: AppSpacing.xxs),
                    Text(subtitle!, style: theme.textTheme.bodySmall),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...<Widget>[
              const SizedBox(width: AppSpacing.md),
              trailing!,
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        if (inset)
          DecoratedBox(
            decoration: BoxDecoration(
              color: Color.alphaBlend(
                theme.colorScheme.primary.withValues(alpha: 0.02),
                theme.colorScheme.surface,
              ),
              borderRadius: BorderRadius.circular(AppRadius.medium),
              border: Border.all(
                color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: child,
            ),
          )
        else
          child,
      ],
    );
  }
}

class SelectorSection extends SectionLayout {
  const SelectorSection({
    super.key,
    required super.title,
    required super.child,
    super.subtitle,
    super.trailing,
  }) : super(inset: false);
}
