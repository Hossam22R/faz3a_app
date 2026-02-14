abstract class LocalDataSource {
  Future<void> writeString({
    required String key,
    required String value,
  });

  Future<String?> readString(String key);
}
