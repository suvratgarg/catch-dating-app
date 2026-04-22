import 'package:flutter/foundation.dart';

class AppConfig {
  const AppConfig._();

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

  static const String firebaseWebVapidKey = String.fromEnvironment(
    'FIREBASE_WEB_VAPID_KEY',
    defaultValue: '',
  );

  static String get firebaseEmulatorHost {
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return '10.0.2.2';
    }
    return 'localhost';
  }
}
