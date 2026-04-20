import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../config/app_constants.dart';

class ErrorMapper {
  static String toMessage(Object error) {
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
    return text;
  }
}
