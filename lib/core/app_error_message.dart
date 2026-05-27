import 'package:catch_dating_app/core/backend_error_message.dart';
import 'package:catch_dating_app/core/backend_error_util.dart';
import 'package:catch_dating_app/core/theme/catch_icons.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

enum AppErrorContext {
  generic,
  dashboard,
  profile,
  event,
  club,
  chat,
  swipes,
  payments,
  auth,
}

@immutable
class AppErrorDescriptor {
  const AppErrorDescriptor({
    required this.title,
    required this.message,
    required this.icon,
    required this.retryLabel,
    required this.retryable,
    required this.severity,
  });

  final String title;
  final String message;
  final IconData icon;
  final String retryLabel;
  final bool retryable;
  final AppErrorSeverity severity;
}

AppErrorDescriptor appErrorDescriptor(
  Object error, {
  AppErrorContext context = AppErrorContext.generic,
}) {
  final appException = _normalizeForPresentation(error);
  return AppErrorDescriptor(
    title: _titleFor(error, appException, context),
    message: _messageFor(error, appException),
    icon: _iconFor(error, appException),
    retryLabel: _retryLabelFor(appException, context),
    retryable: _isRetryable(error, appException),
    severity: appException?.severity ?? AppErrorSeverity.error,
  );
}

String appErrorMessage(
  Object error, {
  AppErrorContext context = AppErrorContext.generic,
}) {
  return appErrorDescriptor(error, context: context).message;
}

String appErrorTitle(
  Object error, {
  AppErrorContext context = AppErrorContext.generic,
}) {
  return appErrorDescriptor(error, context: context).title;
}

AppException? _normalizeForPresentation(Object error) {
  if (error is AppException) return error;
  if (error is FirebaseException) {
    return normalizeBackendError(
      error,
      context: backendContextForFirebaseException(error),
    );
  }
  return null;
}

String _messageFor(Object error, AppException? appException) {
  if (appException == null) return backendErrorMessage(error);
  return appException.message;
}

String _titleFor(
  Object error,
  AppException? appException,
  AppErrorContext context,
) {
  if (_isNetworkError(error, appException)) return 'Connection issue';
  if (_isAuthError(error, appException)) return 'Sign in required';
  if (_isPermissionError(error, appException)) return 'Action unavailable';
  if (_isNotFoundError(error, appException)) return _notFoundTitle(context);
  if (appException is ValidationException) return 'Check your details';
  if (appException is PaymentCancelledException) return 'Payment cancelled';
  if (appException is PaymentVerificationFailedException) {
    return 'Payment verification failed';
  }
  if (appException is PaymentFailedException) return 'Payment failed';
  if (appException is PaidBookingUnsupportedException) {
    return 'Payment unavailable';
  }
  if (appException is EventBookingFailedException) {
    return 'Event signup unavailable';
  }
  if (appException is StorageException) return 'Upload failed';
  if (appException is ExternalActionException) return 'Action failed';
  if (appException is BackendOperationException) {
    final backendContext = appException.context;
    return switch (backendContext?.service) {
      BackendService.appCheck => 'Session verification failed',
      BackendService.messaging => 'Notifications unavailable',
      BackendService.remoteConfig => 'Update check unavailable',
      BackendService.storage => 'Upload failed',
      BackendService.auth => 'Sign in problem',
      BackendService.payments => 'Payment failed',
      _ => _contextTitle(context),
    };
  }

  return _contextTitle(context);
}

String _contextTitle(AppErrorContext context) {
  return switch (context) {
    AppErrorContext.dashboard => 'Dashboard unavailable',
    AppErrorContext.profile => 'Profile unavailable',
    AppErrorContext.event => 'Event unavailable',
    AppErrorContext.club => 'Club unavailable',
    AppErrorContext.chat => 'Messages unavailable',
    AppErrorContext.swipes => 'Catches unavailable',
    AppErrorContext.payments => 'Payments unavailable',
    AppErrorContext.auth => 'Sign in problem',
    AppErrorContext.generic => 'Something went wrong',
  };
}

IconData _iconFor(Object error, AppException? appException) {
  if (_isNetworkError(error, appException)) return CatchIcons.wifiOffRounded;
  if (_isAuthError(error, appException)) return CatchIcons.lockOutlineRounded;
  if (_isPermissionError(error, appException)) return CatchIcons.blockRounded;
  if (_isNotFoundError(error, appException)) return CatchIcons.searchOffRounded;
  if (appException is ValidationException) return CatchIcons.editNoteRounded;
  if (appException is PaymentCancelledException ||
      appException is PaymentFailedException ||
      appException is PaymentVerificationFailedException ||
      appException is PaidBookingUnsupportedException) {
    return CatchIcons.creditCardOffRounded;
  }
  if (appException is EventBookingFailedException) {
    return CatchIcons.directionsRunRounded;
  }
  if (appException is StorageException) {
    return CatchIcons.cloudUploadOutlined;
  }
  if (appException is ExternalActionException) {
    return CatchIcons.openInNewRounded;
  }
  if (appException is BackendOperationException) {
    final backendContext = appException.context;
    return switch (backendContext?.service) {
      BackendService.auth => CatchIcons.lockOutlineRounded,
      BackendService.storage => CatchIcons.cloudUploadOutlined,
      BackendService.messaging => CatchIcons.notificationsOffOutlined,
      BackendService.payments => CatchIcons.creditCardOffRounded,
      BackendService.external => CatchIcons.openInNewRounded,
      _ => CatchIcons.errorOutlineRounded,
    };
  }
  return CatchIcons.errorOutlineRounded;
}

String _retryLabelFor(AppException? appException, AppErrorContext context) {
  if (appException is SignInRequiredException) return 'Sign in';
  if (appException is StorageException) return 'Try upload again';
  if (appException is PaymentFailedException ||
      appException is PaymentVerificationFailedException) {
    return 'Try payment again';
  }
  return switch (context) {
    AppErrorContext.chat => 'Reload messages',
    AppErrorContext.profile => 'Reload profile',
    AppErrorContext.event => 'Reload event',
    AppErrorContext.club => 'Reload club',
    AppErrorContext.swipes => 'Reload catches',
    AppErrorContext.payments => 'Reload payments',
    _ => 'Try again',
  };
}

bool _isRetryable(Object error, AppException? appException) {
  if (appException != null) return appException.retryable;
  if (_isNetworkError(error, appException)) return true;
  // Unknown load failures are still worth retrying when a screen supplies a
  // retry callback; the retry button is not shown unless such a callback exists.
  return true;
}

bool _isNetworkError(Object error, AppException? appException) {
  if (appException is NetworkException) return true;
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

bool _isAuthError(Object error, AppException? appException) =>
    appException is SignInRequiredException ||
    (error is FirebaseException && error.code == 'unauthenticated');

bool _isPermissionError(Object error, AppException? appException) =>
    appException is PermissionException ||
    (error is FirebaseException && error.code == 'permission-denied');

bool _isNotFoundError(Object error, AppException? appException) =>
    appException is DocumentNotFoundException ||
    (error is FirebaseException && error.code == 'not-found');

String _notFoundTitle(AppErrorContext context) {
  return switch (context) {
    AppErrorContext.profile => 'Profile not found',
    AppErrorContext.event => 'Event not found',
    AppErrorContext.club => 'Club not found',
    AppErrorContext.chat => 'Chat not found',
    AppErrorContext.swipes => 'Catches not found',
    AppErrorContext.payments => 'Payment not found',
    _ => 'Not found',
  };
}
