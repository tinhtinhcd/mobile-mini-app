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
      minimumSize: const Size.fromHeight(54),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
      minimumSize: const Size.fromHeight(46),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
