abstract class StorageService {
  Future<String> uploadFile({
    required String path,
    required List<int> bytes,
  });
}
