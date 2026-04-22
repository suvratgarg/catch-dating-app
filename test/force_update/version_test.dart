import 'package:catch_dating_app/force_update/domain/version.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('isUpdateRequired', () {
    test('#25 same version → no update required', () {
      expect(
        isUpdateRequired(current: '2.3.4', minimum: '2.3.4'),
        isFalse,
      );
    });

    test('#26 lower major → update required', () {
      expect(
        isUpdateRequired(current: '1.9.9', minimum: '2.0.0'),
        isTrue,
      );
    });

    test('#27 same major, lower minor → update required', () {
      expect(
        isUpdateRequired(current: '2.1.9', minimum: '2.2.0'),
        isTrue,
      );
    });

    test('same major+minor, lower patch → update required', () {
      expect(
        isUpdateRequired(current: '2.2.1', minimum: '2.2.2'),
        isTrue,
      );
    });

    test('#28 current above minimum → no update required', () {
      expect(
        isUpdateRequired(current: '3.0.0', minimum: '2.9.9'),
        isFalse,
      );
    });

    test('non-parseable current treated as 0.0.0 → update required', () {
      expect(
        isUpdateRequired(current: 'bad-version', minimum: '1.0.0'),
        isTrue,
      );
    });

    test('non-parseable minimum treated as 0.0.0 → no update required', () {
      expect(
        isUpdateRequired(current: '1.0.0', minimum: 'bad-version'),
        isFalse,
      );
    });
  });
}
