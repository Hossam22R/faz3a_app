import '../models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel> login({
    required String phone,
    required String password,
  });

  Future<void> logout();
}
