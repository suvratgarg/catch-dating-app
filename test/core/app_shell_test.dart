import 'package:catch_dating_app/core/presentation/app_shell.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('appShellIsOffline', () {
    test('treats empty and none-only results as offline', () {
      expect(appShellIsOffline(const []), isTrue);
      expect(appShellIsOffline(const [ConnectivityResult.none]), isTrue);
    });

    test('treats any real transport as online', () {
      expect(
        appShellIsOffline(const [
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ]),
        isFalse,
      );
    });
  });
}
