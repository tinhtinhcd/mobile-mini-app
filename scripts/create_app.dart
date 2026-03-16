import 'dart:io';

const String _usage = '''
Usage:
  dart run scripts/create_app.dart <app_name> [--title="Display Name"] [--force]

Example:
  dart run scripts/create_app.dart habit_timer_app
''';

const List<int> _accentPalette = <int>[
  0xFFE4572E,
  0xFF1D8A6B,
  0xFF3B6EA8,
  0xFF8B5CF6,
  0xFFF59E0B,
  0xFFEC4899,
];

void main(List<String> arguments) {
  if (arguments.isEmpty || arguments.contains('--help')) {
    stdout.write(_usage);
    exit(arguments.isEmpty ? 64 : 0);
  }

  final String appName = arguments.first.trim();
  final bool force = arguments.contains('--force');
  final String? explicitTitle = _readOption(arguments, '--title');

  final RegExp namePattern = RegExp(r'^[a-z][a-z0-9_]*_app$');
  if (!namePattern.hasMatch(appName)) {
    stderr.writeln(
      'Invalid app name "$appName". Expected snake_case ending with "_app".',
    );
    exit(64);
  }

  final String title =
      explicitTitle?.trim().isNotEmpty == true
          ? explicitTitle!.trim()
          : _displayNameFromAppName(appName);
  final String screenClass = '${_pascalCase(appName)}Screen';
  final String readmeTitle = title;
  final String screenFileName = '${appName}_screen.dart';
  final String accentHex = _accentHexForApp(appName);
  final String idea = _ideaForApp(title);

  final Directory appDirectory = Directory('apps/$appName');
  final Directory libDirectory = Directory('${appDirectory.path}/lib');
  final Directory screenDirectory = Directory(
    '${libDirectory.path}/src/presentation',
  );

  appDirectory.createSync(recursive: true);
  screenDirectory.createSync(recursive: true);

  _writeFile(
    '${appDirectory.path}/pubspec.yaml',
    _pubspecTemplate(appName),
    force: force,
  );
  _writeFile(
    '${libDirectory.path}/main.dart',
    _mainTemplate(appName),
    force: force,
  );
  _writeFile(
    '${libDirectory.path}/app_config.dart',
    _appConfigTemplate(
      appName: appName,
      title: title,
      accentHex: accentHex,
      screenFileName: screenFileName,
      screenClass: screenClass,
    ),
    force: force,
  );
  _writeFile(
    '${screenDirectory.path}/$screenFileName',
    _screenTemplate(title: title, appName: appName, screenClass: screenClass),
    force: force,
  );
  _writeReadme(
    '${appDirectory.path}/README.md',
    _readmeTemplate(
      readmeTitle: readmeTitle,
      idea: idea,
      keyword: _keywordFromTitle(title),
    ),
  );

  stdout.writeln('Scaffolded apps/$appName');
  stdout.writeln('');
  stdout.writeln('Next steps:');
  stdout.writeln('- Run: cd apps/$appName && flutter pub get');
  stdout.writeln(
    '- Optional: add apps/$appName to the root workspace when you are ready to make it active.',
  );
}

String? _readOption(List<String> arguments, String prefix) {
  for (final String argument in arguments.skip(1)) {
    if (argument.startsWith('$prefix=')) {
      return argument.substring(prefix.length + 1);
    }
  }
  return null;
}

void _writeFile(String path, String content, {required bool force}) {
  final File file = File(path);
  if (file.existsSync()) {
    final String existing = file.readAsStringSync();
    if (existing == content) {
      return;
    }
    if (!force) {
      stderr.writeln('Refusing to overwrite existing file: $path');
      stderr.writeln('Re-run with --force if you want to replace it.');
      exit(2);
    }
  }

  file.writeAsStringSync(content);
}

void _writeReadme(String path, String content) {
  File(path).writeAsStringSync(content);
}

String _pubspecTemplate(String appName) => '''name: $appName
description: Scaffolded placeholder app for the Mobile App Factory monorepo.
version: 0.1.0
publish_to: none

environment:
  sdk: ^3.7.0
  flutter: '>=3.29.0'

dependencies:
  flutter:
    sdk: flutter
  app_core:
    path: ../../packages/app_core
  ui_kit:
    path: ../../packages/ui_kit

dependency_overrides:
  app_core:
    path: ../../packages/app_core

flutter:
  uses-material-design: true
''';

String _mainTemplate(String appName) =>
    '''import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'app_config.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const GeneratedAppEntry());
}

class GeneratedAppEntry extends StatelessWidget {
  const GeneratedAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: build${_pascalCase(appName)}Definition());
  }
}
''';

String _appConfigTemplate({
  required String appName,
  required String title,
  required String accentHex,
  required String screenFileName,
  required String screenClass,
}) => '''import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'src/presentation/$screenFileName';

AppDefinition build${_pascalCase(appName)}Definition() {
  return AppDefinition(
    name: '$appName',
    title: '$title',
    accentColor: const Color($accentHex),
    router: createAppRouter(
      builder: (BuildContext context, state) {
        return const $screenClass();
      },
    ),
  );
}
''';

String _screenTemplate({
  required String title,
  required String appName,
  required String screenClass,
}) => '''import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:ui_kit/ui_kit.dart';

class $screenClass extends StatelessWidget {
  const $screenClass({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryScaffold(
      title: '$title',
      subtitle: 'A scaffolded placeholder app generated for future development.',
      body: const SectionCard(
        title: 'Status',
        subtitle: 'This app is scaffolded but not implemented yet.',
        child: EmptyState(
          title: 'Coming soon',
          message:
              'The initial shell for $appName is ready. Future work can add app-specific flows here.',
          icon: Icons.construction_rounded,
        ),
      ),
    );
  }
}
''';

String _readmeTemplate({
  required String readmeTitle,
  required String idea,
  required String keyword,
}) => '''# $readmeTitle

Idea:
$idea

Primary keyword:
$keyword

Status:
Scaffolded placeholder.

Next implementation suggestion:
- define the core user flow
- decide what shared packages are needed beyond app_core and ui_kit
- replace the placeholder screen with the first real feature surface
''';

String _displayNameFromAppName(String appName) {
  final String trimmed = appName.replaceFirst(RegExp(r'_app$'), '');
  return trimmed
      .split('_')
      .map((String segment) {
        if (segment.isEmpty) {
          return segment;
        }
        return '${segment[0].toUpperCase()}${segment.substring(1)}';
      })
      .join(' ');
}

String _pascalCase(String appName) {
  return appName.split('_').map((String segment) {
    if (segment.isEmpty) {
      return segment;
    }
    return '${segment[0].toUpperCase()}${segment.substring(1)}';
  }).join();
}

String _keywordFromTitle(String title) => title.toLowerCase();

String _ideaForApp(String title) {
  return 'A minimal $title app scaffolded from the shared monorepo template.';
}

String _accentHexForApp(String appName) {
  final int hash = appName.codeUnits.fold<int>(
    0,
    (int value, int codeUnit) => value + codeUnit,
  );
  final int color = _accentPalette[hash % _accentPalette.length];
  return '0x${color.toRadixString(16).toUpperCase()}';
}
