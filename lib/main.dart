import 'dart:async';

import 'package:catch_dating_app/analytics/app_analytics.dart';
import 'package:catch_dating_app/app.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:catch_dating_app/core/fcm_service.dart';
import 'package:catch_dating_app/core/firebase_providers.dart';
import 'package:catch_dating_app/exceptions/error_logger.dart';
import 'package:catch_dating_app/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ── Entry point ───────────────────────────────────────────────────────────────

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeFirebaseServices();

  final errorLogger = ErrorLogger();
  await errorLogger.initialize();
  final analytics = AppAnalytics();
  await analytics.initialize();

  _registerErrorHandlers(errorLogger);

  runApp(
    ProviderScope(
      overrides: [appAnalyticsProvider.overrideWithValue(analytics)],
      observers: [AsyncErrorLogger(errorLogger)],
      child: const MyApp(),
    ),
  );
}

// ── Global error handlers ─────────────────────────────────────────────────────

Future<void> _initializeFirebaseServices() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await _activateFirebaseAppCheck();

  if (AppConfig.supportsPushMessagingOnCurrentPlatform) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
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

Future<void> _activateFirebaseAppCheck() async {
  final debugToken = AppConfig.firebaseAppCheckDebugToken.trim();
  final debugTokenOrNull = debugToken.isEmpty ? null : debugToken;
  final useDebugProvider =
      kDebugMode ||
      AppConfig.useFirebaseEmulators ||
      !AppConfig.environment.isProduction;

  if (kIsWeb) {
    final siteKey = AppConfig.firebaseAppCheckWebRecaptchaEnterpriseSiteKey
        .trim();
    if (useDebugProvider) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: WebDebugProvider(debugToken: debugTokenOrNull),
      );
    } else if (siteKey.isNotEmpty) {
      await FirebaseAppCheck.instance.activate(
        providerWeb: ReCaptchaEnterpriseProvider(siteKey),
      );
    }
    return;
  }

  await FirebaseAppCheck.instance.activate(
    providerAndroid: useDebugProvider
        ? AndroidDebugProvider(debugToken: debugTokenOrNull)
        : const AndroidPlayIntegrityProvider(),
    providerApple: useDebugProvider
        ? AppleDebugProvider(debugToken: debugTokenOrNull)
        : const AppleAppAttestProvider(),
  );
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

  // Widget build failures — show a readable error screen instead of a
  // blank red widget in debug mode.
  if (kDebugMode) {
    ErrorWidget.builder = (details) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: const Text('An error occurred'),
        ),
        body: Center(child: Text(details.toString())),
      );
    };
  }
}
