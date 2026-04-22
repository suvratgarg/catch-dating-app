import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'email-already-in-use' => 'An account already exists for that email.',
      'invalid-credential' || 'wrong-password' || 'user-not-found' =>
        'Incorrect email or password.',
      'invalid-email' => 'Please enter a valid email address.',
      'network-request-failed' =>
        'Check your internet connection and try again.',
      'operation-not-allowed' => 'This sign-in method is not enabled.',
      'too-many-requests' =>
        'Too many attempts. Please wait a bit and try again.',
      'user-disabled' => 'This account has been disabled.',
      'weak-password' => 'Password must be at least 6 characters.',
      _ => error.message ?? 'Something went wrong. Please try again.',
    };
  }

  final message = error.toString();
  const exceptionPrefix = 'Exception: ';
  if (message.startsWith(exceptionPrefix)) {
    return message.substring(exceptionPrefix.length);
  }
  return message;
}
