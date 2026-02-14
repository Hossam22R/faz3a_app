import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/auth_repository.dart';

class AuthSession extends ChangeNotifier {
  AuthSession(this._authRepository) {
    _subscription = _authRepository.authStateChanges().listen(
      (UserModel? user) {
        _currentUser = user;
        _isReady = true;
        notifyListeners();
      },
      onError: (_) {
        _currentUser = null;
        _isReady = true;
        notifyListeners();
      },
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<UserModel?> _subscription;

  UserModel? _currentUser;
  bool _isReady = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  bool get isReady => _isReady;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
