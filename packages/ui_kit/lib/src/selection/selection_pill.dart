import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

class SelectionPill extends StatelessWidget {
  const SelectionPill({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.locked = false,
    this.leading,
  });

  final String label;
  final bool selected;
  final bool locked;
  final Widget? leading;
  final VoidCallback onTap;

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
      borderRadius: BorderRadius.circular(999),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? primary : theme.colorScheme.outlineVariant,
          ),
          boxShadow:
              selected
                  ? <BoxShadow>[
                    BoxShadow(
                      color: primary.withValues(alpha: 0.18),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
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
                  size: 16,
                  color: selected ? Colors.white : theme.colorScheme.onSurface,
                ),
                child: leading!,
              ),
              const SizedBox(width: AppSpacing.xs),
            ],
            Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: selected ? Colors.white : theme.colorScheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (locked) ...<Widget>[
              const SizedBox(width: AppSpacing.xs),
              Icon(
                Icons.lock_rounded,
                size: 16,
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
