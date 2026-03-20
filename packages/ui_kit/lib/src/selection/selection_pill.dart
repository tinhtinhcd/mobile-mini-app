import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class SelectionPill extends StatelessWidget {
  const SelectionPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.leading,
    this.compact = false,
  });

  final String label;
  final bool selected;
  final bool locked;
  final Widget? leading;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final Color primary = theme.colorScheme.primary;
    final Color background =
        selected
            ? primary
            : Color.alphaBlend(
              primary.withValues(alpha: 0.06),
              theme.colorScheme.surface,
            );

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.pill),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: compact ? AppSpacing.xs : AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(
            color: selected ? primary : theme.colorScheme.outlineVariant,
          ),
          boxShadow:
              selected
                  ? <BoxShadow>[
                    BoxShadow(
                      color: primary.withValues(alpha: 0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : const <BoxShadow>[],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (leading != null) ...<Widget>[
              IconTheme(
                data: IconThemeData(
                  size: AppIconSize.small,
                  color: selected ? Colors.white : theme.colorScheme.onSurface,
                ),
                child: leading!,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: (compact
                      ? theme.textTheme.bodySmall
                      : theme.textTheme.bodyMedium)
                  ?.copyWith(
                    color:
                        selected ? Colors.white : theme.colorScheme.onSurface,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            if (locked) ...<Widget>[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.lock_rounded,
                size: AppIconSize.small,
                color:
                    selected ? Colors.white : theme.textTheme.bodySmall?.color,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
