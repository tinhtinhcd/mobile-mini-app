import 'package:flutter/material.dart';

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
    if (icon == null) {
      return FilledButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon!,
      label: Text(label),
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
    if (icon == null) {
      return OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: icon!,
      label: Text(label),
    );
  }
}

