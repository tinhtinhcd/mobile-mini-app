import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';
import 'package:widgetbook/widgetbook.dart';

void main() {
  runApp(const FactoryWidgetbook());
}

class FactoryWidgetbook extends StatelessWidget {
  const FactoryWidgetbook({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: <WidgetbookNode>[
        WidgetbookFolder(
          name: 'Buttons',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'Primary Button',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (BuildContext context) {
                    return const AppPrimaryButton(
                      label: 'Start session',
                      icon: Icon(Icons.play_arrow_rounded),
                    );
                  },
                ),
                WidgetbookUseCase(
                  name: 'Secondary',
                  builder: (BuildContext context) {
                    return const AppSecondaryButton(
                      label: 'Reset',
                      icon: Icon(Icons.refresh_rounded),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Stats',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'Stat Tile',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Daily Summary',
                  builder: (BuildContext context) {
                    return const StatTile(
                      label: 'Focus sessions',
                      value: '6',
                      detail: 'Completed today',
                    );
                  },
                ),
                WidgetbookUseCase(
                  name: 'Accent Highlight',
                  builder: (BuildContext context) {
                    return const StatTile(
                      label: 'Tracked hours',
                      value: '12.5h',
                      detail: 'Accumulated fasting time',
                      highlight: Color(0xFF1B8A5A),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Settings',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'Settings Tile',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (BuildContext context) {
                    return const SettingsTile(
                      title: 'Notifications',
                      subtitle: 'Session completion alerts',
                      leading: Icon(Icons.notifications_active_rounded),
                    );
                  },
                ),
                WidgetbookUseCase(
                  name: 'With trailing action',
                  builder: (BuildContext context) {
                    return const SettingsTile(
                      title: 'Premium',
                      subtitle: 'Manage plan and restore purchases',
                      leading: Icon(Icons.workspace_premium_rounded),
                      trailing: Icon(Icons.open_in_new_rounded),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Timer',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'Display Card',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Running',
                  builder: (BuildContext context) {
                    return const TimerDisplayCard(
                      label: 'Focus',
                      timeText: '24:12',
                      progress: 0.42,
                      statusText: 'Focus in progress',
                      footnote: 'Stay with a single task until the timer ends.',
                    );
                  },
                ),
                WidgetbookUseCase(
                  name: 'Paused',
                  builder: (BuildContext context) {
                    return const TimerDisplayCard(
                      label: 'Short break',
                      timeText: '04:40',
                      progress: 0.16,
                      statusText: 'Paused',
                      footnote:
                          'Take a quick reset, then come back with clarity.',
                    );
                  },
                ),
              ],
            ),
            WidgetbookComponent(
              name: 'Selection Pill',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Selected',
                  builder: (BuildContext context) {
                    return SelectionPill(
                      label: 'Focus',
                      selected: true,
                      leading: const Icon(Icons.bolt_rounded),
                      onTap: _noop,
                    );
                  },
                ),
                WidgetbookUseCase(
                  name: 'Locked',
                  builder: (BuildContext context) {
                    return SelectionPill(
                      label: '20:4',
                      selected: false,
                      locked: true,
                      onTap: _noop,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        WidgetbookFolder(
          name: 'Premium',
          children: <WidgetbookNode>[
            WidgetbookComponent(
              name: 'Callout Card',
              useCases: <WidgetbookUseCase>[
                WidgetbookUseCase(
                  name: 'Default',
                  builder: (BuildContext context) {
                    return PremiumCalloutCard(
                      title: 'Premium keeps the experience focused',
                      subtitle:
                          'Remove light banner ads and unlock advanced tools without changing the calm core flow.',
                      actionLabel: 'See premium',
                      onPressed: _noop,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ],
      appBuilder: (BuildContext context, Widget? child) {
        return Theme(
          data: AppTheme.light(const Color(0xFFE4572E)),
          child: Scaffold(
            backgroundColor: AppColors.background,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.xl),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

void _noop() {}
