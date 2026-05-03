import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Translates any error (Firestore, state, argument, or generic) into a
/// user-facing message.
///
/// In debug mode the Firebase error code and server message are appended
/// so developers can diagnose rule failures, missing indexes, etc. without
/// recompiling. In release mode only the user-friendly message is shown.
String firestoreErrorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }

  if (error is FirebaseException) {
    final userMessage = switch (error.code) {
      'permission-denied' =>
        "You don't have permission to do that. "
            'If this keeps happening, please contact support.',
      'unavailable' =>
        "We're having trouble connecting. "
            'Please check your internet and try again.',
      'deadline-exceeded' =>
        'The request timed out. Please try again.',
      'resource-exhausted' =>
        "We're experiencing high traffic. "
            'Please try again in a moment.',
      'unauthenticated' => 'Please sign in again to continue.',
      'not-found' => "The data you're looking for no longer exists.",
      'already-exists' => 'This already exists.',
      'aborted' => 'The operation could not be completed. Please try again.',
      _ => 'Something went wrong. Please try again.',
    };

    if (kDebugMode) {
      return '$userMessage\n\n[DEBUG Firestore ${error.code}] ${error.message}';
    }
    return userMessage;
  }

  if (error case StateError(:final message)) {
    return message.isNotEmpty ? message : 'Something went wrong.';
  }

  if (error case ArgumentError(:final message)) {
    // ignore: avoid_dynamic_calls
    return message.isNotEmpty ? message : 'Something went wrong.';
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
