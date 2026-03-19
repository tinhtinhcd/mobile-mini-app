import 'dart:io';

final Directory _root = Directory.current;

Future<void> main(List<String> args) async {
  final Map<String, String> supportedApps = _discoverIconConfigs();
  final List<String> targets =
      args.isEmpty ? supportedApps.keys.toList() : args;
  final List<String> unknown =
      targets.where((String app) => !supportedApps.containsKey(app)).toList();

  if (unknown.isNotEmpty) {
    stderr.writeln('Unknown app(s): ${unknown.join(', ')}');
    stderr.writeln('Supported apps: ${supportedApps.keys.join(', ')}');
    exitCode = 64;
    return;
  }

  for (final String app in targets) {
    final String configPath = supportedApps[app]!;
    final Directory appDirectory = Directory('${_root.path}/apps/$app');

    stdout.writeln('Generating launcher icons for $app...');
    final ProcessResult result = await Process.run(
      'dart',
      <String>['run', 'flutter_launcher_icons', '-f', '../../$configPath'],
      workingDirectory: appDirectory.path,
      runInShell: true,
    );

    stdout.write(result.stdout);
    stderr.write(result.stderr);

    if (result.exitCode != 0) {
      stderr.writeln('Icon generation failed for $app.');
      exit(result.exitCode);
    }
  }
}

Map<String, String> _discoverIconConfigs() {
  final Directory brandingDirectory = Directory('${_root.path}/branding');
  final Map<String, String> configs = <String, String>{};

  if (!brandingDirectory.existsSync()) {
    return configs;
  }

  for (final FileSystemEntity entity in brandingDirectory.listSync()) {
    if (entity is! Directory) {
      continue;
    }

    final String appName =
        entity.uri.pathSegments
            .where((String segment) => segment.isNotEmpty)
            .last;
    final File configFile = File('${entity.path}/flutter_launcher_icons.yaml');
    final Directory appDirectory = Directory('${_root.path}/apps/$appName');

    if (configFile.existsSync() && appDirectory.existsSync()) {
      configs[appName] = 'branding/$appName/flutter_launcher_icons.yaml';
    }
  }

  return configs;
}
