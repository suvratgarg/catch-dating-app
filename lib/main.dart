import 'dart:async';

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/core/widgets/catch_framework_error_view.dart';
import 'package:catch_dating_app/exceptions/app_exception.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/firebase_options.dart';
import 'package:catch_dating_app/force_update/domain/app_version_config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _lockDeviceOrientation();
  await _initializeFirebaseServices();

  final errorLogger = ErrorLogger();
  await errorLogger.initialize();
  final analytics = AppAnalytics();
  await analytics.initialize();

  _registerErrorHandlers(errorLogger);

  runApp(
    ProviderScope(
      overrides: [
        appAnalyticsProvider.overrideWithValue(analytics),
        errorLoggerProvider.overrideWithValue(errorLogger),
      ],
      observers: [
        AsyncErrorLogger(
          errorLogger,
          onBackendOperationFailed:
              ({
                required BackendErrorContext context,
                required String errorCode,
                required bool retryable,
                required AppErrorSeverity severity,
              }) {
                analytics.logBackendOperationFailed(
                  context: context,
                  errorCode: errorCode,
                  retryable: retryable,
                  severity: severity,
                );
              },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _lockDeviceOrientation() {
  return SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
  ]);
}

// ── Global error handlers ─────────────────────────────────────────────────────

Future<void> _initializeFirebaseServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _activateFirebaseAppCheck();

  // Enable offline persistence explicitly — defaults differ by platform
  // (mobile: enabled, web: disabled). Setting it ensures consistent behavior.
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  await _initializeRemoteConfig();

  if (AppConfig.supportsPushMessagingOnCurrentPlatform) {
    registerFirebaseMessagingBackgroundHandler();
  }

  if (AppConfig.useFirebaseEmulators) {
    final host = AppConfig.firebaseEmulatorHost;
    await FirebaseAuth.instance.useAuthEmulator(host, 9099);
    FirebaseFirestore.instance.useFirestoreEmulator(host, 8080);
    await FirebaseStorage.instance.useStorageEmulator(host, 9199);
    FirebaseFunctions.instanceFor(
      region: firebaseFunctionsRegion,
    ).useFunctionsEmulator(host, 5001);
  }
}

Future<void> _initializeRemoteConfig() async {
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(
    RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 10),
      minimumFetchInterval: AppConfig.remoteConfigMinimumFetchInterval,
    ),
  );
  await remoteConfig.setDefaults(kAppVersionConfigDefaults);
  try {
    await remoteConfig.fetchAndActivate();
  } catch (_) {
    // fetch failed — the defaults set above will serve as the gate.
  }
}

Future<void> _activateFirebaseAppCheck() async {
  final debugToken = AppConfig.firebaseAppCheckDebugToken.trim();
  final debugTokenOrNull = debugToken.isEmpty ? null : debugToken;
  final useDebugProvider =
      AppConfig.useFirebaseAppCheckDebugProvider ||
      AppConfig.useFirebaseEmulators;
  final useWebDebugProvider = kDebugMode || useDebugProvider;
  final useAndroidDebugProvider = kDebugMode || useDebugProvider;
  final useAppleDebugProvider = useDebugProvider;

  debugPrint('── App Check init ──');
  debugPrint('  kDebugMode: $kDebugMode');
  debugPrint('  debugToken configured: ${debugToken.isNotEmpty}');
  debugPrint('  forceDebugProvider: $useDebugProvider');
  debugPrint('  useAppleDebugProvider: $useAppleDebugProvider');

  if (kIsWeb) {
    final siteKey = AppConfig.firebaseAppCheckWebRecaptchaEnterpriseSiteKey
        .trim();
    if (useWebDebugProvider) {
      debugPrint(
        debugToken.isEmpty
            ? 'WARNING: Debug provider active but no FIREBASE_APP_CHECK_DEBUG_TOKEN set.'
            : 'Using WebDebugProvider with configured token.',
      );
      await FirebaseAppCheck.instance.activate(
        providerWeb: WebDebugProvider(debugToken: debugTokenOrNull),
      );
    } else if (siteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaEnterpriseProvider(siteKey),
      );
    } else {
      debugPrint(
        'WARNING: Web App Check has no debug token and no ReCaptcha site key '
        'configured. App Check enforcement is silently disabled — all '
        'App Check-protected services (Firestore, Auth, Functions) are '
        'unprotected on web.',
      );
    }
    return;
  }

  if ((useAndroidDebugProvider || useAppleDebugProvider) &&
      debugToken.isEmpty) {
    debugPrint(
      'WARNING: Debug App Check provider active on iOS/Android but no '
      'FIREBASE_APP_CHECK_DEBUG_TOKEN env var is set. A random token will be '
      'generated and printed. It must be registered in Firebase Console '
      '(App Check > Manage debug tokens) and re-exported, or all App Check-'
      'protected services (Firestore, Auth, Functions) will fail with 403.',
    );
  }

  await FirebaseAppCheck.instance.activate(
    providerAndroid: useAndroidDebugProvider
        ? AndroidDebugProvider(debugToken: debugTokenOrNull)
        : const AndroidPlayIntegrityProvider(),
    providerApple: useAppleDebugProvider
        ? AppleDebugProvider(debugToken: debugTokenOrNull)
        : const AppleAppAttestProvider(),
  );
  if (useDebugProvider && !useAppleDebugProvider) {
    unawaited(_warmUpFirebaseAppCheckDebugToken());
  }
}

Future<void> _warmUpFirebaseAppCheckDebugToken() async {
  try {
    await FirebaseAppCheck.instance
        .getToken(true)
        .timeout(const Duration(seconds: 8));
  } catch (error) {
    debugPrint('Firebase App Check debug token warmup failed: $error');
  }
}

/// Hooks into Flutter's error reporting pipeline so uncaught errors are
/// logged and sent to Crashlytics in production release builds.
void _registerErrorHandlers(ErrorLogger errorLogger) {
  // Flutter framework errors (widget build failures, layout overflow, etc.)
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    errorLogger.logFlutterError(details, fatal: true);
  };

  // Errors from the underlying platform / Dart isolate
  PlatformDispatcher.instance.onError = (error, stack) {
    errorLogger.logError(error, stack, fatal: true);
    return true;
  };

  // Widget build failures should still look like Catch. Debug builds keep the
  // useful framework details, but the raw Flutter red screen should not leak
  // into the product shell.
  ErrorWidget.builder = (details) => CatchFrameworkErrorView(details: details);
}
