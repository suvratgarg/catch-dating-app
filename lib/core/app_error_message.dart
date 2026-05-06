import 'package:catch_dating_app/auth/presentation/auth_error_message.dart';
import 'package:catch_dating_app/core/firestore_error_message.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_auth/firebase_auth.dart';

enum AppErrorContext {
  generic,
  dashboard,
  profile,
  run,
  club,
  chat,
  payments,
  auth,
}

String appErrorMessage(
  Object error, {
  AppErrorContext context = AppErrorContext.generic,
}) {
  if (error is FirebaseAuthException || context == AppErrorContext.auth) {
    return authErrorMessage(error);
  }
  return firestoreErrorMessage(error);
}

String appErrorTitle(
  Object error, {
  AppErrorContext context = AppErrorContext.generic,
}) {
  if (_isNetworkError(error)) return 'Connection issue';
  if (_isAuthError(error)) return 'Sign in required';
  if (_isPermissionError(error)) return 'Action unavailable';
  if (_isNotFoundError(error)) return _notFoundTitle(context);

  return switch (context) {
    AppErrorContext.dashboard => 'Dashboard unavailable',
    AppErrorContext.profile => 'Profile unavailable',
    AppErrorContext.run => 'Run unavailable',
    AppErrorContext.club => 'Club unavailable',
    AppErrorContext.chat => 'Messages unavailable',
    AppErrorContext.payments => 'Payments unavailable',
    AppErrorContext.auth => 'Sign in problem',
    AppErrorContext.generic => 'Something went wrong',
  };
}

bool _isNetworkError(Object error) {
  if (error is NetworkException) return true;
  if (error is FirebaseException) {
    return switch (error.code) {
      'unavailable' ||
      'deadline-exceeded' ||
      'resource-exhausted' ||
      'network-request-failed' => true,
      _ => false,
    };
  }
  return false;
}

bool _isAuthError(Object error) =>
    error is SignInRequiredException ||
    error is FirebaseAuthException ||
    (error is FirebaseException && error.code == 'unauthenticated');

bool _isPermissionError(Object error) =>
    error is PermissionException ||
    (error is FirebaseException && error.code == 'permission-denied');

bool _isNotFoundError(Object error) =>
    error is DocumentNotFoundException ||
    (error is FirebaseException && error.code == 'not-found');

String _notFoundTitle(AppErrorContext context) {
  return switch (context) {
    AppErrorContext.profile => 'Profile not found',
    AppErrorContext.run => 'Run not found',
    AppErrorContext.club => 'Club not found',
    AppErrorContext.chat => 'Chat not found',
    AppErrorContext.payments => 'Payment not found',
    _ => 'Not found',
  };
}
