import 'package:catch_dating_app/app.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'force update diagnostics explain App Check and rules denials in dev',
    () {
      final diagnostic = forceUpdateDevelopmentDiagnostic(
        FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied'),
      );

      expect(diagnostic, contains('config/app_config was denied'));
      expect(diagnostic, contains('App Check'));
      expect(diagnostic, contains('debug iPhone'));
    },
  );

  test('force update diagnostics stay hidden when there is no error', () {
    expect(forceUpdateDevelopmentDiagnostic(null), isNull);
  });
}
