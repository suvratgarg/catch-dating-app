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

enum AppRole {
  consumer('consumer'),
  host('host');

  const AppRole(this.value);

  final String value;

  bool get isHost => this == AppRole.host;

  static AppRole fromValue(String value) {
    return switch (value.trim().toLowerCase()) {
      'consumer' || 'guest' => AppRole.consumer,
      'host' || 'organizer' => AppRole.host,
      _ => throw ArgumentError.value(
        value,
        'CATCH_APP_ROLE',
        'Unsupported app role. Use consumer or host.',
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

  static const String _rawAppRole = String.fromEnvironment(
    'CATCH_APP_ROLE',
    defaultValue: 'consumer',
  );

  static AppRole? _entrypointAppRoleOverride;

  static AppEnvironment get environment =>
      AppEnvironment.fromValue(_rawAppEnvironment);

  static AppRole get appRole =>
      _entrypointAppRoleOverride ?? AppRole.fromValue(_rawAppRole);

  static String get appRoleName => appRole.value;

  static void configureEntrypointRole(AppRole role) {
    _entrypointAppRoleOverride = role;
  }

  @visibleForTesting
  static void resetEntrypointRoleOverrideForTesting() {
    _entrypointAppRoleOverride = null;
  }

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

  static String get appTitle {
    if (!appRole.isHost) return environment.appTitle;
    if (environment.isProduction) return 'Catch Host';
    return 'Catch Host (${environment.bannerLabel})';
  }

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

  @visibleForTesting
  static bool canDebugSignOutOnStart({
    required bool releaseMode,
    required bool requested,
  }) {
    return requested && !releaseMode;
  }

  @visibleForTesting
  static bool canDisableAuthAppVerificationForTesting({
    required AppEnvironment environment,
    required bool releaseMode,
    required bool requested,
  }) {
    return requested && !releaseMode && !environment.isProduction;
  }

  static const bool enableObservabilityCollection = bool.fromEnvironment(
    'ENABLE_OBSERVABILITY_COLLECTION',
  );

  static const bool emitObservabilitySmokeEvent = bool.fromEnvironment(
    'EMIT_OBSERVABILITY_SMOKE_EVENT',
  );

  static const bool enableExploreSyntheticVisualFill = bool.fromEnvironment(
    'ENABLE_EXPLORE_SYNTHETIC_VISUAL_FILL',
  );

  static bool get shouldShowEnvironmentBanner => !environment.isProduction;

  static String get environmentBannerLabel {
    if (!appRole.isHost) return environment.bannerLabel;
    if (environment.bannerLabel.isEmpty) return '';
    return 'HOST ${environment.bannerLabel}';
  }

  static const bool useFirebaseEmulators = bool.fromEnvironment(
    'USE_FIREBASE_EMULATORS',
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
  );

  static const String firebaseAppCheckDebugToken = String.fromEnvironment(
    'FIREBASE_APP_CHECK_DEBUG_TOKEN',
  );

  static final Uri hostAppUrl = Uri.parse(
    const String.fromEnvironment(
      'CATCH_HOST_APP_URL',
      defaultValue: 'https://catchdates.com/host',
    ),
  );

  static const bool useFirebaseAppCheckDebugProvider = bool.fromEnvironment(
    'USE_FIREBASE_APP_CHECK_DEBUG_PROVIDER',
  );

  static const bool verboseAuthDebugLogs = bool.fromEnvironment(
    'VERBOSE_AUTH_DEBUG_LOGS',
  );

  static const bool disableAuthAppVerificationForTesting = bool.fromEnvironment(
    'DISABLE_AUTH_APP_VERIFICATION_FOR_TESTING',
  );

  static const bool debugSignOutOnStart = bool.fromEnvironment(
    'DEBUG_SIGN_OUT_ON_START',
  );

  static bool get shouldDebugSignOutOnStart => canDebugSignOutOnStart(
    releaseMode: kReleaseMode,
    requested: debugSignOutOnStart,
  );

  static bool get shouldDisableAuthAppVerificationForTesting =>
      canDisableAuthAppVerificationForTesting(
        environment: environment,
        releaseMode: kReleaseMode,
        requested: disableAuthAppVerificationForTesting,
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
      );

  static String get firebaseEmulatorHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }
}
