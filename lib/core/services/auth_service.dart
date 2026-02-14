abstract class AuthService {
  Future<String?> getCurrentUserId();
  Future<void> signOut();
}
