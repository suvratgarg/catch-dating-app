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

  static String get environmentName => environment.value;

  static String get appTitle => environment.appTitle;

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
