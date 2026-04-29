import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  setUp(() {
    PackageInfo.setMockInitialValues(
      appName: 'Catch',
      packageName: 'com.catchdating.app',
      version: '1.2.3',
      buildNumber: '45',
      buildSignature: '',
    );
  });

  test('disables Crashlytics collection when reporting is off', () async {
    final reporter = _FakeCrashReporter();
    final logger = ErrorLogger(
      crashReporter: reporter,
      shouldReportErrors: false,
    );

    await logger.initialize();
    logger.logError(StateError('hidden'), StackTrace.current, fatal: true);
    await Future<void>.delayed(Duration.zero);

    expect(reporter.collectionEnabled, isFalse);
    expect(reporter.customKeys, isEmpty);
    expect(reporter.recordedErrors, isEmpty);
  });

  test('records unexpected errors when reporting is enabled', () async {
    final reporter = _FakeCrashReporter();
    final logger = ErrorLogger(
      crashReporter: reporter,
      shouldReportErrors: true,
    );

    await logger.initialize();
    logger.logError(
      StateError('boom'),
      StackTrace.current,
      fatal: true,
      reason: 'test failure',
    );
    await Future<void>.delayed(Duration.zero);

    expect(reporter.collectionEnabled, isTrue);
    expect(reporter.customKeys['app_environment'], 'dev');
    expect(reporter.customKeys['app_version'], '1.2.3');
    expect(reporter.customKeys['build_number'], '45');
    expect(reporter.recordedErrors, hasLength(1));
    expect(reporter.recordedErrors.single.fatal, isTrue);
    expect(reporter.recordedErrors.single.reason, 'test failure');
  });

  test('does not report expected app exceptions', () async {
    final reporter = _FakeCrashReporter();
    final logger = ErrorLogger(
      crashReporter: reporter,
      shouldReportErrors: true,
    );

    logger.logAppException(const PaymentCancelledException());
    await Future<void>.delayed(Duration.zero);

    expect(reporter.recordedErrors, isEmpty);
  });

  test('records Flutter framework errors through Crashlytics', () async {
    final reporter = _FakeCrashReporter();
    final logger = ErrorLogger(
      crashReporter: reporter,
      shouldReportErrors: true,
    );

    logger.logFlutterError(
      FlutterErrorDetails(exception: StateError('widget failed')),
      fatal: true,
    );
    await Future<void>.delayed(Duration.zero);

    expect(reporter.recordedFlutterErrors, hasLength(1));
    expect(reporter.recordedFlutterErrors.single.fatal, isTrue);
  });
}

final class _RecordedError {
  const _RecordedError({
    required this.error,
    required this.fatal,
    required this.reason,
  });

  final Object error;
  final bool fatal;
  final String? reason;
}

final class _RecordedFlutterError {
  const _RecordedFlutterError({required this.details, required this.fatal});

  final FlutterErrorDetails details;
  final bool fatal;
}

final class _FakeCrashReporter implements CrashReporter {
  bool? collectionEnabled;
  final customKeys = <String, Object>{};
  final recordedErrors = <_RecordedError>[];
  final recordedFlutterErrors = <_RecordedFlutterError>[];

  @override
  Future<void> setCollectionEnabled(bool enabled) async {
    collectionEnabled = enabled;
  }

  @override
  Future<void> setCustomKey(String key, Object value) async {
    customKeys[key] = value;
  }

  @override
  Future<void> recordError(
    Object error,
    StackTrace stackTrace, {
    bool fatal = false,
    String? reason,
  }) async {
    recordedErrors.add(
      _RecordedError(error: error, fatal: fatal, reason: reason),
    );
  }

  @override
  Future<void> recordFlutterError(
    FlutterErrorDetails details, {
    bool fatal = false,
  }) async {
    recordedFlutterErrors.add(
      _RecordedFlutterError(details: details, fatal: fatal),
    );
  }
}
