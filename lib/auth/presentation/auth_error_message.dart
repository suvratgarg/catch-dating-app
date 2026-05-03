import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Returns a user-facing message for errors that occur during profile save /
/// Firestore write operations (not auth-specific).
///
/// Delegates to [firestoreErrorMessage] for [FirebaseException] and
/// [AppException] so Firestore-specific codes like `permission-denied`
/// get user-friendly translations.
String generalErrorMessage(Object error) {
  if (error is FirebaseException || error is AppException) {
    return firestoreErrorMessage(error);
  }
  if (error is StateError) {
    return error.message.isNotEmpty ? error.message : 'Something went wrong.';
  }
  if (error is ArgumentError) {
    return error.message.isNotEmpty ? error.message : 'Something went wrong.';
  }

  return _stripCommonErrorPrefix(error.toString());
}

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-phone-number' => 'Please enter a valid phone number.',
      'invalid-verification-code' => 'That code is invalid. Please try again.',
      'session-expired' ||
      'code-expired' => 'That code expired. Please request a new one.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait a bit and try again.',
      'user-disabled' => 'This account has been disabled.',
      'internal-error' =>
        'Unable to reach authentication services. If this is a dev build, '
        'check that your App Check debug token is registered in Firebase '
        'Console and exported as FIREBASE_APP_CHECK_DEBUG_TOKEN.',
      _ => error.message ?? 'Something went wrong. Please try again.',
    };
  }

  return _stripCommonErrorPrefix(error.toString());
}

String _stripCommonErrorPrefix(String message) {
  const prefixes = <String>[
    'Exception: ',
    'Bad state: ',
    'Invalid argument(s): ',
  ];

  for (final prefix in prefixes) {
    if (message.startsWith(prefix)) {
      return message.substring(prefix.length);
    }
  }

  return message;
}
