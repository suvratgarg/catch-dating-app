import 'dart:async';

import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/console_crash_reporter.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'error_logger.g.dart';

// ── CrashReporter interface ───────────────────────────────────────────────────

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
  Future<void> setCollectionEnabled(bool enabled) =>
      _crashlytics.setCrashlyticsCollectionEnabled(enabled);

  @override
  Future<void> setCustomKey(String key, Object value) =>
      _crashlytics.setCustomKey(key, value);

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) => _crashlytics.recordError(error, stackTrace, fatal: fatal, reason: reason);

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) => fatal
      ? _crashlytics.recordFlutterFatalError(details)
      : _crashlytics.recordFlutterError(details);
}

// ── Log level ─────────────────────────────────────────────────────────────────

enum LogLevel { fatal, error, warn, info, debug }

// ── ErrorLogger ───────────────────────────────────────────────────────────────

class ErrorLogger {
  ErrorLogger({CrashReporter? crashReporter, bool? shouldReportErrors})
    : _crashReporter = crashReporter ?? _defaultCrashReporter,
      _shouldReportErrors = shouldReportErrors ?? _defaultShouldReportErrors;

  final CrashReporter? _crashReporter;
  final bool _shouldReportErrors;

  static CrashReporter get _defaultCrashReporter {
    if (kIsWeb) return ConsoleCrashReporter();
    return FirebaseCrashReporter(FirebaseCrashlytics.instance);
  }

  static bool get _defaultShouldReportErrors {
    return kReleaseMode &&
        AppConfig.environment.isProduction &&
        !AppConfig.useFirebaseEmulators;
  }

  bool get _canReport => _shouldReportErrors && _crashReporter != null;

  // ── Initialization ──────────────────────────────────────────────────────────

  Future<void> initialize() async {
    final crashReporter = _crashReporter;
    if (crashReporter == null) return;

    await crashReporter.setCollectionEnabled(_shouldReportErrors);
    if (!_shouldReportErrors) return;

    await crashReporter.setCustomKey('app_environment', AppConfig.environmentName);
    await crashReporter.setCustomKey('use_firebase_emulators', AppConfig.useFirebaseEmulators);
    await crashReporter.setCustomKey('platform', defaultTargetPlatform.name);

    final packageInfo = await PackageInfo.fromPlatform();
    await crashReporter.setCustomKey('app_version', packageInfo.version);
    await crashReporter.setCustomKey('build_number', packageInfo.buildNumber);
  }

  /// Sets the current user ID as a Crashlytics custom key so crash reports
  /// are attributable to a specific user. Call when the auth state changes.
  void setUserId(String? uid) {
    if (!_canReport) return;
    unawaited(_crashReporter!.setCustomKey('user_id', uid ?? 'anonymous'));
  }

  // ── Structured logging ─────────────────────────────────────────────────────

  /// Primary logging method. All other log methods delegate here.
  ///
  /// [level] determines severity. Errors at [LogLevel.fatal] or [LogLevel.error]
  /// are reported to Crashlytics (in production). All levels are printed to
  /// the console in debug mode.
  void log({
    required LogLevel level,
    required String message,
    Object? error,
    StackTrace? stackTrace,
    Map<String, String>? context,
  }) {
    final timestamp = DateTime.now().toIso8601String();
    final prefix = level.name.toUpperCase();
    final ctx = context != null ? ' ${_formatContext(context)}' : '';
    debugPrint('[$prefix][$timestamp]$ctx $message');
    if (error != null) debugPrint('  error=$error');
    if (stackTrace != null) debugPrint('  $stackTrace');

    if ((level == LogLevel.fatal || level == LogLevel.error) && _canReport) {
      unawaited(
        _crashReporter!.recordError(
          error ?? message,
          stackTrace ?? StackTrace.current,
          fatal: level == LogLevel.fatal,
          reason: message,
        ),
      );
    }
  }

  String _formatContext(Map<String, String> context) =>
      context.entries.map((e) => '${e.key}=${e.value}').join(' ');

  // ── Convenience methods (backward-compatible) ───────────────────────────────

  void logFlutterError(FlutterErrorDetails details, {bool fatal = false}) {
    log(
      level: fatal ? LogLevel.fatal : LogLevel.error,
      message: 'Flutter error: ${details.exception}',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (!_canReport) return;
    unawaited(_crashReporter!.recordFlutterError(details, fatal: fatal));
  }

  void logError(Object error, StackTrace? stackTrace, {bool fatal = false, String? reason}) {
    log(
      level: fatal ? LogLevel.fatal : LogLevel.error,
      message: reason ?? 'Unexpected error: $error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void logAppException(AppException exception) {
    log(
      level: LogLevel.warn,
      message: '[${exception.code}] ${exception.message}',
      error: exception.cause,
    );
  }
}

// ── Provider ─────────────────────────────────────────────────────────────────

/// A no-op default that must be overridden in [main] with the real instance.
@riverpod
ErrorLogger errorLogger(Ref ref) => ErrorLogger();

// ── ProviderObserver ──────────────────────────────────────────────────────────

base class AsyncErrorLogger extends ProviderObserver {
  AsyncErrorLogger(this._logger, {this.onFirestoreWriteFailed});

  final ErrorLogger _logger;

  /// Called when a [FirestoreWriteException] is caught by the observer.
  /// Use this to fire analytics events for write failures.
  final void Function({
    required String collection,
    required String action,
    required String errorCode,
  })? onFirestoreWriteFailed;

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    if (newValue is AsyncError) {
      final error = newValue.error;
      if (error is AppException) {
        _logger.logAppException(error);
        if (error is FirestoreWriteException) {
          onFirestoreWriteFailed?.call(
            collection: error.collection ?? '',
            action: error.action ?? '',
            errorCode: error.code,
          );
        }
      } else {
        _logger.logError(error, newValue.stackTrace);
      }
    }
  }
}
