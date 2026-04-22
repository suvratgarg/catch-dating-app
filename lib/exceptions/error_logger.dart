import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Logs errors to the console in debug builds.
///
/// Replace [logError] / [logAppException] with calls to your crash-reporting
/// tool (e.g. Firebase Crashlytics, Sentry) before going to production.
class ErrorLogger {
  void logError(Object error, StackTrace? stackTrace) {
    debugPrint('ERROR: $error\n$stackTrace');
  }

  void logAppException(AppException exception) {
    // AppExceptions are expected user-facing errors — lower severity.
    debugPrint('APP_EXCEPTION [${exception.code}]: ${exception.message}');
  }
}

/// [ProviderObserver] that automatically logs every provider that transitions
/// into an error state. Attach via [ProviderContainer.observers] in [main].
base class AsyncErrorLogger extends ProviderObserver {
  AsyncErrorLogger(this._logger);

  final ErrorLogger _logger;

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue is AsyncError) {
      if (newValue.error is AppException) {
        _logger.logAppException(newValue.error as AppException);
      } else {
        _logger.logError(newValue.error, newValue.stackTrace);
      }
    }
  }
}
