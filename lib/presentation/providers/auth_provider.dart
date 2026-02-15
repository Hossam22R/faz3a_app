import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository) {
    _subscription = _authRepository.authStateChanges().listen(
      (UserModel? user) {
        _currentUser = user;
        notifyListeners();
      },
      onError: (Object error) {
        _errorMessage = error.toString();
        notifyListeners();
      },
    );
    _loadCurrentUser();
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<UserModel?> _subscription;

  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> _loadCurrentUser() async {
    try {
      _currentUser = await _authRepository.getCurrentUser();
      notifyListeners();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> login({
    required String phone,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(phone: phone, password: password);
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    UserType userType = UserType.customer,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(
        fullName: fullName,
        email: email,
        phone: phone,
        password: password,
        userType: userType,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authRepository.logout();
      _currentUser = null;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateProfile({
    required String fullName,
    required String email,
    required String phone,
  }) async {
    final UserModel? existing = _currentUser;
    if (existing == null) {
      _errorMessage = 'No authenticated user.';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final UserModel updated = existing.copyWith(
        fullName: fullName.trim(),
        email: email.trim(),
        phone: phone.trim(),
        updatedAt: DateTime.now(),
      );
      await _authRepository.updateUserProfile(updated);
      _currentUser = updated;
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> sendPasswordResetEmail(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authRepository.sendPasswordResetEmail(email);
      return true;
    } catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
