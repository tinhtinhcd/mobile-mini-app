import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

typedef AppDrawerSelection = void Function(BuildContext context);
typedef AppDrawerPlaceholderBuilder =
    AppDrawerPlaceholderSpec Function(BuildContext context);

@immutable
class AppDrawerDestination {
  const AppDrawerDestination.action({
    required this.label,
    required this.icon,
    required AppDrawerSelection onSelected,
  }) : _onSelected = onSelected,
       _placeholderBuilder = null;

  const AppDrawerDestination.placeholder({
    required this.label,
    required this.icon,
    required AppDrawerPlaceholderBuilder placeholderBuilder,
  }) : _onSelected = null,
       _placeholderBuilder = placeholderBuilder;

  final String label;
  final IconData icon;
  final AppDrawerSelection? _onSelected;
  final AppDrawerPlaceholderBuilder? _placeholderBuilder;

  void select(BuildContext context) {
    final AppDrawerSelection? onSelected = _onSelected;
    if (onSelected != null) {
      onSelected(context);
      return;
    }

    final AppDrawerPlaceholderBuilder? placeholderBuilder = _placeholderBuilder;
    if (placeholderBuilder == null) {
      return;
    }

    showAppDrawerPlaceholder(context, spec: placeholderBuilder(context));
  }
}

@immutable
class AppDrawerPlaceholderSpec {
  const AppDrawerPlaceholderSpec({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

Future<void> showAppDrawerPlaceholder(
  BuildContext context, {
  required AppDrawerPlaceholderSpec spec,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (BuildContext context) {
      final ThemeData theme = Theme.of(context);
      return SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.sm,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(spec.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(spec.description, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      );
    },
  );
}
