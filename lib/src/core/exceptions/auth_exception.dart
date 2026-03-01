

import 'package:smart_iot_app/src/core/exceptions/app_exception.dart';

/// All authentication related errors
import 'package:firebase_auth/firebase_auth.dart';

class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });

  /// Map FirebaseAuthException → AuthException
  factory AuthException.fromFirebase(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException(
          message: 'No account found with this email.',
          code: e.code,
        );

      case 'wrong-password':
        return AuthException(
          message: 'Incorrect password.',
          code: e.code,
        );

      case 'email-already-in-use':
        return AuthException(
          message: 'Email is already registered.',
          code: e.code,
        );

      case 'weak-password':
        return AuthException(
          message: 'Password is too weak.',
          code: e.code,
        );

      case 'network-request-failed':
        return AuthException(
          message: 'Network error. Please check your connection.',
          code: e.code,
        );

      default:
        return AuthException(
          message: e.message ?? 'Authentication failed.',
          code: e.code,
        );
    }
  }
}
