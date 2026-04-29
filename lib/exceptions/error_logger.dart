import 'dart:async';

import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

abstract interface class CrashReporter {
  Future<void> setCollectionEnabled(bool enabled);

  Future<void> setCustomKey(String key, Object value);

  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  });

  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  });
}

final class FirebaseCrashReporter implements CrashReporter {
  FirebaseCrashReporter(this._crashlytics);

  final FirebaseCrashlytics _crashlytics;

  @override
  Future<void> setCollectionEnabled(bool enabled) {
    return _crashlytics.setCrashlyticsCollectionEnabled(enabled);
  }

  @override
  Future<void> setCustomKey(String key, Object value) {
    return _crashlytics.setCustomKey(key, value);
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) {
    return _crashlytics.recordError(
      error,
      stackTrace,
      fatal: fatal,
      reason: reason,
    );
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) {
    if (fatal) {
      return _crashlytics.recordFlutterFatalError(details);
    }
    return _crashlytics.recordFlutterError(details);
  }
}

/// Logs unexpected errors locally and, in production release builds, reports
/// them to Firebase Crashlytics.
class ErrorLogger {
  ErrorLogger({CrashReporter? crashReporter, bool? shouldReportErrors})
    : _crashReporter = crashReporter ?? _defaultCrashReporter,
      _shouldReportErrors = shouldReportErrors ?? _defaultShouldReportErrors;

  final CrashReporter? _crashReporter;
  final bool _shouldReportErrors;

  static CrashReporter? get _defaultCrashReporter {
    if (kIsWeb) return null;
    return FirebaseCrashReporter(FirebaseCrashlytics.instance);
  }

  static bool get _defaultShouldReportErrors {
    return !kIsWeb &&
        kReleaseMode &&
        AppConfig.environment.isProduction &&
        !AppConfig.useFirebaseEmulators;
  }

  bool get _canReport => _shouldReportErrors && _crashReporter != null;

  Future<void> initialize() async {
    final crashReporter = _crashReporter;
    if (crashReporter == null) return;

    await crashReporter.setCollectionEnabled(_shouldReportErrors);
    if (!_shouldReportErrors) return;

    await crashReporter.setCustomKey(
      'app_environment',
      AppConfig.environmentName,
    );
    await crashReporter.setCustomKey(
      'use_firebase_emulators',
      AppConfig.useFirebaseEmulators,
    );
    await crashReporter.setCustomKey('platform', defaultTargetPlatform.name);

    final packageInfo = await PackageInfo.fromPlatform();
    await crashReporter.setCustomKey('app_version', packageInfo.version);
    await crashReporter.setCustomKey('build_number', packageInfo.buildNumber);
  }

  void logFlutterError(FlutterErrorDetails details, {bool fatal = false}) {
    debugPrint('FLUTTER_ERROR: ${details.exception}\n${details.stack}');
    if (!_canReport) return;

    unawaited(_crashReporter!.recordFlutterError(details, fatal: fatal));
  }

  void logError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) {
    debugPrint('ERROR: $error\n$stackTrace');
    if (!_canReport) return;

    unawaited(
      _crashReporter!.recordError(
        error,
        stackTrace ?? StackTrace.current,
        fatal: fatal,
        reason: reason,
      ),
    );
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
