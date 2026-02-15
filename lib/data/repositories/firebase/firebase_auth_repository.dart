import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/errors/exceptions.dart';
import '../../data_sources/remote/firebase_data_source.dart';
import '../../models/user_model.dart';
import '../auth_repository.dart';
import 'firebase_demo_store.dart';
import 'firebase_repository_utils.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseDataSource dataSource,
    FirebaseAuth? auth,
  })  : _dataSource = dataSource,
        _auth = auth;

  final FirebaseDataSource _dataSource;
  final FirebaseAuth? _auth;

  FirebaseAuth get auth => _auth ?? FirebaseAuth.instance;

  @override
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
    UserType userType = UserType.customer,
  }) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final String normalizedEmail = email.trim().toLowerCase();
      final String normalizedPhone = phone.trim();

      final bool emailTaken = FirebaseDemoStore.usersById.values.any(
        (UserModel user) => user.email.toLowerCase() == normalizedEmail,
      );
      if (emailTaken) {
        throw const AuthException('Email is already in use.');
      }
      final bool phoneTaken = FirebaseDemoStore.usersById.values.any(
        (UserModel user) => user.phone.trim() == normalizedPhone,
      );
      if (phoneTaken) {
        throw const AuthException('Phone number is already in use.');
      }

      final UserModel userModel = UserModel(
        id: 'demo-user-${DateTime.now().microsecondsSinceEpoch}',
        fullName: fullName,
        email: normalizedEmail,
        phone: normalizedPhone,
        userType: userType,
        isVerified: true,
        isActive: true,
        createdAt: DateTime.now(),
        isApproved: userType == UserType.vendor ? false : null,
      );
      FirebaseDemoStore.usersById[userModel.id] = userModel;
      FirebaseDemoStore.passwordsByUserId[userModel.id] = password;
      FirebaseDemoStore.setCurrentUser(userModel);
      return userModel;
    }

    try {
      final UserCredential credential = await auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final User? firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw const AuthException('Registration failed: no user returned.');
      }

      await firebaseUser.updateDisplayName(fullName);

      final UserModel userModel = UserModel(
        id: firebaseUser.uid,
        fullName: fullName,
        email: email.trim(),
        phone: phone.trim(),
        userType: userType,
        isVerified: firebaseUser.emailVerified,
        isActive: true,
        createdAt: DateTime.now(),
        isApproved: userType == UserType.vendor ? false : null,
      );

      await _dataSource.usersCollection().doc(firebaseUser.uid).set(
        <String, dynamic>{
          ...userModel.toJson(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      return userModel;
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Registration failed.',
        code: error.code,
      );
    }
  }

  @override
  Future<UserModel> login({
    required String phone,
    required String password,
  }) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final String normalized = phone.trim();
      late final UserModel matchedUser;
      if (normalized.contains('@')) {
        matchedUser = FirebaseDemoStore.usersById.values.firstWhere(
          (UserModel user) => user.email.toLowerCase() == normalized.toLowerCase(),
          orElse: () => _emptyUser,
        );
      } else {
        matchedUser = FirebaseDemoStore.usersById.values.firstWhere(
          (UserModel user) => user.phone.trim() == normalized,
          orElse: () => _emptyUser,
        );
      }

      if (matchedUser.id == _emptyUser.id) {
        throw const AuthException('No user found for this account.');
      }

      final String? storedPassword = FirebaseDemoStore.passwordsByUserId[matchedUser.id];
      if (storedPassword != password) {
        throw const AuthException('Incorrect password.');
      }
      FirebaseDemoStore.setCurrentUser(matchedUser);
      return matchedUser;
    }

    final String normalized = phone.trim();
    final String email = await _resolveEmail(normalized);

    try {
      final UserCredential credential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;
      if (user == null) {
        throw const AuthException('Authentication failed: no user returned.');
      }

      final UserModel? profile = await _loadUserProfileById(user.uid);
      return profile ?? _buildFallbackUserModel(user);
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Authentication failed.',
        code: error.code,
      );
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      return FirebaseDemoStore.currentUser;
    }
    final User? user = auth.currentUser;
    if (user == null) {
      return null;
    }
    final UserModel? profile = await _loadUserProfileById(user.uid);
    return profile ?? _buildFallbackUserModel(user);
  }

  @override
  Stream<UserModel?> authStateChanges() {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      return Stream<UserModel?>.multi((StreamController<UserModel?> controller) {
        controller.add(FirebaseDemoStore.currentUser);
        final subscription = FirebaseDemoStore.authStateController.stream.listen(
          controller.add,
          onError: controller.addError,
        );
        controller.onCancel = subscription.cancel;
      });
    }
    return auth.authStateChanges().asyncMap((User? user) async {
      if (user == null) {
        return null;
      }
      final UserModel? profile = await _loadUserProfileById(user.uid);
      return profile ?? _buildFallbackUserModel(user);
    });
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      final bool exists = FirebaseDemoStore.usersById.values.any(
        (UserModel user) => user.email.toLowerCase() == email.trim().toLowerCase(),
      );
      if (!exists) {
        throw const AuthException('No user found for this email.');
      }
      return;
    }
    try {
      await auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (error) {
      throw AuthException(
        error.message ?? 'Password reset failed.',
        code: error.code,
      );
    }
  }

  @override
  Future<void> updateUserProfile(UserModel user) async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.ensureInitialized();
      if (!FirebaseDemoStore.usersById.containsKey(user.id)) {
        throw const AuthException('No authenticated user found.');
      }
      FirebaseDemoStore.usersById[user.id] = user;
      if (FirebaseDemoStore.currentUser?.id == user.id) {
        FirebaseDemoStore.setCurrentUser(user);
      }
      return;
    }
    await _dataSource.usersCollection().doc(user.id).set(
      <String, dynamic>{
        ...user.toJson(),
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }

  @override
  Future<void> logout() async {
    if (!isFirebaseReady) {
      FirebaseDemoStore.setCurrentUser(null);
      return;
    }
    await auth.signOut();
  }

  static final UserModel _emptyUser = UserModel(
    id: '__empty__',
    fullName: '',
    email: '',
    phone: '',
    userType: UserType.customer,
    createdAt: DateTime(2000),
  );

  Future<String> _resolveEmail(String phoneOrEmail) async {
    if (phoneOrEmail.contains('@')) {
      return phoneOrEmail;
    }

    final userSnapshot =
        await _dataSource.usersCollection().where('phone', isEqualTo: phoneOrEmail).limit(1).get();
    if (userSnapshot.docs.isEmpty) {
      throw const AuthException(
        'No user found for this phone number. Use email login or register first.',
      );
    }

    final Map<String, dynamic> data = userSnapshot.docs.first.data();
    final dynamic email = data['email'];
    if (email is! String || email.isEmpty) {
      throw const AuthException('This account has no email associated for password login.');
    }
    return email;
  }

  Future<UserModel?> _loadUserProfileById(String uid) async {
    final doc = await _dataSource.usersCollection().doc(uid).get();
    if (!doc.exists) {
      return null;
    }
    final data = doc.data();
    if (data == null) {
      return null;
    }
    final Map<String, dynamic> json = <String, dynamic>{
      ...data,
      'id': data['id'] ?? doc.id,
    };
    return UserModel.fromJson(json);
  }

  UserModel _buildFallbackUserModel(User user) {
    return UserModel(
      id: user.uid,
      fullName: user.displayName ?? 'Nema User',
      email: user.email ?? '',
      phone: user.phoneNumber ?? '',
      photoUrl: user.photoURL,
      userType: UserType.customer,
      isVerified: user.emailVerified,
      createdAt: user.metadata.creationTime ?? DateTime.now(),
      updatedAt: user.metadata.lastSignInTime,
    );
  }
}
