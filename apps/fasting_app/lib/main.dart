import 'package:app_core/app_core.dart';
import 'package:fasting_app/app_config.dart';
import 'package:fasting_app/src/application/fasting_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:storage/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final SharedPreferencesTimerSnapshotStore snapshotStore =
      await SharedPreferencesTimerSnapshotStore.create(
    storageKey: 'fasting_app.timer_snapshot',
  );
  final restoredSnapshot = await snapshotStore.readSnapshot();

  runApp(
    ProviderScope(
      overrides: [
        fastingSnapshotStoreProvider.overrideWith((_) => snapshotStore),
        fastingRestoredSnapshotProvider.overrideWith((_) => restoredSnapshot),
      ],
      child: const FastingAppEntry(),
    ),
  );
}

class FastingAppEntry extends StatelessWidget {
  const FastingAppEntry({super.key});

  @override
  Widget build(BuildContext context) {
    return FactoryApp(definition: buildFastingAppDefinition());
  }
}
