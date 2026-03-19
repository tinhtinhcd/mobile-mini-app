import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:storage/src/json_object_store.dart';

class SharedPreferencesJsonObjectStore implements JsonObjectStore {
  static Future<SharedPreferencesJsonObjectStore> create({
    required String storageKey,
  }) async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    return SharedPreferencesJsonObjectStore(
      preferences,
      storageKey: storageKey,
    );
  }

  SharedPreferencesJsonObjectStore(
    this._preferences, {
    required this.storageKey,
  });

  final SharedPreferences _preferences;
  final String storageKey;

  @override
  Future<void> clearObject() async {
    await _preferences.remove(storageKey);
  }

  @override
  Future<Map<String, dynamic>?> readObject() async {
    final String? encoded = _preferences.getString(storageKey);
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      final Object? decoded = jsonDecode(encoded);
      if (decoded is! Map<Object?, Object?>) {
        await clearObject();
        return null;
      }

      return decoded.map(
        (Object? key, Object? value) => MapEntry(key.toString(), value),
      );
    } catch (_) {
      await clearObject();
      return null;
    }
  }

  @override
  Future<void> writeObject(Map<String, dynamic> object) async {
    await _preferences.setString(storageKey, jsonEncode(object));
  }
}
