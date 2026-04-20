import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:uuid/uuid.dart';
import 'dart:async';

import '../config/app_constants.dart';
import '../models/user.dart';
import 'firestore_service.dart';

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  User? _currentUser;

  AuthService();

  User? get currentUser => _currentUser;

  bool get isAuthenticated => _currentUser != null;

  User _buildMockUser({
    required String name,
    required String email,
    String? phone,
  }) {
    return User(
      name: name,
      email: email,
      phone: phone,
      avatar: 'https://i.pravatar.cc/150?img=${const Uuid().v4().hashCode}',
    );
  }

  Future<User> signup({
    required String name,
    required String email,
    required String phone,
    required String password,
  }) async {
    if (!FirestoreService.isAvailable) {
      final mockUser = _buildMockUser(name: name, email: email, phone: phone);
      _currentUser = mockUser;
      return mockUser;
    }

    final normalizedEmail = email.trim().toLowerCase();
    final normalizedName = name.trim();

    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('Failed to create user account');
    }

    await firebaseUser.updateDisplayName(normalizedName);
    await firebaseUser.reload();

    final user = User(
      id: firebaseUser.uid,
      name: normalizedName,
      email: normalizedEmail,
      phone: phone.trim(),
      avatar: 'https://i.pravatar.cc/150?img=${firebaseUser.uid.hashCode}',
    );
    await _firestoreService.saveUser(user);
    _currentUser = user;
    return user;
  }

  Future<User> login({required String email, required String password}) async {
    if (!FirestoreService.isAvailable) {
      final mockUser = _buildMockUser(name: email.split('@')[0], email: email);
      _currentUser = mockUser;
      return mockUser;
    }

    final normalizedEmail = email.trim().toLowerCase();

    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: normalizedEmail,
      password: password,
    );

    final firebaseUser = credential.user;
    if (firebaseUser == null) {
      throw Exception('Failed to log in');
    }

    final profile = await _firestoreService.getUserById(firebaseUser.uid);
    final user =
        profile ??
        User(
          id: firebaseUser.uid,
          name:
              (firebaseUser.displayName != null &&
                  firebaseUser.displayName!.trim().isNotEmpty)
              ? firebaseUser.displayName!.trim()
              : normalizedEmail.split('@')[0],
          email: firebaseUser.email ?? normalizedEmail,
          avatar: firebaseUser.photoURL,
        );

    // Persist profile data without delaying navigation after successful login.
    unawaited(_firestoreService.saveUser(user).catchError((_) {}));
    _currentUser = user;
    return user;
  }

  Future<void> logout() async {
    if (FirestoreService.isAvailable) {
      await _firebaseAuth.signOut();
    }
    _currentUser = null;
  }

  String mapAuthError(Object error) {
    if (error is firebase_auth.FirebaseAuthException) {
      switch (error.code) {
        case 'invalid-email':
          return AppConstants.errorInvalidEmail;
        case 'user-disabled':
          return 'This account has been disabled. Contact support.';
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
          return AppConstants.errorInvalidCredentials;
        case 'email-already-in-use':
          return AppConstants.errorEmailAlreadyExists;
        case 'weak-password':
          return AppConstants.errorWeakPassword;
        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';
        case 'network-request-failed':
          return AppConstants.errorNetworkConnection;
        default:
          return error.message ?? 'Authentication failed. Please try again.';
      }
    }

    final text = error.toString();
    if (text.startsWith('Exception: ')) {
      return text.replaceFirst('Exception: ', '').trim();
    }
    return AppConstants.errorServerError;
  }

  Future<User> updateProfile({
    required String name,
    String? phone,
    String? bio,
    String? avatar,
  }) async {
    if (_currentUser == null) {
      throw Exception('User not authenticated');
    }

    final updatedUser = _currentUser!.copyWith(
      name: name,
      phone: phone,
      bio: bio,
      avatar: avatar,
    );

    if (!FirestoreService.isAvailable) {
      _currentUser = updatedUser;
      return updatedUser;
    }

    await _firestoreService.saveUser(updatedUser);
    _currentUser = updatedUser;
    return updatedUser;
  }

  Future<User> getProfile() async {
    if (_currentUser == null) {
      final firebaseUser = _firebaseAuth.currentUser;
      if (firebaseUser == null) {
        throw Exception('User not authenticated');
      }

      final profile = await _firestoreService.getUserById(firebaseUser.uid);
      if (profile != null) {
        _currentUser = profile;
        return profile;
      }

      final fallback = User(
        id: firebaseUser.uid,
        name:
            (firebaseUser.displayName != null &&
                firebaseUser.displayName!.trim().isNotEmpty)
            ? firebaseUser.displayName!.trim()
            : 'User',
        email: firebaseUser.email ?? '',
        avatar: firebaseUser.photoURL,
      );
      await _firestoreService.saveUser(fallback);
      _currentUser = fallback;
      return fallback;
    }

    final profile = await _firestoreService.getUserById(_currentUser!.id);
    if (profile != null) {
      _currentUser = profile;
      return profile;
    }
    return _currentUser!;
  }
}
