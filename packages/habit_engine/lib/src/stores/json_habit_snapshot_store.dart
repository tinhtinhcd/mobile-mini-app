import 'package:habit_engine/src/models/habit_snapshot.dart';
import 'package:habit_engine/src/stores/habit_snapshot_store.dart';
import 'package:storage/storage.dart';

class JsonHabitSnapshotStore implements HabitSnapshotStore {
  JsonHabitSnapshotStore({
    required Future<JsonObjectStore> Function() storeLoader,
  }) : _storeLoader = storeLoader;

  final Future<JsonObjectStore> Function() _storeLoader;
  JsonObjectStore? _store;
  Future<JsonObjectStore>? _storeFuture;

  Future<JsonObjectStore> _resolveStore() {
    final JsonObjectStore? store = _store;
    if (store != null) {
      return Future<JsonObjectStore>.value(store);
    }

    return _storeFuture ??= _createStore();
  }

  Future<JsonObjectStore> _createStore() async {
    final JsonObjectStore store = await _storeLoader();
    _store = store;
    return store;
  }

  @override
  Future<void> clearSnapshot() async {
    final JsonObjectStore store = await _resolveStore();
    await store.clearObject();
  }

  @override
  Future<HabitSnapshot?> readSnapshot() async {
    final JsonObjectStore store = await _resolveStore();
    final Map<String, dynamic>? json = await store.readObject();
    if (json == null) {
      return null;
    }

    try {
      return HabitSnapshot.fromJson(json);
    } catch (_) {
      await store.clearObject();
      return null;
    }
  }

  @override
  Future<void> writeSnapshot(HabitSnapshot snapshot) async {
    final JsonObjectStore store = await _resolveStore();
    await store.writeObject(snapshot.toJson());
  }
}
