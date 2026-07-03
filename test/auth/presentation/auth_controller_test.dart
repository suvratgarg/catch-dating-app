import 'dart:ui' show Locale;

import 'package:catch_dating_app/auth/data/auth_repository.dart';
import 'package:catch_dating_app/auth/presentation/auth_controller.dart';
import 'package:catch_dating_app/auth/presentation/auth_input.dart';
import 'package:catch_dating_app/auth/presentation/auth_session_controller.dart';
import 'package:catch_dating_app/core/app_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../onboarding/onboarding_test_helpers.dart';

void main() {
  tearDown(AppConfig.resetEntrypointRoleOverrideForTesting);

  group('AuthController.sendOtp', () {
    test(
      'prefixes +91 and advances to the OTP step when code is sent',
      () async {
        final repository = FakeAuthRepository()
          ..onVerifyPhoneNumber =
              ({
                required verificationCompleted,
                required verificationFailed,
                required codeSent,
                required codeAutoRetrievalTimeout,
              }) {
                codeSent('verification-id', 11);
              };
        final container = _authControllerContainer(repository);
        addTearDown(repository.dispose);
        addTearDown(container.dispose);
        AuthController.sendOtpMutation.reset(container);
        AuthController.verifyOtpMutation.reset(container);

        final notifier = container.read(authControllerProvider.notifier);

        await notifier.sendOtp('9999999999', '+91');

        expect(repository.verifiedPhoneNumber, '+919999999999');
        expect(
          container.read(authControllerProvider),
          const AuthScreenState(
            step: AuthStep.otp,
            verificationId: 'verification-id',
            phoneNumber: '9999999999',
          ),
        );
        expect(repository.credential, isNull);
        expect(repository.otpVerificationId, isNull);
      },
    );

    test('uses the previous resend token for repeat OTP requests', () async {
      var verificationRequestCount = 0;
      final repository = FakeAuthRepository()
        ..onVerifyPhoneNumber =
            ({
              required verificationCompleted,
              required verificationFailed,
              required codeSent,
              required codeAutoRetrievalTimeout,
            }) {
              verificationRequestCount += 1;
              codeSent('verification-id-$verificationRequestCount', 11);
            };
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.sendOtp('9999999999', '+91');
      expect(repository.forceResendingToken, isNull);

      await notifier.sendOtp('9999999999', '+91');
      expect(repository.forceResendingToken, 11);
      expect(
        container.read(authControllerProvider).verificationId,
        'verification-id-2',
      );
    });

    test(
      'does not reuse the resend token for a different phone number',
      () async {
        final repository = FakeAuthRepository()
          ..onVerifyPhoneNumber =
              ({
                required verificationCompleted,
                required verificationFailed,
                required codeSent,
                required codeAutoRetrievalTimeout,
              }) {
                codeSent('verification-id', 11);
              };
        final container = _authControllerContainer(repository);
        addTearDown(repository.dispose);
        addTearDown(container.dispose);
        final notifier = container.read(authControllerProvider.notifier);

        await notifier.sendOtp('9999999999', '+91');
        await notifier.sendOtp('8888888888', '+91');

        expect(repository.forceResendingToken, isNull);
      },
    );

    test(
      'rejects invalid phone numbers before calling Firebase Auth',
      () async {
        final repository = FakeAuthRepository();
        final container = _authControllerContainer(repository);
        addTearDown(repository.dispose);
        addTearDown(container.dispose);

        await expectLater(
          container.read(authControllerProvider.notifier).sendOtp('123', '+91'),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              AuthInput.invalidPhoneNumberMessage,
            ),
          ),
        );

        expect(repository.verifyPhoneNumberCallCount, 0);
        expect(container.read(authControllerProvider), const AuthScreenState());
      },
    );

    test(
      'rejects invalid country codes before calling Firebase Auth',
      () async {
        final repository = FakeAuthRepository();
        final container = _authControllerContainer(repository);
        addTearDown(repository.dispose);
        addTearDown(container.dispose);

        await expectLater(
          container
              .read(authControllerProvider.notifier)
              .sendOtp('9999999999', '91'),
          throwsA(
            isA<StateError>().having(
              (error) => error.message,
              'message',
              AuthInput.invalidCountryCodeMessage,
            ),
          ),
        );

        expect(repository.verifyPhoneNumberCallCount, 0);
        expect(container.read(authControllerProvider), const AuthScreenState());
      },
    );

    test('uses signInWithCredential during auto verification', () async {
      final credential = PhoneAuthProvider.credential(
        verificationId: 'verification-id',
        smsCode: '123456',
      );
      final repository = FakeAuthRepository()
        ..onVerifyPhoneNumber =
            ({
              required verificationCompleted,
              required verificationFailed,
              required codeSent,
              required codeAutoRetrievalTimeout,
            }) {
              verificationCompleted(credential);
            };
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      AuthController.sendOtpMutation.reset(container);
      AuthController.verifyOtpMutation.reset(container);

      final notifier = container.read(authControllerProvider.notifier);

      await notifier.sendOtp('9999999999', '+91');

      expect(repository.credential, same(credential));
      expect(repository.otpVerificationId, isNull);
    });
  });

  group('AuthController.verifyOtp', () {
    test('throws when no verification session is active', () async {
      final repository = _SignOutAuthRepository();
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      await expectLater(
        container.read(authControllerProvider.notifier).verifyOtp('123456'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            'Verification session expired. Please request a new code.',
          ),
        ),
      );
      expect(repository.otpVerificationId, isNull);
    });

    test('signs in with the stored verification id', () async {
      final repository = FakeAuthRepository()
        ..onVerifyPhoneNumber =
            ({
              required verificationCompleted,
              required verificationFailed,
              required codeSent,
              required codeAutoRetrievalTimeout,
            }) {
              codeSent('verification-id', 11);
            };
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      AuthController.sendOtpMutation.reset(container);
      AuthController.verifyOtpMutation.reset(container);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.sendOtp('9999999999', '+91');
      await notifier.verifyOtp('123456');

      expect(repository.otpVerificationId, 'verification-id');
      expect(repository.otpSmsCode, '123456');
    });

    test('rejects malformed OTP codes before repository sign-in', () async {
      final repository = FakeAuthRepository()
        ..onVerifyPhoneNumber =
            ({
              required verificationCompleted,
              required verificationFailed,
              required codeSent,
              required codeAutoRetrievalTimeout,
            }) {
              codeSent('verification-id', 11);
            };
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);
      final notifier = container.read(authControllerProvider.notifier);

      await notifier.sendOtp('9999999999', '+91');
      await expectLater(
        notifier.verifyOtp('12345a'),
        throwsA(
          isA<StateError>().having(
            (error) => error.message,
            'message',
            AuthInput.invalidOtpCodeMessage,
          ),
        ),
      );

      expect(repository.otpVerificationId, isNull);
      expect(repository.otpSmsCode, isNull);
    });
  });

  group('AuthController state management', () {
    test('initial country code maps the platform locale', () {
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.localeTestValue = const Locale('en', 'AU');
      addTearDown(binding.platformDispatcher.clearLocaleTestValue);

      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      expect(container.read(authInitialCountryDialCodeProvider), '+61');
      expect(container.read(authControllerProvider).countryCode, '+61');
    });

    test('host app defaults phone auth to the Catch market', () {
      AppConfig.configureEntrypointRole(AppRole.host);
      final binding = TestWidgetsFlutterBinding.ensureInitialized();
      binding.platformDispatcher.localeTestValue = const Locale('en', 'US');
      addTearDown(binding.platformDispatcher.clearLocaleTestValue);

      final repository = FakeAuthRepository();
      final container = ProviderContainer(
        overrides: [authRepositoryProvider.overrideWithValue(repository)],
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      expect(container.read(authInitialCountryDialCodeProvider), '+91');
      expect(container.read(authControllerProvider).countryCode, '+91');
    });

    test('defaults country code from the locale provider', () {
      final repository = FakeAuthRepository();
      final container = _authControllerContainer(
        repository,
        defaultCountryCode: '+61',
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      expect(container.read(authControllerProvider).countryCode, '+61');
    });

    test('setCountryCode updates state and resets mutation', () {
      final repository = FakeAuthRepository();
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier).setCountryCode('+1');

      expect(container.read(authControllerProvider).countryCode, '+1');
    });

    test('goToStep changes the current step', () {
      final repository = FakeAuthRepository();
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier).goToStep(AuthStep.otp);

      expect(container.read(authControllerProvider).step, AuthStep.otp);
    });

    test('reset clears all state', () {
      final repository = FakeAuthRepository();
      final container = _authControllerContainer(repository);
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier)
        ..goToStep(AuthStep.otp)
        ..setCountryCode('+1');
      container.read(authControllerProvider.notifier).reset();

      expect(container.read(authControllerProvider), const AuthScreenState());
    });

    test('reset restores the locale-derived country code', () {
      final repository = FakeAuthRepository();
      final container = _authControllerContainer(
        repository,
        defaultCountryCode: '+977',
      );
      addTearDown(repository.dispose);
      addTearDown(container.dispose);

      container.read(authControllerProvider.notifier)
        ..goToStep(AuthStep.otp)
        ..setCountryCode('+1');
      container.read(authControllerProvider.notifier).reset();

      expect(
        container.read(authControllerProvider),
        const AuthScreenState(countryCode: '+977'),
      );
    });
  });

  group('AuthSessionController', () {
    test(
      'signOut delegates to the repository and clears auth flow state',
      () async {
        final repository = _SignOutAuthRepository();
        final container = _authControllerContainer(repository);
        addTearDown(repository.dispose);
        addTearDown(container.dispose);

        container.read(authControllerProvider.notifier)
          ..setCountryCode('+1')
          ..goToStep(AuthStep.otp);

        await container.read(authSessionControllerProvider.notifier).signOut();

        expect(repository.signOutCallCount, 1);
        expect(container.read(authControllerProvider), const AuthScreenState());
      },
    );
  });
}

ProviderContainer _authControllerContainer(
  FakeAuthRepository repository, {
  String defaultCountryCode = '+91',
}) {
  return ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(repository),
      authInitialCountryDialCodeProvider.overrideWithValue(defaultCountryCode),
    ],
  );
}

class _SignOutAuthRepository extends FakeAuthRepository {
  int signOutCallCount = 0;

  @override
  Future<void> signOut() async {
    signOutCallCount += 1;
  }
}
