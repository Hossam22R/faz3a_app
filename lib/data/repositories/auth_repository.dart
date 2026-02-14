import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    UserType userType = UserType.customer,
  });

  Future<UserModel> login({
    required String phone,
    required String password,
  });

  Future<UserModel?> getCurrentUser();
  Stream<UserModel?> authStateChanges();
  Future<void> updateUserProfile(UserModel user);

  Future<void> sendPasswordResetEmail(String email);
  Future<void> logout();
}
