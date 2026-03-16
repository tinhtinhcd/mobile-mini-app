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
    final Widget button;

    if (icon == null) {
      button = FilledButton(
        onPressed: onPressed,
        child: Text(label),
      );
    } else {
      button = FilledButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: button,
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
    final Widget button;

    if (icon == null) {
      button = OutlinedButton(
        onPressed: onPressed,
        child: Text(label),
      );
    } else {
      button = OutlinedButton.icon(
        onPressed: onPressed,
        icon: icon!,
        label: Text(label),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: button,
    );
  }
}
