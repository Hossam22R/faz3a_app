import 'package:flutter_test/flutter_test.dart';
import 'package:nema_store/data/models/user_model.dart';
import 'package:nema_store/data/repositories/auth_repository.dart';
import 'package:nema_store/presentation/providers/auth_provider.dart';

class _FakeAuthRepository implements AuthRepository {
  _FakeAuthRepository(this._currentUser);

  UserModel? _currentUser;

  @override
  Stream<UserModel?> authStateChanges() {
    return Stream<UserModel?>.value(_currentUser);
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    if (_currentUser != null) {
      return _currentUser!;
    }
    throw Exception('No user');
  }

  @override
  Future<void> logout() async {
    _currentUser = null;
  }

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    UserType userType = UserType.customer,
  }) async {
    _currentUser = UserModel(
      id: 'new-user',
      fullName: fullName,
      email: email,
      phone: phone,
      userType: userType,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> updateUserProfile(UserModel user) async {
    _currentUser = user;
  }
}

void main() {
  group('AuthProvider profile update', () {
    test('updates current user profile fields', () async {
      final UserModel seed = UserModel(
        id: 'u1',
        fullName: 'Old Name',
        email: 'old@test.com',
        phone: '07000000000',
        userType: UserType.customer,
        createdAt: DateTime.now(),
      );
      final _FakeAuthRepository repository = _FakeAuthRepository(seed);
      final AuthProvider provider = AuthProvider(repository);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(provider.currentUser?.fullName, 'Old Name');

      final bool ok = await provider.updateProfile(
        fullName: 'New Name',
        email: 'new@test.com',
        phone: '07111111111',
      );

      expect(ok, isTrue);
      expect(provider.currentUser?.fullName, 'New Name');
      expect(provider.currentUser?.email, 'new@test.com');
      expect(provider.currentUser?.phone, '07111111111');
    });
  });
}
