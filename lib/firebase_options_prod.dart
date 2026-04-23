import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptionsProd {
  static FirebaseOptions get currentPlatform => throw UnsupportedError(
    'Prod Firebase is not configured yet. Generate '
    'lib/firebase_options_prod.dart and add the prod native Firebase files '
    'under firebase/prod/. See firebase/README.md for the setup workflow.',
  );
}
