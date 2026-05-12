import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

String backendErrorMessage(Object error) {
  final message = _backendErrorMessage(error);
  final debug = _debugMessage(error);
  if (kDebugMode && debug != null && debug.isNotEmpty) {
    return '$message\n\n[DEBUG] $debug';
  }
  return message;
}

String _backendErrorMessage(Object error) {
  if (error is AppException) {
    return error.message;
  }

  if (error is FirebaseException) {
    return normalizeBackendError(
      error,
      context: backendContextForFirebaseException(error),
    ).message;
  }

  if (error case StateError(:final message)) {
    return message.isNotEmpty ? message : 'Something went wrong.';
  }

  if (error is ArgumentError) {
    final message = error.message;
    return message is String && message.isNotEmpty
        ? message
        : 'Something went wrong.';
  }

  return _stripCommonErrorPrefix(error.toString());
}

String? _debugMessage(Object error) {
  if (error case AppException(:final debugMessage)) {
    return debugMessage;
  }
  if (error is FirebaseException) {
    return '${error.plugin}/${error.code}'
        '${error.message == null ? '' : ': ${error.message}'}';
  }
  return null;
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
