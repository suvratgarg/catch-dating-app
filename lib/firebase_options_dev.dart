// Firebase options for the dev environment.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

class DefaultFirebaseOptionsDev {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptionsDev are not configured for this platform. '
          'Windows and Linux support have been removed from this app.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptionsDev are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAl271K9YGiYZOEcNgoEwZiOQV0ydpWfrg',
    appId: '1:619661127800:web:b0673ad370947b2f077d8d',
    messagingSenderId: '619661127800',
    projectId: 'catchdates-dev',
    authDomain: 'catchdates-dev.firebaseapp.com',
    storageBucket: 'catchdates-dev.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCpzFHkPnvzLf9ti3JJ3dytrZ0ZiKxzWuY',
    appId: '1:619661127800:android:d90f9bb4d89afbd7077d8d',
    messagingSenderId: '619661127800',
    projectId: 'catchdates-dev',
    storageBucket: 'catchdates-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCFQlvN1fhzrXZg09Bvygc-LGt7vyXsWHQ',
    appId: '1:619661127800:ios:e9456edea3f2427f077d8d',
    messagingSenderId: '619661127800',
    projectId: 'catchdates-dev',
    storageBucket: 'catchdates-dev.firebasestorage.app',
    iosBundleId: 'com.catchdates.app.dev',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCFQlvN1fhzrXZg09Bvygc-LGt7vyXsWHQ',
    appId: '1:619661127800:ios:e9456edea3f2427f077d8d',
    messagingSenderId: '619661127800',
    projectId: 'catchdates-dev',
    storageBucket: 'catchdates-dev.firebasestorage.app',
    iosBundleId: 'com.catchdates.app.dev',
  );
}
