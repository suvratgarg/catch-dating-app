import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptionsStaging {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Staging Firebase is not configured yet. Generate '
    'lib/firebase_options_staging.dart and add the staging native Firebase '
    'files under firebase/staging/. See firebase/README.md for the setup '
    'workflow.',
  );
}
