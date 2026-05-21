import 'package:flutter/foundation.dart';

enum AppEnvironment {
  dev('dev', 'DEV', 'Catch (Dev)'),
  staging('staging', 'STAGING', 'Catch (Staging)'),
  prod('prod', '', 'Catch');

  const AppEnvironment(this.value, this.bannerLabel, this.appTitle);

  final String value;
  final String bannerLabel;
  final String appTitle;

  bool get isProduction => this == AppEnvironment.prod;

  static AppEnvironment fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'dev' => AppEnvironment.dev,
      'staging' => AppEnvironment.staging,
      'prod' || 'production' => AppEnvironment.prod,
      _ => throw ArgumentError.value(
        value,
        'APP_ENV',
        'Unsupported app environment. Use dev, staging, or prod.',
      ),
    };
  }
}

class AppConfig {
  const AppConfig._();

  static const String _rawAppEnvironment = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'dev',
  );

  static AppEnvironment get environment =>
      AppEnvironment.fromValue(_rawAppEnvironment);

  @visibleForTesting
  static bool isEventPolicyLabAvailable({
    required AppEnvironment environment,
    required bool requested,
  }) {
    return requested && !environment.isProduction;
  }

  @visibleForTesting
  static bool isEventSuccessPreviewAvailable({
    required AppEnvironment environment,
    required bool requested,
  }) {
    return requested && !environment.isProduction;
  }

  static String get environmentName => environment.value;

  static String get appTitle => environment.appTitle;

  @visibleForTesting
  static Duration remoteConfigMinimumFetchIntervalFor({
    required AppEnvironment environment,
    required bool debugMode,
    required bool useFirebaseEmulators,
  }) {
    if (debugMode || useFirebaseEmulators || !environment.isProduction) {
      return Duration.zero;
    }
    return const Duration(hours: 1);
  }

  static Duration get remoteConfigMinimumFetchInterval =>
      remoteConfigMinimumFetchIntervalFor(
        environment: environment,
        debugMode: kDebugMode,
        useFirebaseEmulators: useFirebaseEmulators,
      );

  @visibleForTesting
  static bool shouldCollectObservabilityFor({
    required AppEnvironment environment,
    required bool releaseMode,
    required bool profileMode,
    required bool useFirebaseEmulators,
    required bool forceNonProductionCollection,
  }) {
    if (useFirebaseEmulators) return false;
    if (releaseMode && environment.isProduction) return true;
    if (releaseMode || profileMode) return forceNonProductionCollection;
    return false;
  }

  static bool get shouldCollectObservability => shouldCollectObservabilityFor(
    environment: environment,
    releaseMode: kReleaseMode,
    profileMode: kProfileMode,
    useFirebaseEmulators: useFirebaseEmulators,
    forceNonProductionCollection: enableObservabilityCollection,
  );

  @visibleForTesting
  static bool shouldUseFirebaseCrashReporterFor({
    required bool releaseMode,
    required bool profileMode,
    required bool forceObservabilityCollection,
  }) {
    return releaseMode || (profileMode && forceObservabilityCollection);
  }

  static bool get shouldUseFirebaseCrashReporter =>
      shouldUseFirebaseCrashReporterFor(
        releaseMode: kReleaseMode,
        profileMode: kProfileMode,
        forceObservabilityCollection: enableObservabilityCollection,
      );

  static const bool enableObservabilityCollection = bool.fromEnvironment(
    'ENABLE_OBSERVABILITY_COLLECTION',
    defaultValue: false,
  );

  static const bool emitObservabilitySmokeEvent = bool.fromEnvironment(
    'EMIT_OBSERVABILITY_SMOKE_EVENT',
    defaultValue: false,
  );

  static bool get shouldShowEnvironmentBanner => !environment.isProduction;

  static String get environmentBannerLabel => environment.bannerLabel;

  static const bool useFirebaseEmulators = bool.fromEnvironment(
    'USE_FIREBASE_EMULATORS',
    defaultValue: false,
  );

  // Default true so native push works in release builds without extra flags.
  // Web still requires a VAPID key — see firebaseWebVapidKey.
  static const bool enablePushMessaging = bool.fromEnvironment(
    'ENABLE_PUSH_MESSAGING',
    defaultValue: true,
  );

  static bool get supportsPushMessagingOnCurrentPlatform {
    if (!enablePushMessaging) return false;

    if (kIsWeb) {
      return firebaseWebVapidKey.isNotEmpty;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android || TargetPlatform.iOS => true,
      _ => false,
    };
  }

  static const String firebaseWebVapidKey = String.fromEnvironment(
    'FIREBASE_WEB_VAPID_KEY',
    defaultValue: '',
  );

  static const String firebaseAppCheckDebugToken = String.fromEnvironment(
    'FIREBASE_APP_CHECK_DEBUG_TOKEN',
    defaultValue: '',
  );

  static const bool useFirebaseAppCheckDebugProvider = bool.fromEnvironment(
    'USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER',
    defaultValue: false,
  );

  static const bool verboseAuthDebugLogs = bool.fromEnvironment(
    'VERBOSE_AUTH_DEBUG_LOGS',
    defaultValue: false,
  );

  static const bool _eventPolicyLabRequested = bool.fromEnvironment(
    'ENABLE_EVENT_POLICY_LAB',
    defaultValue: true,
  );

  static bool get enableEventPolicyLab => isEventPolicyLabAvailable(
    environment: environment,
    requested: _eventPolicyLabRequested,
  );

  static const bool _eventSuccessPreviewRequested = bool.fromEnvironment(
    'ENABLE_EVENT_SUCCESS_PREVIEW',
    defaultValue: true,
  );

  static bool get enableEventSuccessPreview => isEventSuccessPreviewAvailable(
    environment: environment,
    requested: _eventSuccessPreviewRequested,
  );

  static const String firebaseAppCheckWebRecaptchaEnterpriseSiteKey =
      String.fromEnvironment(
        'FIREBASE_APP_CHECK_WEB_RECAPTCHA_ENTERPRISE_SITE_KEY',
        defaultValue: '',
      );

  static String get firebaseEmulatorHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }
}
