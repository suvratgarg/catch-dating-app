import 'package:catch_dating_app/core/app_config.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppEnvironment.fromValue', () {
    test('parses supported environments', () {
      expect(AppEnvironment.fromValue('dev'), AppEnvironment.dev);
      expect(AppEnvironment.fromValue('staging'), AppEnvironment.staging);
      expect(AppEnvironment.fromValue('prod'), AppEnvironment.prod);
      expect(AppEnvironment.fromValue('production'), AppEnvironment.prod);
    });

    test('normalizes case and whitespace', () {
      expect(AppEnvironment.fromValue(' Staging '), AppEnvironment.staging);
    });

    test('throws on unsupported environment', () {
      expect(() => AppEnvironment.fromValue('qa'), throwsArgumentError);
    });
  });
}
