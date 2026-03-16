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
