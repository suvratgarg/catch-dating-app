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

  group('event policy lab availability', () {
    test('allows the lab in non-production environments when requested', () {
      expect(
        AppConfig.isEventPolicyLabAvailable(
          environment: AppEnvironment.dev,
          requested: true,
        ),
        isTrue,
      );
      expect(
        AppConfig.isEventPolicyLabAvailable(
          environment: AppEnvironment.staging,
          requested: true,
        ),
        isTrue,
      );
    });

    test('blocks the lab in production or when not requested', () {
      expect(
        AppConfig.isEventPolicyLabAvailable(
          environment: AppEnvironment.prod,
          requested: true,
        ),
        isFalse,
      );
      expect(
        AppConfig.isEventPolicyLabAvailable(
          environment: AppEnvironment.dev,
          requested: false,
        ),
        isFalse,
      );
    });
  });

  group('event success preview availability', () {
    test(
      'allows the preview in non-production environments when requested',
      () {
        expect(
          AppConfig.isEventSuccessPreviewAvailable(
            environment: AppEnvironment.dev,
            requested: true,
          ),
          isTrue,
        );
        expect(
          AppConfig.isEventSuccessPreviewAvailable(
            environment: AppEnvironment.staging,
            requested: true,
          ),
          isTrue,
        );
      },
    );

    test('blocks the preview in production or when not requested', () {
      expect(
        AppConfig.isEventSuccessPreviewAvailable(
          environment: AppEnvironment.prod,
          requested: true,
        ),
        isFalse,
      );
      expect(
        AppConfig.isEventSuccessPreviewAvailable(
          environment: AppEnvironment.dev,
          requested: false,
        ),
        isFalse,
      );
    });
  });

  group('Remote Config fetch interval', () {
    test('keeps frequent fetches for debug, emulator, and non-prod builds', () {
      expect(
        AppConfig.remoteConfigMinimumFetchIntervalFor(
          environment: AppEnvironment.prod,
          debugMode: true,
          useFirebaseEmulators: false,
        ),
        Duration.zero,
      );
      expect(
        AppConfig.remoteConfigMinimumFetchIntervalFor(
          environment: AppEnvironment.prod,
          debugMode: false,
          useFirebaseEmulators: true,
        ),
        Duration.zero,
      );
      expect(
        AppConfig.remoteConfigMinimumFetchIntervalFor(
          environment: AppEnvironment.staging,
          debugMode: false,
          useFirebaseEmulators: false,
        ),
        Duration.zero,
      );
    });

    test('throttles fetches for production release builds', () {
      expect(
        AppConfig.remoteConfigMinimumFetchIntervalFor(
          environment: AppEnvironment.prod,
          debugMode: false,
          useFirebaseEmulators: false,
        ),
        const Duration(hours: 1),
      );
    });
  });
}
