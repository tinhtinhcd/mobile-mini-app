import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/src/timer_snapshot_store.dart';
import 'package:timer_engine/timer_engine.dart';

class SharedPreferencesTimerSnapshotStore implements TimerSnapshotStore {
  static Future<SharedPreferencesTimerSnapshotStore> create({
    required String storageKey,
  }) async {
    final SharedPreferences preferences =
        await SharedPreferences.getInstance();
    return SharedPreferencesTimerSnapshotStore(
      preferences,
      storageKey: storageKey,
    );
  }

  SharedPreferencesTimerSnapshotStore(
    this._preferences, {
    required this.storageKey,
  });

  final SharedPreferences _preferences;
  final String storageKey;

  @override
  Future<void> clearSnapshot() async {
    await _preferences.remove(storageKey);
  }

  @override
  Future<TimerSnapshot?> readSnapshot() async {
    final String? encoded = _preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(encoded);
      if (decoded is! Map<Object?, Object?>) {
        await clearSnapshot();
        return null;
      }

      return TimerSnapshot.fromJson(
        decoded.map(
          (Object? key, Object? value) => MapEntry(key.toString(), value),
        ),
      );
    } catch (_) {
      await clearSnapshot();
      return null;
    }
  }

  @override
  Future<void> writeSnapshot(TimerSnapshot snapshot) async {
    await _preferences.setString(
      storageKey,
      jsonEncode(snapshot.toJson()),
    );
  }
}
