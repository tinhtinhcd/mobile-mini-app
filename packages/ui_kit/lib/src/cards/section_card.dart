import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    this.title,
    this.subtitle,
    this.trailing,
    required this.child,
    this.compact = false,
  });

  final String? title;
  final String? subtitle;
  final Widget? trailing;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          theme.colorScheme.primary.withValues(alpha: 0.018),
          theme.colorScheme.surfaceContainerLowest,
        ),
        borderRadius: BorderRadius.circular(AppRadius.medium),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.7),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.all(compact ? AppSpacing.sm : AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (title != null ||
                subtitle != null ||
                trailing != null) ...<Widget>[
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        if (title != null)
                          Text(
                            title!,
                            style:
                                compact
                                    ? theme.textTheme.titleSmall
                                    : theme.textTheme.titleMedium,
                          ),
                        if (subtitle != null) ...<Widget>[
                          SizedBox(
                            height: compact ? AppSpacing.xxs : AppSpacing.xs,
                          ),
                          Text(subtitle!, style: theme.textTheme.bodySmall),
                        ],
                      ],
                    ),
                  ),
                  if (trailing != null) ...<Widget>[
                    SizedBox(width: compact ? AppSpacing.sm : AppSpacing.md),
                    trailing!,
                  ],
                ],
              ),
              SizedBox(height: compact ? AppSpacing.sm : AppSpacing.md),
            ],
            child,
          ],
        ),
      ),
    );
  }
}
