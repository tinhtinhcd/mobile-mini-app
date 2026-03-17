import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle primaryStyle = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
    );
    final Widget button;

    if (icon == null) {
      button = FilledButton(
        style: primaryStyle,
        onPressed: onPressed,
        child: Text(label),
      );
    } else {
      button = FilledButton.icon(
        style: primaryStyle,
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: button.animate().fadeIn(
        duration: 160.ms,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final ButtonStyle secondaryStyle = OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.sm,
      ),
    );
    final Widget button;

    if (icon == null) {
      button = OutlinedButton(
        style: secondaryStyle,
        onPressed: onPressed,
        child: Text(label),
      );
    } else {
      button = OutlinedButton.icon(
        style: secondaryStyle,
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: button.animate().fadeIn(
        duration: 160.ms,
        curve: Curves.easeOutCubic,
      ),
    );
  }
}
