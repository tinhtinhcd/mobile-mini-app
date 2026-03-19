abstract class JsonObjectStore {
  Future<Map<String, dynamic>?> readObject();

  Future<void> writeObject(Map<String, dynamic> object);

  Future<void> clearObject();
}
