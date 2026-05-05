import 'package:catch_dating_app/core/connectivity_service.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('connectivityResultsAreOffline', () {
    test('treats empty and none-only results as offline', () {
      expect(connectivityResultsAreOffline(const []), isTrue);
      expect(
        connectivityResultsAreOffline(const [ConnectivityResult.none]),
        isTrue,
      );
    });

    test('treats any real transport as online', () {
      expect(
        connectivityResultsAreOffline(const [
          ConnectivityResult.none,
          ConnectivityResult.wifi,
        ]),
        isFalse,
      );
    });
  });
}
